OCR_SCRIPT_DIR="${0:A:h}"
OCR_PROJECT=''
OCR_FLUTTER=''
OCR_MODE=''
OCR_DEVICE_NAME=''
OCR_DEVICE_ID=''
OCR_DEVICE_LABEL=''
OCR_YES=0
OCR_LIST=0
OCR_TIMEOUT=180
OCR_OUTPUT=''
OCR_BUILD_ROOT=''
OCR_DERIVED_DATA=''
OCR_ISOLATED_NATIVE=0
OCR_BUILD_DRIVER=official_flutter
OCR_IOS_BUILD=''
OCR_SPM_CACHE=''
OCR_RUN_DIR=''
OCR_RUN_ID=''
OCR_RUN_PID=''
OCR_INPUT_FD=''
OCR_CONFIG_BACKUP=''
OCR_APP=''
OCR_LOCK_DIR=''
OCR_LOCK_OWNED=0
OCR_FINAL_WRITTEN=0
typeset -A OCR_GENERATED_HASH

ocr_intro() {
  printf '%s\n' 'Rust OCR移动验收：发现设备 → 官方缓存编译 → 安装启动 → 真识别回执。'
  printf '%s\n' '将安装覆盖所选设备上的本工程App，不卸载、不清除App数据。成功后保留App运行。'
  printf '%s\n' '构建成功不算验收通过；无设备、签名失败或没有真实样本回执会分别记录。'
}

ocr_usage() {
  printf '%s\n' '用法：本脚本 --simulator | --device [--auto] [--yes] [--name 设备名]'
  printf '%s\n' '      [--project Flutter工程] [--output 证据目录] [--build-root 独立构建目录]'
  printf '%s\n' '      [--derived-data 现有或独立DerivedData目录] [--timeout 秒] [--list]'
  printf '%s\n' '--simulator 只选iOS模拟器；--device只选iOS真机。--auto显式声明自动样本验收。'
  printf '%s\n' '单个匹配设备自动使用；多个用fzf，或用--name精确过滤；不要求抄UDID。'
  printf '%s\n' '--yes跳过脚本确认，适用于已授权自动化；--list只读列出匹配设备。'
}

ocr_parse() {
  while (( $# )); do
    case "$1" in
      --simulator) [[ -z "$OCR_MODE" || "$OCR_MODE" == simulator ]] || return 64; OCR_MODE=simulator ;;
      --device) [[ -z "$OCR_MODE" || "$OCR_MODE" == device ]] || return 64; OCR_MODE=device ;;
      --auto) ;;
      --yes) OCR_YES=1 ;;
      --list) OCR_LIST=1 ;;
      --name|--project|--output|--build-root|--derived-data|--timeout)
        (( $# >= 2 )) || return 64
        case "$1" in
          --name) OCR_DEVICE_NAME="$2" ;;
          --project) OCR_PROJECT="${2:A}" ;;
          --output) OCR_OUTPUT="${2:A}" ;;
          --build-root) OCR_BUILD_ROOT="${2:A}"; OCR_ISOLATED_NATIVE=1 ;;
          --derived-data) OCR_DERIVED_DATA="${2:A}"; OCR_ISOLATED_NATIVE=1 ;;
          --timeout) [[ "$2" == <-> ]] && (( $2 >= 10 && $2 <= 3600 )) || return 64; OCR_TIMEOUT="$2" ;;
        esac
        shift
        ;;
      --help|-h) ocr_usage; return 10 ;;
      *) printf '未知参数：%s\n' "$1" >&2; return 64 ;;
    esac
    shift
  done
  [[ -n "$OCR_MODE" ]] || { ocr_usage; return 64; }
}

ocr_find_project() {
  local candidate="${OCR_PROJECT:-$OCR_SCRIPT_DIR}"
  while [[ "$candidate" != / ]]; do
    if [[ -f "$candidate/pubspec.yaml" && -f "$candidate/lib/demos/离线文字识别/验收入口.dart" ]]; then
      OCR_PROJECT="$candidate"
      return 0
    fi
    [[ -z "$OCR_PROJECT" ]] || break
    candidate="${candidate:h}"
  done
  printf '%s\n' '未找到包含OCR验收入口的Flutter宿主，请用--project指定工程。' >&2
  return 66
}

ocr_confirm() {
  (( OCR_YES || OCR_LIST )) && return 0
  [[ -t 0 ]] || { printf '%s\n' '非交互运行需要显式--yes；尚未开始构建。' >&2; return 64; }
  if [[ -n "${JOBS_TERMINAL_STYLE_OWNER:-}" && -z "${NO_COLOR+x}" ]]; then
    printf '确认继续：\033[1;32m仅按回车\033[0m；\033[1;31m输入任意字符再回车取消\033[0m：'
  else
    printf '确认继续：仅按回车；输入任意字符再回车取消：'
  fi
  local choice=''
  IFS= read -r choice || return 130
  [[ -z "$choice" ]] || return 130
}

ocr_initialize() {
  setopt NO_NOMATCH
  umask 077
  if [[ -x "$OCR_PROJECT/.fvm/flutter_sdk/bin/flutter" ]]; then
    OCR_FLUTTER="$OCR_PROJECT/.fvm/flutter_sdk/bin/flutter"
  else
    OCR_FLUTTER="$(command -v flutter)"
  fi
  [[ -x "$OCR_FLUTTER" ]] || { printf '%s\n' 'Flutter不可运行，请先修复宿主工程工具链。' >&2; return 69; }
  command -v xcrun >/dev/null && command -v osascript >/dev/null || return 69
  OCR_RUN_ID="$(/usr/bin/uuidgen)"
  local stamp="$(TZ=Asia/Shanghai /bin/date '+%Y.%m.%d %H-%M-%S')"
  OCR_RUN_DIR="${OCR_OUTPUT:-$OCR_PROJECT/项目相关报告/RustOCR验收}/运行-$stamp-$OCR_RUN_ID"
  OCR_BUILD_ROOT="${OCR_BUILD_ROOT:-$OCR_PROJECT/work/RustOCRValidation}"
  if (( OCR_ISOLATED_NATIVE )); then
    OCR_DERIVED_DATA="${OCR_DERIVED_DATA:-$OCR_BUILD_ROOT/DerivedData}"
    OCR_BUILD_DRIVER=audited_xcodebuild
  fi
  /bin/mkdir -p "$OCR_RUN_DIR" || return 73
  trap 'ocr_cleanup' EXIT
  trap 'ocr_receipt not_run interrupted "用户取消或进程中断"; exit 130' INT TERM HUP
  printf '工程：%s\n构建入口：%s\nDerivedData：%s\n证据：%s\n' "$OCR_PROJECT" "$OCR_BUILD_DRIVER" "${OCR_DERIVED_DATA:-由官方Flutter管理当前workspace缓存}" "$OCR_RUN_DIR"
}

ocr_receipt() {
  [[ -n "$OCR_RUN_DIR" ]] || return 0
  local wanted="$1" reason="$2" message="$3"
  /usr/bin/osascript -l JavaScript - "$wanted" "$reason" "$message" "$OCR_RUN_ID" "$OCR_MODE" "$OCR_DEVICE_ID" "$OCR_DEVICE_LABEL" "$OCR_RUN_DIR/native-evidence.json" "$OCR_BUILD_ROOT" "$OCR_DERIVED_DATA" "$OCR_BUILD_DRIVER" "$OCR_SPM_CACHE" <<'JXA' > "$OCR_RUN_DIR/evidence.json"
ObjC.import('Foundation');
function run(a) {
  let native = null;
  try {
    const source = $.NSString.stringWithContentsOfFileEncodingError($(a[7]), $.NSUTF8StringEncoding, null);
    if (source) native = JSON.parse(source.js);
  } catch (_) {}
  const valid = native && native.run_id === a[3] && native.passed === true &&
      native.source === 'JobsRustOCR/real-native-sample' && native.engine === 'jobs-rust-ocr/indra' &&
      native.platform === 'iOS' && native.width > 0 && native.height > 0 &&
      native.anchor_found === true && native.line_count > 0 && /^[a-f0-9]{64}$/.test(native.text_sha256);
  const outcome = a[0] === 'passed' && !valid ? 'failed' : a[0];
  return JSON.stringify({schema_version:1, status:outcome,
    reason:outcome !== a[0] ? 'invalid_native_receipt' : a[1], message:a[2],
    run_id:a[3], mode:a[4], device_id:a[5], device_name:a[6],
    recorded_at:new Date().toISOString(), build_driver:a[10],
    build_root:a[10] === 'audited_xcodebuild' ? a[8] : null,
    derived_data:a[9] || null, spm_cache:a[11] || null, native:native,
    scope:'actual Flutter app launch and bundled-sample OCR; not a full OCR accuracy evaluation'},null,2);
}
JXA
  local result=$?
  (( result == 0 )) && OCR_FINAL_WRITTEN=1
  return "$result"
}

ocr_devices() {
  (cd "$OCR_PROJECT" && "$OCR_FLUTTER" devices --machine --device-timeout 20) > "$OCR_RUN_DIR/devices.json" 2> "$OCR_RUN_DIR/device-query.log"
  local device_code=$?
  if (( device_code != 0 )); then
    ocr_receipt failed device_query_failed '设备查询失败；不能据此认定没有真机。'
    return "$device_code"
  fi
  /usr/bin/osascript -l JavaScript - "$OCR_RUN_DIR/devices.json" "$OCR_MODE" "$OCR_DEVICE_NAME" <<'JXA' > "$OCR_RUN_DIR/devices.tsv"
ObjC.import('Foundation');
function run(a) {
  const data=$.NSString.stringWithContentsOfFileEncodingError($(a[0]),$.NSUTF8StringEncoding,null);
  const devices=JSON.parse(data.js);
  if (!Array.isArray(devices)) throw Error('Device response is not an array');
  return devices.filter(d=>d.targetPlatform==='ios' && d.isSupported!==false &&
      (a[1]==='simulator' ? d.emulator===true : d.emulator===false) && (!a[2] || d.name===a[2]))
    .map(d=>[d.id,d.name,d.sdk].map(x=>String(x || '').replace(/[\t\r\n]/g,' ')).join('\t')).join('\n');
}
JXA
  if (( $? != 0 )); then
    ocr_receipt failed device_response_invalid '无法解析设备清单。'
    return 65
  fi
  (( OCR_LIST )) && { /bin/cat "$OCR_RUN_DIR/devices.tsv"; ocr_receipt not_run list_only '只读设备列表，未构建或启动。'; return 10; }
  local -a rows
  rows=("${(@f)$(/bin/cat "$OCR_RUN_DIR/devices.tsv")}")
  [[ -n "${rows[1]:-}" ]] || {
    ocr_receipt not_run no_matching_device '没有匹配的现有设备；未进行此模式验收。'
    return 2
  }
  local selected=''
  if (( ${#rows} == 1 )); then
    selected="${rows[1]}"
  else
    command -v fzf >/dev/null || { ocr_receipt not_run fzf_missing '多个设备需要fzf；尚未选择或启动。'; return 69; }
    [[ -t 0 ]] || { ocr_receipt not_run device_selection_required '多个设备请交互选择，或用--name精确筛选。'; return 2; }
    selected="$(printf '%s\n' "${rows[@]}" | fzf --height=45% --delimiter=$'\t' --with-nth=2,3 --header='↑↓选择；回车或空格确认；Esc取消' --bind='space:accept')" || {
      ocr_receipt not_run selection_cancelled '已取消设备选择。'; return 130
    }
  fi
  IFS=$'\t' read -r OCR_DEVICE_ID OCR_DEVICE_LABEL _ <<< "$selected"
  printf '目标：%s（%s）\n' "$OCR_DEVICE_LABEL" "$OCR_MODE"
}

ocr_command() {
  local log_name="$1"
  shift
  "$@" 2>&1 | /usr/bin/tee "$OCR_RUN_DIR/$log_name"
  local -a codes=("${pipestatus[@]}")
  (( codes[1] == 0 )) || return "${codes[1]}"
  return "${codes[2]}"
}

ocr_backup_generated() {
  OCR_CONFIG_BACKUP="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/jobs-ocr-flutter-config.XXXXXX")" || return 73
  local name
  for name in Generated.xcconfig flutter_export_environment.sh; do
    if [[ -f "$OCR_PROJECT/ios/Flutter/$name" ]]; then
      /bin/cp -p "$OCR_PROJECT/ios/Flutter/$name" "$OCR_CONFIG_BACKUP/$name" || return 73
    fi
  done
}

ocr_lock() {
  OCR_LOCK_DIR="$OCR_PROJECT/work/RustOCRValidation/.runner-lock"
  /bin/mkdir -p "${OCR_LOCK_DIR:h}" || return 73
  if ! /bin/mkdir "$OCR_LOCK_DIR" 2>/dev/null; then
    ocr_receipt not_run runner_busy '已有验收占用专用输出；请先核查.runner-lock中的进程，不自动删除锁。'
    return 75
  fi
  OCR_LOCK_OWNED=1
  printf '%s\n' "$OCR_RUN_ID" > "$OCR_LOCK_DIR/run_id"
  printf '%s\n' "$$" > "$OCR_LOCK_DIR/pid"
}

ocr_capture_generated() {
  local name
  for name in Generated.xcconfig flutter_export_environment.sh; do
    if [[ -f "$OCR_PROJECT/ios/Flutter/$name" ]]; then
      OCR_GENERATED_HASH[$name]="$(/usr/bin/shasum -a 256 "$OCR_PROJECT/ios/Flutter/$name" | /usr/bin/awk '{print $1}')"
    fi
  done
}

ocr_flutter_build_layout() {
  local line flutter_build=''
  while IFS= read -r line; do
    [[ "$line" == FLUTTER_BUILD_DIR=* ]] && flutter_build="${line#FLUTTER_BUILD_DIR=}"
  done < "$OCR_PROJECT/ios/Flutter/Generated.xcconfig"
  [[ -n "$flutter_build" ]] || return 65
  [[ "$flutter_build" == /* ]] || flutter_build="$OCR_PROJECT/$flutter_build"
  OCR_IOS_BUILD="$flutter_build/ios"
  OCR_SPM_CACHE="$OCR_IOS_BUILD/SourcePackages"
}

ocr_require_audited_sdk() {
  # Explicit DD overrides are allowed only for the SDK parameter flow audited here.
  local sdk_root="${OCR_FLUTTER:A:h:h}"
  local -a files=(ios/xcodeproj.dart ios/mac.dart xcode_project.dart macos/swift_package_manager.dart)
  local -a expected=(1ce40886792da2c14c1bc7629a6e1af9602d53bbc05b8c1800d1227b7203b1ca b8bc45ef189e45e8c4b21db558f98b86a781722e985eb2db68a36d239bcf3f55 3f71e64dfbcc6055dd31284c833135feb63738f9d04489b9aedbe94a4ceb89ec d443591419c0aa2d723bf3fb45cb6e3a1a373b2fb1e44ecc1d54b06c6a9ac3ed)
  local index actual
  for index in {1..4}; do
    actual="$(/usr/bin/shasum -a 256 "$sdk_root/packages/flutter_tools/lib/src/${files[$index]}" 2>/dev/null | /usr/bin/awk '{print $1}')"
    if [[ "$actual" != "${expected[$index]}" ]]; then
      ocr_receipt not_run unaudited_sdk_override '当前SDK参数流已变化；请去掉--build-root/--derived-data，使用默认官方Flutter构建。'
      return 65
    fi
  done
}

ocr_build() {
  local sdk="$OCR_PROJECT/JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR"
  [[ -f "$sdk/JobsRustOCR.podspec" ]] || { ocr_receipt not_run sdk_missing '自包含Apple SDK尚未打包，未开始编译。'; return 2; }
  ocr_lock || return $?
  if (( OCR_ISOLATED_NATIVE )); then
    ocr_require_audited_sdk || return $?
  fi
  ocr_backup_generated || return $?
  local -a flutter_args=(build ios --debug --no-pub -d "$OCR_DEVICE_ID" -t 'lib/demos/离线文字识别/验收入口.dart' --dart-define=JOBS_OCR_AUTO=true "--dart-define=JOBS_OCR_RUN_ID=$OCR_RUN_ID")
  [[ "$OCR_MODE" == simulator ]] && flutter_args+=(--simulator --no-codesign)
  local build_code=0 product=iphoneos
  [[ "$OCR_MODE" == simulator ]] && product=iphonesimulator
  if (( ! OCR_ISOLATED_NATIVE )); then
    (cd "$OCR_PROJECT" && ocr_command build.log "$OCR_FLUTTER" "${flutter_args[@]}")
    build_code=$?
    ocr_capture_generated
    (( build_code == 0 )) || { ocr_receipt failed flutter_build_failed '官方Flutter构建失败，详见build.log；不能标记OCR通过。'; return "$build_code"; }
    ocr_flutter_build_layout || { ocr_receipt failed build_layout_missing '官方构建没有生成有效输出配置。'; return 65; }
    OCR_APP="$OCR_IOS_BUILD/$product/Runner.app"
    [[ -d "$OCR_APP" ]] || { ocr_receipt failed app_missing '官方构建没有生成预期App。'; return 66; }
    return 0
  fi
  # Config-only invokes Flutter's real SwiftPM prefetch before a native DD override.
  flutter_args+=(--config-only)
  (cd "$OCR_PROJECT" && ocr_command configure.log "$OCR_FLUTTER" "${flutter_args[@]}")
  build_code=$?
  ocr_capture_generated
  (( build_code == 0 )) || { ocr_receipt failed flutter_config_failed 'Flutter配置／依赖准备失败，详见configure.log。'; return "$build_code"; }
  ocr_flutter_build_layout || { ocr_receipt failed build_layout_missing '官方配置没有生成有效输出目录。'; return 65; }
  # Local pod resolution is explicit and never updates remote specs.
  (cd "$OCR_PROJECT/ios" && ocr_command pods.log pod install --no-repo-update) || {
    build_code=$?; ocr_receipt failed pod_install_failed 'CocoaPods依赖解析失败，详见pods.log。'; return "$build_code"
  }
  local dd="$OCR_DERIVED_DATA"
  local defines="$(printf '%s' JOBS_OCR_AUTO=true | /usr/bin/base64 | /usr/bin/tr -d '\n'),$(printf '%s' "JOBS_OCR_RUN_ID=$OCR_RUN_ID" | /usr/bin/base64 | /usr/bin/tr -d '\n')"
  local -a xcode=(xcrun xcodebuild)
  [[ "$(/usr/bin/uname -m)" == arm64 ]] && xcode=(/usr/bin/arch -arm64e xcrun xcodebuild)
  # Match Flutter's build flow: shared SourcePackages, BUILD_DIR, no validation-skip flags.
  local -a build_args=(-clonedSourcePackagesDirPath "$OCR_SPM_CACHE" -workspace "$OCR_PROJECT/ios/Runner.xcworkspace" -scheme Runner -configuration Debug -sdk "$product" -destination "id=$OCR_DEVICE_ID" -derivedDataPath "$dd" -jobs 1 "BUILD_DIR=$OCR_IOS_BUILD" "FLUTTER_TARGET=$OCR_PROJECT/lib/demos/离线文字识别/验收入口.dart" "DART_DEFINES=$defines")
  [[ "$OCR_MODE" == simulator ]] && build_args+=(CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO 'CODE_SIGNING_IDENTITY=""')
  ocr_command build.log "${xcode[@]}" "${build_args[@]}" build || {
    build_code=$?; ocr_receipt failed native_build_failed '原生编译／签名失败，不能标记OCR通过。'; return "$build_code"
  }
  OCR_APP="$OCR_IOS_BUILD/Debug-$product/Runner.app"
  [[ -d "$OCR_APP" ]] || { ocr_receipt failed app_missing '构建没有生成预期App。'; return 66; }
}

ocr_run() {
  local fifo="$OCR_RUN_DIR/flutter-input.fifo"
  /usr/bin/mkfifo "$fifo" || return 73
  exec {OCR_INPUT_FD}<>"$fifo"
  (cd "$OCR_PROJECT" && "$OCR_FLUTTER" run --debug --no-pub --no-devtools -d "$OCR_DEVICE_ID" -t 'lib/demos/离线文字识别/验收入口.dart' "--use-application-binary=$OCR_APP" --dart-define=JOBS_OCR_AUTO=true "--dart-define=JOBS_OCR_RUN_ID=$OCR_RUN_ID") < "$fifo" > "$OCR_RUN_DIR/run.log" 2>&1 &
  OCR_RUN_PID=$!
  local start_seconds=$SECONDS
  local line=''
  while (( SECONDS - start_seconds < OCR_TIMEOUT )); do
    line="$(/usr/bin/sed -n 's/^.*JOBS_OCR_EVIDENCE: //p' "$OCR_RUN_DIR/run.log" | /usr/bin/tail -n 1)"
    if [[ -n "$line" ]]; then
      printf '%s\n' "$line" > "$OCR_RUN_DIR/native-evidence.json"
      ocr_receipt passed native_receipt_received 'App已实际启动并返回本轮样本识别回执。' || return $?
      local verdict="$(/usr/bin/plutil -extract status raw -o - "$OCR_RUN_DIR/evidence.json")"
      if [[ "$OCR_MODE" == simulator ]]; then
        xcrun simctl io "$OCR_DEVICE_ID" screenshot "$OCR_RUN_DIR/screenshot.png" >/dev/null 2>&1 || :
      fi
      printf 'd\n' >&$OCR_INPUT_FD
      local waiting=0
      while kill -0 "$OCR_RUN_PID" 2>/dev/null && (( waiting < 20 )); do
        /bin/sleep 1
        (( waiting++ ))
      done
      [[ "$verdict" == passed ]] && return 0
      return 1
    fi
    if ! kill -0 "$OCR_RUN_PID" 2>/dev/null; then
      wait "$OCR_RUN_PID"
      local run_code=$?
      ocr_receipt failed no_native_receipt "Flutter退出但没有原生识别回执，退出码=$run_code。"
      return 1
    fi
    /bin/sleep 1
  done
  ocr_receipt failed native_receipt_timeout '等待真实识别回执超时，详见run.log。'
  return 1
}

ocr_cleanup() {
  local name current_hash
  if [[ -n "$OCR_RUN_PID" ]] && kill -0 "$OCR_RUN_PID" 2>/dev/null; then
    # Only the child still owned by this script may be stopped.
    if [[ "$(/bin/ps -p "$OCR_RUN_PID" -o ppid= | /usr/bin/tr -d ' ')" == "$$" ]]; then
      kill -TERM "$OCR_RUN_PID" 2>/dev/null || :
    fi
  fi
  if [[ -n "$OCR_INPUT_FD" ]]; then
    exec {OCR_INPUT_FD}>&-
  fi
  [[ -n "$OCR_RUN_DIR" && -p "$OCR_RUN_DIR/flutter-input.fifo" ]] && /bin/rm -f "$OCR_RUN_DIR/flutter-input.fifo"
  if [[ -n "$OCR_CONFIG_BACKUP" && -d "$OCR_CONFIG_BACKUP" ]]; then
    for name in Generated.xcconfig flutter_export_environment.sh; do
      [[ -n "${OCR_GENERATED_HASH[$name]:-}" ]] || continue
      current_hash="$(/usr/bin/shasum -a 256 "$OCR_PROJECT/ios/Flutter/$name" 2>/dev/null | /usr/bin/awk '{print $1}')"
      if [[ "$current_hash" == "${OCR_GENERATED_HASH[$name]}" ]]; then
        if [[ -f "$OCR_CONFIG_BACKUP/$name" ]]; then
          /bin/cp -p "$OCR_CONFIG_BACKUP/$name" "$OCR_PROJECT/ios/Flutter/$name"
        else
          /bin/rm -f "$OCR_PROJECT/ios/Flutter/$name"
        fi
      else
        printf '保留并发生成配置，未覆盖：%s\n' "$name" >&2
      fi
    done
    # Private backups remain for inspection when concurrent changes prevent restoration.
  fi
  if [[ -n "$OCR_RUN_DIR" && "$OCR_FINAL_WRITTEN" == 0 ]]; then
    ocr_receipt failed interrupted_before_receipt '流程未产生最终回执，请查看各阶段日志。' || :
  fi
  if (( OCR_LOCK_OWNED )) && [[ -f "$OCR_LOCK_DIR/run_id" ]] && [[ "$(/bin/cat "$OCR_LOCK_DIR/run_id")" == "$OCR_RUN_ID" ]]; then
    /bin/rm -f "$OCR_LOCK_DIR/run_id" "$OCR_LOCK_DIR/pid"
    /bin/rmdir "$OCR_LOCK_DIR" 2>/dev/null || :
  fi
}

main() {
  ocr_intro
  ocr_parse "$@"
  local parse_code=$?
  (( parse_code == 10 )) && return 0
  (( parse_code == 0 )) || return "$parse_code"
  ocr_find_project || return $?
  ocr_confirm || return $?
  ocr_initialize || return $?
  ocr_devices
  local device_code=$?
  (( device_code == 10 )) && return 0
  (( device_code == 0 )) || return "$device_code"
  ocr_build || return $?
  ocr_run
  local result_code=$?
  printf '验收退出码：%s；证据：%s/evidence.json\n' "$result_code" "$OCR_RUN_DIR"
  return "$result_code"
}

