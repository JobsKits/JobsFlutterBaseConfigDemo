#!/bin/sh
# 脚本自述：保留旧入口解释器，用随包zsh模块准备SDK网络；实际构建和依赖业务只执行一次。
# 仅作为入口子进程运行；不source用户Shell文件，不修改系统代理或持久SDK源。

# 由脚本实际位置解析同目录资源，支持整体复制到中文或空格路径。
jobs_sdk_adapter_initialize() {
    JOBS_SDK_ADAPTER_PATH=$0
    case "$JOBS_SDK_ADAPTER_PATH" in
        /*) ;;
        *) JOBS_SDK_ADAPTER_PATH=$PWD/$JOBS_SDK_ADAPTER_PATH ;;
    esac
    JOBS_SDK_ADAPTER_DIRECTORY=$(CDPATH= cd -P -- "$(dirname -- "$JOBS_SDK_ADAPTER_PATH")" && pwd) || exit 1
    JOBS_SDK_NETWORK_MODULE=$JOBS_SDK_ADAPTER_DIRECTORY/../【MacOS】FlutterSDK网络选路.zsh/【MacOS】FlutterSDK网络选路.zsh
    [ -f "$JOBS_SDK_NETWORK_MODULE" ] || { printf '%s\n' '✖ 缺少随包Flutter SDK网络模块，请保留完整Scripts目录。' >&2; exit 1; }
    # 本适配器的SDK日志始终追加，不能继承外层run_bounded的“重建日志”标记。
    export JOBS_SDK_LOG_REPLACED=0
    JOBS_SDK_NETWORK_LOG=${JOBS_FLUTTER_ROUTE_LOG:-}
    [ -n "$JOBS_SDK_NETWORK_LOG" ] || JOBS_SDK_NETWORK_LOG=$(mktemp "${TMPDIR:-/tmp/}JobsFlutterSdkNetwork.XXXXXX") || exit 1
    JOBS_SDK_TARGET_ROOT=${JOBS_FLUTTER_ROUTE_SDK_ROOT:-}
    JOBS_SDK_TARGET_VERSION=${JOBS_FLUTTER_ROUTE_VERSION:-}
    JOBS_SDK_PROJECT=
    JOBS_SDK_PROGRAM=
}
# 仅通过系统JSON解析器读取目标字段，禁止执行SDK或把FVM完整environment写到磁盘。
jobs_sdk_adapter_json() {
    /usr/bin/osascript -l JavaScript -e 'ObjC.import("Foundation"); function run(a) { const d=$.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile; const s=ObjC.unwrap($.NSString.alloc.initWithDataEncoding(d,$.NSUTF8StringEncoding)); const m=JSON.parse(s); const v=a[0]==="cache" ? m.context&&m.context.versionsCachePath : a[0]==="cask" ? (m.casks&&m.casks[0]) : (m.flutter||m.flutterSdkVersion||""); if(a[0]==="cask") { if(!v||typeof v.url!=="string"||!/^https:\/\//.test(v.url)||/[\u0000-\u001f\u007f]/.test(v.url)) throw Error("invalid Flutter cask URL"); return [v.url,String(v.version||"")].join("\t"); } if(typeof v!=="string"||/[\u0000-\u001f\u007f]/.test(v)) throw Error("invalid metadata"); return v; }' "$@"
}
# 优先使用当前工程的明确SDK声明；目录名不能充当版本信息。
jobs_sdk_adapter_project() {
    local directory=$PWD
    while :; do
        if [ -f "$directory/pubspec.yaml" ]; then
            JOBS_SDK_PROJECT=$directory
            if [ -z "$JOBS_SDK_TARGET_ROOT" ] && [ -d "$directory/.fvm/flutter_sdk" ]; then
                JOBS_SDK_TARGET_ROOT=$directory/.fvm/flutter_sdk
            fi
            if [ -z "$JOBS_SDK_TARGET_VERSION" ]; then
                if [ -f "$directory/.fvmrc" ]; then
                    JOBS_SDK_TARGET_VERSION=$(jobs_sdk_adapter_json version < "$directory/.fvmrc" 2>/dev/null) || JOBS_SDK_TARGET_VERSION=
                elif [ -f "$directory/.fvm/fvm_config.json" ]; then
                    JOBS_SDK_TARGET_VERSION=$(jobs_sdk_adapter_json version < "$directory/.fvm/fvm_config.json" 2>/dev/null) || JOBS_SDK_TARGET_VERSION=
                fi
            fi
            return 0
        fi
        [ "$directory" != / ] || return 0
        directory=$(dirname -- "$directory")
    done
}
# 解析真正的外部命令，避免调用父Shell的flutter()/dart()重载形成递归。
jobs_sdk_adapter_program() {
    case "$1" in
        */*) JOBS_SDK_PROGRAM=$1 ;;
        *) JOBS_SDK_PROGRAM=$(command -v "$1" 2>/dev/null) || return 127 ;;
    esac
    [ -x "$JOBS_SDK_PROGRAM" ] || return 127
    local link= count=0
    while [ -L "$JOBS_SDK_PROGRAM" ]; do
        count=$((count + 1)); [ "$count" -lt 40 ] || return 1
        link=$(readlink "$JOBS_SDK_PROGRAM") || return 1
        case "$link" in /*) JOBS_SDK_PROGRAM=$link ;; *) JOBS_SDK_PROGRAM=$(dirname -- "$JOBS_SDK_PROGRAM")/$link ;; esac
    done
}
# 共享本任务私有路线缓存，选择结果只在模块及实际命令子进程中生效。
jobs_sdk_adapter_route() {
    if [ "${1:-}" = --run ] || [ "${1:-}" = --flutter-upgrade ]; then
        JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 /bin/zsh "$JOBS_SDK_NETWORK_MODULE" "$@"
    else
        /bin/zsh "$JOBS_SDK_NETWORK_MODULE" "$@"
    fi
}
# 当前SDK真正就绪只认engine stamp与原生Dart，不能只看SDK目录存在。
jobs_sdk_adapter_ready() {
    [ -n "$1" ] && [ -f "$1/bin/internal/engine.version" ] &&
        [ -f "$1/bin/cache/engine-dart-sdk.stamp" ] && [ -x "$1/bin/cache/dart-sdk/bin/dart" ] || return 1
    if [ -n "${FLUTTER_PREBUILT_ENGINE_VERSION:-}" ]; then
        [ "$(cat "$1/bin/cache/engine-dart-sdk.stamp")" = "$FLUTTER_PREBUILT_ENGINE_VERSION" ]
    else
        cmp -s "$1/bin/internal/engine.version" "$1/bin/cache/engine-dart-sdk.stamp"
    fi
}
# FVM缓存位置仅来自生效context；完整JSON只经过管道，不写日志或临时文件。
jobs_sdk_adapter_fvm_root() {
    local cache=
    cache=$("$1" api context --compress 2>/dev/null | jobs_sdk_adapter_json cache 2>/dev/null) || return 1
    case "$cache" in /*) ;; *) return 1 ;; esac
    case "$2" in ''|*/*|*..*) return 1 ;; esac
    [ -d "$cache/$2" ] || return 1
    JOBS_SDK_TARGET_ROOT=$cache/$2
}
# 安装SDK使用公共两阶段接口，保留原FVM源、目标版本及附加安装参数。
jobs_sdk_adapter_fvm_install() {
    local manager=$1 wanted=$2
    shift 2
    jobs_sdk_adapter_route --fvm-install 'FVM SDK获取与就绪验证' "$JOBS_SDK_NETWORK_LOG" "$manager" "$wanted" "$@"
}
# channel切换只处理原Git分支；后续upgrade再按新频道制品单独预检。
jobs_sdk_adapter_channel() {
    local sdk=$1 wanted=$2
    shift 2
    /bin/zsh -s -- "$JOBS_SDK_NETWORK_MODULE" "$JOBS_SDK_NETWORK_LOG" "$sdk" "$wanted" "$@" <<'JOBS_CHANNEL'
source "$1" || exit 1
log_file=$2
sdk=$3
wanted=$4
shift 4
[[ -n "$sdk" && "$wanted" != *$'\n'* ]] || exit 2
local_git=(/usr/bin/env -u GIT_DIR -u GIT_INDEX_FILE -u GIT_WORK_TREE -u GIT_COMMON_DIR /usr/bin/git --no-optional-locks -c core.fsmonitor=false -C "$sdk")
url="$("${local_git[@]}" remote get-url origin 2>/dev/null)" || exit 2
ref="refs/heads/$wanted"
"${local_git[@]}" check-ref-format "$ref" >/dev/null 2>&1 || exit 2
JOBS_FLUTTER_ROUTE_MODE=git JOBS_FLUTTER_ROUTE_SOURCE_URL="$url" JOBS_FLUTTER_ROUTE_GIT_REF="$ref" \
JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 jobs_flutter_sdk_retry 'Flutter原Git频道切换' "$log_file" "$sdk" "$wanted" "$@"
JOBS_CHANNEL
}

# SDK就绪后才执行原业务；初始化可重试，构建、run与pub只执行一次。
jobs_sdk_adapter_flutter() {
    local program=$1 family=$2 action=$3 origin=
    shift 3
    if [ "$family" = fvm ]; then
        if [ -n "$JOBS_SDK_TARGET_VERSION" ]; then
            JOBS_SDK_TARGET_ROOT=
            jobs_sdk_adapter_fvm_root "$program" "$JOBS_SDK_TARGET_VERSION" || true
        fi
        if ! jobs_sdk_adapter_ready "$JOBS_SDK_TARGET_ROOT" && [ -n "$JOBS_SDK_TARGET_VERSION" ]; then
            jobs_sdk_adapter_fvm_install "$program" "$JOBS_SDK_TARGET_VERSION" || return $?
            jobs_sdk_adapter_fvm_root "$program" "$JOBS_SDK_TARGET_VERSION" || true
        fi
        if [ -z "$action" ]; then
            jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter --version >/dev/null || return $?
            jobs_sdk_adapter_route --once 'Flutter命令（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter
            return $?
        fi
        case "$action" in
            --version) jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter "$action" "$@" ;;
            precache) JOBS_FLUTTER_ROUTE_MODE=platform jobs_sdk_adapter_route --run 'Flutter平台资源' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter "$action" "$@" ;;
            channel)
                jobs_sdk_adapter_route --run '切频道前当前SDK原生Dart补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter --version >/dev/null || return $?
                if [ "$#" -gt 0 ]; then jobs_sdk_adapter_channel "$JOBS_SDK_TARGET_ROOT" "$1" "$program" flutter channel "$@"
                else jobs_sdk_adapter_route --once 'Flutter频道列表' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter channel; fi
                ;;
            upgrade)
                jobs_sdk_adapter_route --run '升级前当前SDK原生Dart补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter --version >/dev/null || return $?
                jobs_sdk_adapter_route --flutter-upgrade 'Flutter SDK升级' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" '' "$program" flutter "$action" "$@"
                ;;
            *)
                jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter --version >/dev/null || return $?
                jobs_sdk_adapter_route --once 'Flutter业务（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter "$action" "$@"
                ;;
        esac
    else
        case "$program" in
            */bin/flutter)
                JOBS_SDK_TARGET_ROOT=$(CDPATH= cd -P -- "$(dirname -- "$program")/.." && pwd) || return 1
                JOBS_SDK_TARGET_VERSION=${JOBS_FLUTTER_ROUTE_VERSION:-}
                ;;
        esac
        if [ -z "$action" ]; then
            jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" --version >/dev/null || return $?
            jobs_sdk_adapter_route --once 'Flutter命令（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program"
            return $?
        fi
        case "$action" in
            --version) jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" "$action" "$@" ;;
            precache) JOBS_FLUTTER_ROUTE_MODE=platform jobs_sdk_adapter_route --run 'Flutter平台资源' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" "$action" "$@" ;;
            channel)
                jobs_sdk_adapter_route --run '切频道前当前SDK原生Dart补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" --version >/dev/null || return $?
                if [ "$#" -gt 0 ]; then jobs_sdk_adapter_channel "$JOBS_SDK_TARGET_ROOT" "$1" "$program" channel "$@"
                else jobs_sdk_adapter_route --once 'Flutter频道列表' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" channel; fi
                ;;
            upgrade)
                jobs_sdk_adapter_route --run '升级前当前SDK原生Dart补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" --version >/dev/null || return $?
                jobs_sdk_adapter_route --flutter-upgrade 'Flutter SDK升级' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" '' "$program" "$action" "$@"
                ;;
            *)
                jobs_sdk_adapter_route --run 'Flutter/Dart首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" --version >/dev/null || return $?
                jobs_sdk_adapter_route --once 'Flutter业务（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" "$action" "$@"
                ;;
        esac
    fi
}
# URL尚未知时只重试Brew原metadata查询，不猜tap/API地址或修改Brew原路由。
jobs_sdk_adapter_brew_metadata() {
    /bin/zsh -s -- "$JOBS_SDK_NETWORK_MODULE" "$1" "$JOBS_SDK_NETWORK_LOG" "${2:---run}" <<'JOBS_BREW_METADATA'
source "$1" || exit 1
manager=$2
log_file=$3
metadata_operation=$4
child='' interrupted=0 result=0 attempt=1 delay=2 details='' offset=0 filtered=''
filtered="$(/usr/bin/mktemp "${TMPDIR:-/tmp/}JobsFlutterCaskMetadata.XXXXXXXX")" || exit 1
# 文件只存筛选后的URL/版本，完整Brew JSON始终只经过管道。
TRAPEXIT() { [[ -z "$child" ]] || jfs_route_stop_tree "$child"; /bin/rm -f -- "$filtered"; }
trap 'interrupted=130; [[ -z "$child" ]] || jfs_route_stop_tree "$child"' INT
trap 'interrupted=143; [[ -z "$child" ]] || jfs_route_stop_tree "$child"' TERM
trap 'interrupted=129; [[ -z "$child" ]] || jfs_route_stop_tree "$child"' HUP
while true; do
    offset=0
    [[ ! -f "$log_file" ]] || offset="$(/usr/bin/wc -c < "$log_file")"
    : > "$filtered"
    jfs_route_note "$log_file" "▶ Flutter cask metadata获取第${attempt}次：保留Brew原命令与既有网络配置，尚未进入SDK payload路线选择。"
    (
        setopt PIPE_FAIL
        jfs_fvm_timed /usr/bin/env HOMEBREW_NO_AUTO_UPDATE=1 "$manager" info --json=v2 --cask flutter \
            2> >(/usr/bin/tee -a "$log_file" >&2) |
          /usr/bin/osascript -l JavaScript -e 'ObjC.import("Foundation");function run(){const d=$.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile;const s=ObjC.unwrap($.NSString.alloc.initWithDataEncoding(d,$.NSUTF8StringEncoding));const m=JSON.parse(s),c=m.casks&&m.casks[0];if(!c||typeof c.url!=="string"||!/^https:\/\//.test(c.url)||/[\u0000-\u001f\u007f]/.test(c.url))throw Error("Flutter cask metadata缺少有效原始URL");return[c.url,String(c.version||"")].join("\t");}' \
            2> >(/usr/bin/tee -a "$log_file" >&2)
    ) > "$filtered" &
    child=$!
    result=0
    wait "$child" || result=$?
    child=''
    (( interrupted==0 )) || exit "$interrupted"
    if (( result==0 )) && [[ -s "$filtered" ]]; then
        /bin/cat "$filtered"
        exit 0
    fi
    case "$result" in 126|127|129|130|131|137|143) exit "$result" ;; esac
    details="$(/usr/bin/tail -c +$((offset+1)) "$log_file" | /usr/bin/tail -c 65536)"
    if print -r -- "$details" | /usr/bin/grep -Eqi 'Permission denied|Operation not permitted|No space left|No available Cask|No Cask with this name|Cask .* (unavailable|not found|does not exist)|No formulae or casks found|No formulae found|No available formula|metadata缺少有效原始URL'; then
        (( result!=0 )) || result=1
        exit "$result"
    fi
    if [[ "$metadata_operation" == --once ]]; then
        jfs_route_note "$log_file" 'Download failed: Flutter cask metadata网络获取未完成，交回原双栈流程换路；未执行SDK安装。'
        (( result!=0 )) || result=1
        exit "$result"
    fi
    jfs_route_note "$log_file" "⚠ Flutter cask metadata尚未获取成功（$result），${delay}秒后重试原查询；Ctrl+C取消，未重复安装。"
    /bin/sleep "$delay" &
    child=$!
    wait "$child" || result=$?
    child=''
    (( interrupted==0 )) || exit "$interrupted"
    (( result<128 )) || exit "$result"
    (( attempt++ ))
    (( delay>=30 )) || delay=$((delay*2))
    (( delay<=30 )) || delay=30
done
JOBS_BREW_METADATA
}

# Brew下载地址与摘要仍由Brew负责；只比较真正cask URL的网络路线，不替换下载主机。
jobs_sdk_adapter_brew() {
    local brew=$1 operation=$2 metadata= url= version= route_operation=${JOBS_SDK_BREW_ROUTE_OPERATION:---run}
    shift 2
    metadata=$(jobs_sdk_adapter_brew_metadata "$brew" "$route_operation") || return $?
    url=$(printf '%s\n' "$metadata" | cut -f1)
    version=$(printf '%s\n' "$metadata" | cut -f2)
    local curl_bin=${HOMEBREW_CURL_PATH:-${JOBS_FLUTTER_ROUTE_CURL:-/usr/bin/curl}} config= prepare_once=0
    [ "$route_operation" != --once ] || prepare_once=1
    case "${HOMEBREW_CURLRC:-}" in
        /*) [ ! -f "$HOMEBREW_CURLRC" ] || config=$HOMEBREW_CURLRC ;;
    esac
    # 同一Brew curl配置同时用于小样本与实际下载；一次预检失败交回原双栈外循环。
    if [ -n "$config" ]; then
        JOBS_FLUTTER_ROUTE_CURL_CONFIG="$config" JOBS_FLUTTER_ROUTE_CURL="$curl_bin" \
        JOBS_FLUTTER_ROUTE_PREPARE_ONCE="$prepare_once" \
        JOBS_FLUTTER_ROUTE_MODE=source JOBS_FLUTTER_ROUTE_SOURCE_URL="$url" \
            jobs_sdk_adapter_route "$route_operation" 'Brew Flutter cask原始制品' "$JOBS_SDK_NETWORK_LOG" '' "$version" "$brew" "$operation" --cask flutter "$@"
    else
        JOBS_FLUTTER_ROUTE_CURL="$curl_bin" JOBS_FLUTTER_ROUTE_PREPARE_ONCE="$prepare_once" \
        JOBS_FLUTTER_ROUTE_MODE=source JOBS_FLUTTER_ROUTE_SOURCE_URL="$url" \
            jobs_sdk_adapter_route "$route_operation" 'Brew Flutter cask原始制品' "$JOBS_SDK_NETWORK_LOG" '' "$version" "$brew" "$operation" --cask flutter "$@"
    fi
}
# 官方SDK只下载manifest确认的精确归档；解压由原入口执行一次。
jobs_sdk_adapter_official_archive() {
    /bin/zsh -s -- "$JOBS_SDK_NETWORK_MODULE" "$JOBS_SDK_NETWORK_LOG" "$1" "$2" <<'JOBS_OFFICIAL_ARCHIVE'
source "$1" || exit 1
log_file=$2
wanted=$3
output=$4
previous_object=''
[[ "$output" == /* && -f "$output" ]] || exit 2
function official_archive_once() {
    local object="${JOBS_FLUTTER_ROUTE_OBJECT_PATH:-}" sha="${JOBS_FLUTTER_ROUTE_EXPECTED_SHA256:-}" result=0
    [[ -n "$object" && "$object" == flutter_infra_release/releases/* && "$sha" =~ '^[a-fA-F0-9]{64}$' ]] || { jfs_route_note "$log_file" '✖ 精确归档或SHA256缺失，未下载未验证SDK。'; return 2; }
    if [[ -n "$previous_object" && "$previous_object" != "$object" ]]; then : > "$output"; fi
    previous_object="$object"
    if [[ -s "$output" ]]; then
      local cached="$(/usr/bin/shasum -a 256 "$output" | /usr/bin/awk '{print $1}')"
      [[ "$cached" != "${sha:l}" ]] || { jfs_route_note "$log_file" '✓ 本任务完整归档已通过manifest SHA256校验。'; return 0; }
      local bytes="$(/usr/bin/wc -c < "$output")"
      if [[ "${JFS_SIZE:-}" == <-> ]] && (( bytes>=JFS_SIZE )); then : > "$output"; fi
    fi
    "${JOBS_FLUTTER_ROUTE_CURL:-/usr/bin/curl}" --fail --location --connect-timeout 10 --max-time 1800 \
      --speed-limit 1024 --speed-time 30 --continue-at - --output "$output" \
      "${FLUTTER_STORAGE_BASE_URL:-https://storage.googleapis.com}/$object" || result=$?
    if (( result==33 || result==36 )); then : > "$output"; return 1; fi
    (( result==0 )) || return "$result"
    local actual="$(/usr/bin/shasum -a 256 "$output" | /usr/bin/awk '{print $1}')"
    if [[ "$actual" != "${sha:l}" ]]; then
      jfs_route_note "$log_file" '⚠ SDK归档摘要不匹配，清空本任务归档后重新获取，不触碰SDK缓存。'
      : > "$output"
      return 1
    fi
    jfs_route_note "$log_file" '✓ 目标版本/架构归档已通过manifest SHA256校验。'
}
JOBS_FLUTTER_ROUTE_MODE=archive JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 \
  jobs_flutter_sdk_retry '官方Flutter SDK精确归档' "$log_file" '' "$wanted" official_archive_once
JOBS_OFFICIAL_ARCHIVE
}
# 仅支持现有FVM前置dart formula；Brew负责原供应商URL、鉴权、摘要和安装。
jobs_sdk_adapter_brew_dart() {
    local retry=$JOBS_SDK_ADAPTER_DIRECTORY/../【MacOS】SDK获取重试.zsh/【MacOS】SDK获取重试.zsh
    [ -f "$retry" ] || return 1
    /bin/zsh -s -- "$JOBS_SDK_NETWORK_MODULE" "$retry" "$JOBS_SDK_NETWORK_LOG" "$@" <<'JOBS_BREW_DART'
source "$1" || exit 1
source "$2" || exit 1
log_file=$3
manager=$4
operation=$5
shift 5
extra_args=("$@")
filtered="$(/usr/bin/mktemp "${TMPDIR:-/tmp/}JobsDartFormulaMetadata.XXXXXXXX")" || exit 1
TRAPEXIT() { /bin/rm -f -- "$filtered"; }
function dart_formula_metadata_once() {
    setopt LOCAL_OPTIONS PIPE_FAIL
    # Formula#bottle由Brew根据当前OS/arch选择兼容bottle，包含已配置的供应商域名。
    local exact=''
    exact="$(jfs_fvm_timed /usr/bin/env HOMEBREW_NO_AUTO_UPDATE=1 "$manager" ruby -e 'require "formula"; f=Formula["dart"]; b=f.bottle; puts(b ? b.url : f.stable.url)' 2>/dev/null)" || exact=''
    jfs_fvm_timed /usr/bin/env HOMEBREW_NO_AUTO_UPDATE=1 "$manager" info --json=v2 dart \
      2> >(/usr/bin/tee -a "$log_file" >&2) |
      /usr/bin/osascript -l JavaScript -e 'ObjC.import("Foundation");function run(a){const d=$.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile;const m=JSON.parse(ObjC.unwrap($.NSString.alloc.initWithDataEncoding(d,$.NSUTF8StringEncoding)));const f=m.formulae&&m.formulae[0];if(!f)throw Error("No available formula dart");let u=a[0],kind="exact";if(!/^https:\/\/[^\s]+$/.test(u)){u=f.urls&&f.urls.stable&&f.urls.stable.url||"";kind=f.bottle&&f.bottle.stable&&Object.keys(f.bottle.stable.files||{}).length?"representative":"exact";}if(!/^https:\/\/[^\s]+$/.test(u)){u="";kind="unresolved";}return[u,String(f.versions&&f.versions.stable||""),kind].join("\t");}' "$exact" > "$filtered" \
      2> >(/usr/bin/tee -a "$log_file" >&2)
}
JOBS_SDK_LOG_REPLACED=0 jobs_sdk_retry 'Dart Brew供应商metadata获取' "$log_file" dart_formula_metadata_once || exit $?
IFS=$'\t' read -r url version identity < "$filtered"
function dart_formula_install_once() {
    local result=0 prefix='' probe_result=0
    if [[ -n "$url" ]]; then
      jfs_route_note "$log_file" "▶ Dart SDK供应商原URL预检；metadata身份=$identity。"
      local JOBS_FLUTTER_ROUTE_MODE=source JOBS_FLUTTER_ROUTE_SOURCE_URL="$url" JOBS_FLUTTER_ROUTE_PREPARE_ONCE=1
      local JOBS_FLUTTER_ROUTE_CURL="${HOMEBREW_CURL_PATH:-${JOBS_FLUTTER_ROUTE_CURL:-/usr/bin/curl}}"
      local JOBS_FLUTTER_ROUTE_CURL_CONFIG="${JOBS_FLUTTER_ROUTE_CURL_CONFIG:-}"
      [[ "${HOMEBREW_CURLRC:-}" != /* || ! -f "$HOMEBREW_CURLRC" ]] || JOBS_FLUTTER_ROUTE_CURL_CONFIG="$HOMEBREW_CURLRC"
      jobs_flutter_route_prepare '' "$version" "$log_file" source || probe_result=$?
      case "$probe_result" in 129|130|137|143) return "$probe_result" ;; esac
      if (( probe_result!=0 )); then
        jfs_route_note "$log_file" 'ℹ 供应商正文预检未取得可用路线（可能需Brew原鉴权）；保留Brew原通道实际尝试，不冒称已验证payload。'
      elif [[ "$identity" != exact ]]; then
        jfs_route_note "$log_file" 'ℹ 仅验证供应商source代表对象，实际bottle仍由Brew原通道处理，不冒称已核对bottle。'
      fi
    else
      jfs_route_note "$log_file" 'ℹ 未能解析Dart实际制品URL；仅有界查询原dart-lang tap作为诊断，实际Brew获取继续重试，不假称制品路线已验证。'
      jfs_fvm_timed /usr/bin/env GIT_TERMINAL_PROMPT=0 /usr/bin/git ls-remote --exit-code https://github.com/dart-lang/homebrew-dart.git HEAD >/dev/null 2>&1 || true
    fi
    /usr/bin/env HOMEBREW_NO_AUTO_UPDATE=1 "$manager" "$operation" dart "${extra_args[@]}" 2>&1 | /usr/bin/tee -a "$log_file"
    result=${pipestatus[1]}
    (( result==0 )) || { jobs_flutter_route_invalidate; return "$result"; }
    prefix="$(jfs_fvm_timed "$manager" --prefix dart 2>/dev/null)" || return 1
    [[ "$prefix" == /* && -x "$prefix/bin/dart" ]] || { jfs_route_note "$log_file" '⚠ Brew返回0但Dart原生入口未就绪，继续获取。'; return 1; }
}
jobs_sdk_retry 'Dart SDK原供应商获取与就绪验证' "$log_file" dart_formula_install_once
JOBS_BREW_DART
}

# 仅FVM工具包属于SDK前置获取；普通Dart项目业务仍只执行一次。
jobs_sdk_adapter_dart_business() {
    local program=$1 sdk=$2
    shift 2
    if [ "${1:-}" = pub ] && [ "${2:-}" = global ] && [ "${3:-}" = activate ] && [ "${4:-}" = fvm ]; then
        local retry=$JOBS_SDK_ADAPTER_DIRECTORY/../【MacOS】SDK获取重试.zsh/【MacOS】SDK获取重试.zsh
        [ -f "$retry" ] || return 1
        /bin/zsh -s -- "$retry" "$JOBS_SDK_NETWORK_LOG" "$program" "$@" <<'JOBS_FVM_PACKAGE'
source "$1" || exit 1
log_file=$2
shift 2
function fvm_package_once() {
    "$@" 2>&1 | /usr/bin/tee -a "$log_file"
    local result=${pipestatus[1]}
    (( result==0 )) || return "$result"
    [[ -x "${PUB_CACHE:-$HOME/.pub-cache}/bin/fvm" ]] || { print -r -- '⚠ FVM工具包返回0但原缓存执行入口缺失，继续获取。' | /usr/bin/tee -a "$log_file" >&2; return 1; }
}
jobs_sdk_retry 'FVM前置工具包获取' "$log_file" fvm_package_once "$@"
JOBS_FVM_PACKAGE
    elif [ -n "$sdk" ]; then
        jobs_sdk_adapter_route --once 'Dart命令（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$sdk" '' "$program" "$@"
    else
        "$program" "$@"
    fi
}

# 仅分派实际SDK获取，普通命令保持原参数和一次执行语义。
jobs_sdk_adapter_dispatch() {
    [ "$#" -gt 0 ] || return 2
    case "$1" in
        --releases)
            shift
            JOBS_FLUTTER_ROUTE_MODE=source JOBS_FLUTTER_ROUTE_EXPECTED_TEXT='"releases"' \
            JOBS_FLUTTER_ROUTE_SOURCE_URL="${FLUTTER_STORAGE_BASE_URL-https://storage.googleapis.com}/flutter_infra_release/releases/releases_macos.json" \
              jobs_sdk_adapter_route --run 'Flutter SDK版本清单' "$JOBS_SDK_NETWORK_LOG" '' '' /usr/bin/curl -fsSL --connect-timeout 10 --max-time 60 "${FLUTTER_STORAGE_BASE_URL-https://storage.googleapis.com}/flutter_infra_release/releases/releases_macos.json"
            return $?
            ;;
        --official-archive) shift; jobs_sdk_adapter_official_archive "$@"; return $? ;;
        --brew-dart) shift; jobs_sdk_adapter_brew_dart "$@"; return $? ;;
        --brew-cask|--brew-cask-once)
            [ "$1" != --brew-cask-once ] || JOBS_SDK_BREW_ROUTE_OPERATION=--once
            shift
            jobs_sdk_adapter_brew "$@"
            return $?
            ;;
    esac
    jobs_sdk_adapter_project
    jobs_sdk_adapter_program "$1" || return $?
    local program=$JOBS_SDK_PROGRAM family=${1##*/} action=${2:-}
    shift
    if [ "$family" = fvm ]; then
        jobs_sdk_adapter_route --fvm-runtime 'FVM外部Dart运行时检查' "$JOBS_SDK_NETWORK_LOG" "$program" || return $?
    fi
    case "$family:$action" in
        fvm:install)
            shift
            [ "$#" -gt 0 ] || return 2
            local wanted=$1
            shift
            jobs_sdk_adapter_fvm_install "$program" "$wanted" "$@"
            ;;
        fvm:use)
            shift
            [ "$#" -gt 0 ] || return 2
            local wanted=$1
            shift
            JOBS_SDK_TARGET_ROOT=
            jobs_sdk_adapter_fvm_root "$program" "$wanted" || true
            if ! jobs_sdk_adapter_ready "$JOBS_SDK_TARGET_ROOT"; then
                jobs_sdk_adapter_fvm_install "$program" "$wanted" || return $?
                jobs_sdk_adapter_fvm_root "$program" "$wanted" || true
            fi
            jobs_sdk_adapter_route --once 'FVM项目绑定（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$wanted" "$program" use "$wanted" "$@"
            ;;
        fvm:releases)
            shift
            JOBS_FLUTTER_ROUTE_MODE=source JOBS_FLUTTER_ROUTE_EXPECTED_TEXT='"releases"' \
            JOBS_FLUTTER_ROUTE_SOURCE_URL="${FLUTTER_STORAGE_BASE_URL-https://storage.googleapis.com}/flutter_infra_release/releases/releases_macos.json" \
                jobs_sdk_adapter_route --run 'FVM SDK远程版本清单' "$JOBS_SDK_NETWORK_LOG" '' '' "$program" releases "$@"
            ;;
        fvm:dart)
            shift
            if [ -n "$JOBS_SDK_TARGET_VERSION" ]; then
                JOBS_SDK_TARGET_ROOT=
                jobs_sdk_adapter_fvm_root "$program" "$JOBS_SDK_TARGET_VERSION" || true
            fi
            if ! jobs_sdk_adapter_ready "$JOBS_SDK_TARGET_ROOT" && [ -n "$JOBS_SDK_TARGET_VERSION" ]; then
                jobs_sdk_adapter_fvm_install "$program" "$JOBS_SDK_TARGET_VERSION" || return $?
                jobs_sdk_adapter_fvm_root "$program" "$JOBS_SDK_TARGET_VERSION" || true
            fi
            jobs_sdk_adapter_route --run 'Dart所属Flutter SDK首次补齐' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" flutter --version >/dev/null || return $?
            jobs_sdk_adapter_route --once 'FVM Dart命令（仅一次）' "$JOBS_SDK_NETWORK_LOG" "$JOBS_SDK_TARGET_ROOT" "$JOBS_SDK_TARGET_VERSION" "$program" dart "$@"
            ;;
        fvm:flutter)
            shift
            action=${1:-}
            [ "$#" -eq 0 ] || shift
            jobs_sdk_adapter_flutter "$program" fvm "$action" "$@"
            ;;
        flutter:*)
            [ "$#" -eq 0 ] || shift
            jobs_sdk_adapter_flutter "$program" direct "$action" "$@"
            ;;
        dart:*)
            local sdk=
            sdk=$(CDPATH= cd -P -- "$(dirname -- "$program")/.." && pwd) || return 1
            if [ -f "$sdk/bin/internal/update_dart_sdk.sh" ]; then
                JOBS_SDK_TARGET_ROOT=$sdk
                jobs_sdk_adapter_route --run 'Dart所属Flutter SDK首次补齐' "$JOBS_SDK_NETWORK_LOG" "$sdk" '' "$sdk/bin/flutter" --version >/dev/null || return $?
                jobs_sdk_adapter_dart_business "$program" "$sdk" "$@"
            else
                jobs_sdk_adapter_dart_business "$program" '' "$@"
            fi
            ;;
        *) "$program" "$@" ;;
    esac
}
# 统一编排私有资源定位与SDK命令分派。
main() {
    jobs_sdk_adapter_initialize # 确认后的SDK调用才解析随包资源和日志。
    jobs_sdk_adapter_dispatch "$@" # SDK获取持续重试，原业务只执行一次。
}
main "$@"
