#!/bin/zsh
# Created by Jobs on 2026年11月4日，星期三.
# CI SDK准备：只写runner临时目录和本job环境；失败持续获取，作业取消/预算结束会终止子树。
# source用于verify版本补齐；--install用于GitHub Actions，不执行项目依赖、测试或业务构建。
JCI_PACKAGE_DIR="${${(%):-%x}:A:h}"

jobs_ci_load_network() {
    (( $+functions[jobs_flutter_sdk_retry] )) && return 0
    source "$JCI_PACKAGE_DIR/【MacOS】FlutterSDK网络选路.zsh/【MacOS】FlutterSDK网络选路.zsh"
}
jobs_ci_publish_sdk() {
    /usr/bin/python3 - "$1" "$2" <<'PYCODE'
import ctypes, errno, os, sys
source, target = sys.argv[1:]
parent = os.path.dirname(target)
if os.path.islink(parent) or not os.path.isdir(parent) or os.path.lexists(target):
    raise SystemExit('invalid argument: SDK发布目标或父目录不是预期普通路径，未覆盖。')
libc = ctypes.CDLL(None, use_errno=True)
rename = libc.renamex_np
rename.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_uint]
rename.restype = ctypes.c_int
# Darwin sys/stdio.h: RENAME_EXCL = 0x00000004; existing targets are never replaced.
if rename(os.fsencode(source), os.fsencode(target), 0x00000004):
    code = ctypes.get_errno()
    raise SystemExit('invalid argument: SDK原子发布失败，未覆盖：' + os.strerror(code))
PYCODE
}
jobs_ci_archive_once() {
    local object="${JOBS_FLUTTER_ROUTE_OBJECT_PATH:-}" sha="${JOBS_FLUTTER_ROUTE_EXPECTED_SHA256:-}" resolved="${JOBS_FLUTTER_ROUTE_RESOLVED_VERSION:-}"
    local archive="$JCI_TASK/archive.part" identity='' root='' extracted='' code=0 digest='' previous=''
    [[ "$resolved" == "$JCI_VERSION" && "$sha" =~ '^[0-9a-fA-F]{64}$' && "$object" == flutter_infra_release/releases/*/macos/flutter_macos_*.zip ]] || { print -u2 'invalid argument: SDK发布清单没有匹配的版本/架构/可信SHA。'; return 2; }
    identity="$JCI_VERSION|$JCI_ARCH|$sha|$object"
    root="$JCI_RUNNER/jobs-flutter-sdk/$JCI_VERSION-$JCI_ARCH-$sha"
    [[ ! -L "${root:h}" && -d "${root:h}" ]] || { print -u2 'invalid argument: SDK发布父目录被替换，未写入。'; return 2; }
    if [[ -L "$root" ]]; then print -u2 'invalid argument: SDK目标为链接，未跟随或覆盖。'; return 2; fi
    if [[ -e "$root" ]]; then
        if [[ -d "$root" && ! -L "$root" && -f "$root/.jobs-ci-trusted" && "$(<"$root/.jobs-ci-trusted")" == "$identity" && -x "$root/bin/flutter" && -x "$root/bin/cache/dart-sdk/bin/dart" ]]; then
            print -r -- "$root" > "$JCI_RESULT"; print -u2 '✓ 复用本job已按同版本/架构/SHA验证的SDK。'; return 0
        fi
        print -u2 'invalid argument: runner SDK目标已存在但可信身份或必要文件不匹配，未覆盖。'; return 2
    fi
    if [[ -f "$JCI_TASK/archive.identity" && "$(<"$JCI_TASK/archive.identity")" != "$identity" && -f "$archive" ]]; then
        /bin/mv "$archive" "$archive.previous.$(/usr/bin/uuidgen)" || return $?
    fi
    print -r -- "$identity" > "$JCI_TASK/archive.identity"
    local -a args=(--fail --location --max-redirs 4 --proto '=https' --proto-redir '=https' --connect-timeout 15 --speed-time 30 --speed-limit 1 --retry 0 --output "$archive")
    [[ ! -s "$archive" ]] || args+=(--continue-at -)
    [[ ! -f "${JOBS_FLUTTER_ROUTE_CURL_CONFIG:-}" ]] || args+=(--config "$JOBS_FLUTTER_ROUTE_CURL_CONFIG")
    "${JOBS_FLUTTER_ROUTE_CURL:-/usr/bin/curl}" "${args[@]}" "${FLUTTER_STORAGE_BASE_URL:-https://storage.googleapis.com}/$object" || code=$?
    if (( code!=0 )); then
        (( code!=33 )) || { previous="$archive.unresumable.$(/usr/bin/uuidgen)"; [[ ! -f "$archive" ]] || /bin/mv "$archive" "$previous"; }
        return "$code"
    fi
    digest="$(/usr/bin/shasum -a 256 "$archive" | /usr/bin/awk '{print $1}')"
    if [[ "$digest" != "${sha:l}" ]]; then
        /bin/mv "$archive" "$archive.bad-sha.$(/usr/bin/uuidgen)" || return $?
        print -u2 'SDK完整SHA校验失败，校验副本保留；下一轮重新获取。'; return 1
    fi
    extracted="$(/usr/bin/mktemp -d "$JCI_TASK/extract.XXXXXX")" || return 1
    /usr/bin/unzip -q "$archive" -d "$extracted" || return $?
    [[ -x "$extracted/flutter/bin/flutter" && -x "$extracted/flutter/bin/cache/dart-sdk/bin/dart" ]] || { print -u2 'SDK归档缺少Flutter/Dart必要文件，未发布；获取阶段继续。'; return 1; }
    print -r -- "$identity" > "$extracted/flutter/.jobs-ci-trusted"
    jobs_ci_publish_sdk "$extracted/flutter" "$root" || return $?
    print -r -- "$root" > "$JCI_RESULT"
}
jobs_ci_install_flutter() {
    setopt LOCAL_OPTIONS
    unsetopt NOUNSET
    local JCI_VERSION="$1" JCI_ARCH="$2" JCI_RUNNER="${RUNNER_TEMP:-}" JCI_TASK='' JCI_RESULT='' native=x64 sdk=''
    [[ "${GITHUB_ACTIONS:-}" == true && -d "$JCI_RUNNER" && -n "${GITHUB_PATH:-}" && -n "${GITHUB_ENV:-}" ]] || { print -u2 'SDK安装只允许GitHub Actions runner及本job环境文件。'; return 2; }
    [[ "$JCI_VERSION" =~ '^[0-9]+\.[0-9]+\.[0-9]+([-+][A-Za-z0-9.+-]+)?$' && "$JCI_ARCH" == (arm64|x64) ]] || return 2
    [[ "$(/usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null)" != 1 ]] || native=arm64
    [[ "$native" == "$JCI_ARCH" ]] || { print -u2 'SDK要求架构与runner实际架构不一致，未下载其它架构代替。'; return 2; }
    JCI_RUNNER="${JCI_RUNNER:A}"
    jobs_ci_load_network || return $?
    local published="$JCI_RUNNER/jobs-flutter-sdk"
    if [[ -e "$published" || -L "$published" ]]; then
        [[ -d "$published" && ! -L "$published" && -f "$published/.jobs-ci-sdk-root" ]] || { print -u2 'invalid argument: SDK父目录已存在但并非本job普通受控目录。'; return 2; }
    else
        /bin/mkdir -m 700 "$published" || return $?
        print -r -- jobs-ci-sdk-v1 > "$published/.jobs-ci-sdk-root"
    fi
    JCI_TASK="$(/usr/bin/mktemp -d "$JCI_RUNNER/JobsCiFlutterSdk.XXXXXX")" || return 1
    /bin/chmod 700 "$JCI_TASK"; JCI_RESULT="$JCI_TASK/ready.path"
    local sdk_log="${JOBS_CI_LOG_DIR:-$JCI_TASK}/sdk-download.log"
    /bin/mkdir -p "${sdk_log:h}"
    jfs_route_note "$sdk_log" "CI准备Flutter $JCI_VERSION / macOS $JCI_ARCH；只写RUNNER_TEMP。SDK获取无内部次数限制；GitHub作业原60分钟预算及用户Cancel仍终止本轮任务。"
    JOBS_FLUTTER_ROUTE_MODE=archive JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 jobs_flutter_sdk_retry 'CI Flutter SDK归档' "$sdk_log" "$JCI_TASK/sdk-target" "$JCI_VERSION" jobs_ci_archive_once || return $?
    [[ -s "$JCI_RESULT" ]] || return 1
    sdk="$(<"$JCI_RESULT")"
    [[ "$sdk" == "$JCI_RUNNER/jobs-flutter-sdk/"* && -x "$sdk/bin/flutter" ]] || return 2
    print -r -- "$sdk/bin" >> "$GITHUB_PATH"
    print -r -- "FLUTTER_ROOT=$sdk" >> "$GITHUB_ENV"
    print -r -- "Flutter $JCI_VERSION / $JCI_ARCH SDK已核验：$sdk"
}
jobs_ci_version_once() {
    local tool="$1" destination="$2" temporary="$3" code=0
    "$tool" --version --machine > "$temporary" || code=$?
    (( code==0 )) || return "$code"
    /usr/bin/env jq -er '.frameworkVersion | select(type == "string" and length > 0)' "$temporary" >/dev/null || { print -u2 'SDK machine响应尚未完整，未发布版本文件。'; return 1; }
    /bin/mv "$temporary" "$destination"
}
jobs_ci_capture_version() {
    setopt LOCAL_OPTIONS
    unsetopt NOUNSET
    local tool="$1" destination="$2" log_file="$3" temporary='' sdk="${1:A:h:h}"
    jobs_ci_load_network || return $?
    temporary="$(/usr/bin/mktemp "${destination}.attempt.XXXXXX")" || return 1
    JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 jobs_flutter_sdk_retry 'CI Flutter/Dart自举与版本核验' "$log_file" "$sdk" '' jobs_ci_version_once "$tool" "$destination" "$temporary"
}
jobs_ci_precache_ios() {
    setopt LOCAL_OPTIONS
    unsetopt NOUNSET
    local tool="$1" log_file="$2" sdk="${1:A:h:h}"
    jobs_ci_load_network || return $?
    JOBS_FLUTTER_ROUTE_MODE=platform JOBS_FLUTTER_ROUTE_CAPTURE_OUTPUT=1 jobs_flutter_sdk_retry 'CI iOS平台SDK准备' "$log_file" "$sdk" '' "$tool" precache --ios
}
jobs_ci_sdk_main() {
    case "${1:-}" in
        --install) (( $#==3 )) || return 2; jobs_ci_install_flutter "$2" "$3" ;;
        *) print -u2 '用法：PrepareFlutterSdk.zsh --install <精确Flutter版本> <arm64|x64>；只用于CI，不执行项目构建。'; return 2 ;;
    esac
}
if [[ "$ZSH_EVAL_CONTEXT" == toplevel ]]; then jobs_ci_sdk_main "$@"; fi
