#!/bin/zsh
# Created by Jobs on 2026年11月4日，星期三.
# CI SDK准备：只写runner临时目录和本job环境；失败持续获取，作业取消/预算结束会终止子树。
# source用于verify版本补齐；--install用于GitHub Actions，不执行项目依赖、测试或业务构建。
# >>> Jobs terminal style protection v1 >>>
# 临时保护当前终端配色，业务进程自行管理原有退出清理。
jobs_terminal_style_run() {
    # 无法可靠保存原色时，沿用脚本已有的纯文本约定。
    jobs_terminal_style_plain() {
        PLAIN_OUTPUT=1
        NO_COLOR=1
        FORCE_COLOR=0
        CLICOLOR=0
        ANSI_COLORS_DISABLED=1
        npm_config_color=false
        export PLAIN_OUTPUT NO_COLOR FORCE_COLOR CLICOLOR ANSI_COLORS_DISABLED npm_config_color
        if "$@"; then
            jobs_style_exit_status=0
        else
            jobs_style_exit_status=$?
        fi
        exit "$jobs_style_exit_status"
    }
    if [ ! -t 0 ] || [ ! -t 1 ] || [ -z "${TERM:-}" ] ||
       [ "${TERM:-}" = dumb ] || [ "${NO_COLOR+x}" = x ] ||
       [ "${PLAIN_OUTPUT:-0}" = 1 ] || [ "${IS_SOURCETREE_RUNTIME:-0}" = 1 ] ||
       env | LC_ALL=C grep -qiE '^(SOURCETREE|SOURCE_TREE)'; then
        if "$@"; then
            jobs_style_exit_status=0
        else
            jobs_style_exit_status=$?
        fi
        exit "$jobs_style_exit_status"
    fi
    if [ -n "${TMUX:-}${STY:-}" ]; then
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_tty=$(tty 2>/dev/null) || jobs_terminal_style_plain "$@"
    if ! ps -o pgid= -o tpgid= -p "$$" 2>/dev/null |
         LC_ALL=C awk 'NF == 2 && $1 == $2 && $1 > 0 { foreground = 1 } END { exit !foreground }'; then
        jobs_terminal_style_plain "$@"
    fi
    case ${JOBS_TERMINAL_STYLE_OWNER:-} in
        ''|*[!0-9]*) ;;
        *)
            if [ "${JOBS_TERMINAL_STYLE_TTY:-}" = "$jobs_style_tty" ] &&
               kill -0 "$JOBS_TERMINAL_STYLE_OWNER" 2>/dev/null; then
                if "$@"; then
                    jobs_style_exit_status=0
                else
                    jobs_style_exit_status=$?
                fi
                exit "$jobs_style_exit_status"
            fi
            ;;
    esac
    jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || jobs_terminal_style_plain "$@"
    jobs_style_saved=''
    jobs_style_saved_rows=''
    jobs_style_applied_rows=''
    jobs_style_changed=0
    jobs_style_applied_complete=0
    jobs_style_query_active=0
    jobs_style_recovery=''
    jobs_style_exit_status=0
    jobs_style_esc=$(printf '\033')
    jobs_style_bel=$(printf '\007')
    # 只接受本次请求对应的 RGB 响应；非协议输入使本次探测失败。
    jobs_terminal_style_query() {
        jobs_style_query_key=$1
        printf '\033]%s;?\007' "$jobs_style_query_key" > /dev/tty || return 1
        jobs_style_reply=''
        for jobs_style_attempt in 1 2 3; do
            jobs_style_piece=$(dd bs=256 count=1 2>/dev/null < /dev/tty)
            jobs_style_reply=$jobs_style_reply$jobs_style_piece
            case $jobs_style_reply in
                *"$jobs_style_bel"|*"$jobs_style_esc\\") break ;;
                '') ;;
                "$jobs_style_esc"*) ;;
                *) break ;;
            esac
        done
        case $jobs_style_reply in
            "$jobs_style_esc]$jobs_style_query_key;rgb:"*"$jobs_style_bel")
                jobs_style_rgb=${jobs_style_reply#"$jobs_style_esc]$jobs_style_query_key;rgb:"}
                jobs_style_rgb=${jobs_style_rgb%"$jobs_style_bel"}
                ;;
            "$jobs_style_esc]$jobs_style_query_key;rgb:"*"$jobs_style_esc\\")
                jobs_style_rgb=${jobs_style_reply#"$jobs_style_esc]$jobs_style_query_key;rgb:"}
                jobs_style_rgb=${jobs_style_rgb%"$jobs_style_esc\\"}
                ;;
            *) return 1 ;;
        esac
        jobs_style_normalized=$(printf '%s\n' "$jobs_style_rgb" | LC_ALL=C awk -F/ '
            NF != 3 { exit 1 }
            {
                for (i = 1; i <= 3; i++) {
                    h = tolower($i)
                    if (length(h) < 1 || length(h) > 4 || h ~ /[^0-9a-f]/) exit 1
                    n = 0
                    for (j = 1; j <= length(h); j++) n = n * 16 + index("0123456789abcdef", substr(h, j, 1)) - 1
                    value[i] = int(n * 65535 / (16 ^ length(h) - 1) + 0.5)
                }
                printf "%d/%d/%d", value[1], value[2], value[3]
            }
        ') || return 1
        [ -n "$jobs_style_normalized" ]
    }
    # 查询可用不代表终端允许改色，按目标值核对实际生效结果。
    jobs_terminal_style_accepts_target() {
        jobs_style_requested_hex=''
        case $1 in
            10|12) jobs_style_requested_hex=ffffff ;;
            11) jobs_style_requested_hex=000000 ;;
            '4;'*)
                jobs_style_requested_index=0
                for jobs_style_requested_color in 000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff; do
                    if [ "4;$jobs_style_requested_index" = "$1" ]; then
                        jobs_style_requested_hex=$jobs_style_requested_color
                        break
                    fi
                    jobs_style_requested_index=$((jobs_style_requested_index + 1))
                done
                ;;
        esac
        [ -n "$jobs_style_requested_hex" ] || return 1
        printf '%s|%s\n' "$jobs_style_normalized" "$jobs_style_requested_hex" | LC_ALL=C awk -F'|' '
            function hexbyte(h) {
                return (index("0123456789abcdef", substr(h, 1, 1)) - 1) * 16 + index("0123456789abcdef", substr(h, 2, 1)) - 1
            }
            {
                if (split($1, actual, "/") != 3 || length($2) != 6) exit 1
                for (i = 1; i <= 3; i++) {
                    difference = actual[i] - hexbyte(substr($2, i * 2 - 1, 2)) * 257
                    if (difference < -255 || difference > 255) exit 1
                }
            }
        '
    }
    # 检测到后续改色时只恢复仍由本次保护持有的项，保留独立恢复入口。
    jobs_terminal_style_cleanup() {
        jobs_style_result=$1
        trap '' HUP INT TERM
        if [ "$jobs_style_query_active" = 1 ]; then
            stty "$jobs_style_stty" 2>/dev/null < /dev/tty || :
            jobs_style_query_active=0
        fi
        if [ "$jobs_style_changed" = 1 ]; then
            jobs_style_cleanup_ok=0
            jobs_style_conflicts=''
            jobs_style_restore_safe=''
            if [ "$jobs_style_applied_complete" = 1 ]; then
                jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || jobs_style_stty=''
                if [ -n "$jobs_style_stty" ] && stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty; then
                    jobs_style_query_active=1
                    jobs_style_cleanup_ok=1
                    while IFS='|' read -r jobs_style_key jobs_style_expected jobs_style_original; do
                        [ -n "$jobs_style_key" ] || continue
                        if ! jobs_terminal_style_query "$jobs_style_key"; then
                            jobs_style_cleanup_ok=0
                            break
                        fi
                        if [ "$jobs_style_normalized" = "$jobs_style_expected" ]; then
                            jobs_style_restore_safe=$jobs_style_restore_safe$jobs_style_original
                        else
                            jobs_style_conflicts="$jobs_style_conflicts $jobs_style_key"
                        fi
                    done <<JOBS_STYLE_APPLIED
$jobs_style_applied_rows
JOBS_STYLE_APPLIED
                    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || jobs_style_cleanup_ok=0
                    jobs_style_query_active=0
                fi
            fi
            if [ "$jobs_style_cleanup_ok" = 1 ] && printf '%s\033[0m' "$jobs_style_restore_safe" > /dev/tty; then
                if [ -z "$jobs_style_conflicts" ]; then
                    rm -f "$jobs_style_recovery"
                    rmdir "${jobs_style_recovery%/*}" 2>/dev/null || :
                else
                    printf '检测到运行期间的配色变更，已保留这些项：%s\n' "$jobs_style_conflicts" >&2
                    printf '确认要覆盖后续改色时才使用恢复入口：sh "%s"\n' "$jobs_style_recovery" >&2
                    [ "$jobs_style_result" -ne 0 ] || jobs_style_result=1
                fi
            else
                printf '终端配色未能安全自动恢复；确认覆盖当前配色后可运行：sh "%s"\n' "$jobs_style_recovery" >&2
                [ "$jobs_style_result" -ne 0 ] || jobs_style_result=1
            fi
        fi
        if [ "${2:-}" = continue ]; then
            jobs_style_cleanup_status=$jobs_style_result
            return 0
        fi
        exit "$jobs_style_result"
    }
    trap 'jobs_terminal_style_cleanup "$jobs_style_exit_status"' 0
    trap 'jobs_style_exit_status=129; exit 129' HUP
    trap 'jobs_style_exit_status=130; exit 130' INT
    trap 'jobs_style_exit_status=143; exit 143' TERM
    if ! stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty; then
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_query_active=1
    jobs_style_probe_ok=1
    for jobs_style_key in 10 11 12 '4;0' '4;1' '4;2' '4;3' '4;4' '4;5' '4;6' '4;7' '4;8' '4;9' '4;10' '4;11' '4;12' '4;13' '4;14' '4;15'; do
        if ! jobs_terminal_style_query "$jobs_style_key"; then
            jobs_style_probe_ok=0
            break
        fi
        jobs_style_saved=$jobs_style_saved$jobs_style_reply
        jobs_style_saved_rows="$jobs_style_saved_rows$jobs_style_key|$jobs_style_reply
"
    done
    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=0
    if [ "$jobs_style_probe_ok" != 1 ]; then
        printf '%s\n' '终端不支持完整配色保存，或启动时收到其它输入；保留原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    jobs_style_recovery_dir=$(umask 077; mktemp -d "${TMPDIR:-/tmp}/jobs-terminal-style.XXXXXX") || jobs_terminal_style_plain "$@"
    jobs_style_recovery=$jobs_style_recovery_dir/restore.sh
    if ! (umask 077; {
        printf '#!/bin/sh\n'
        printf '[ -t 0 ] && [ "$(tty)" = '\''%s'\'' ] || { printf '\''请在原终端运行恢复入口。\\n'\'' >&2; exit 1; }\n' "$jobs_style_tty"
        printf 'printf '\''本操作会覆盖此终端当前配色。确认恢复脚本启动前的配色，请输入 YES：'\'' >&2\n'
        printf 'IFS= read -r jobs_restore_choice\n[ "$jobs_restore_choice" = YES ] || exit 1\n'
        printf 'printf '\''%%s\\033[0m'\'' '\''%s'\'' > /dev/tty\n' "$jobs_style_saved"
    } > "$jobs_style_recovery"); then
        printf '%s\n' '无法保存终端配色恢复入口；保留原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    printf '正在准备本次终端临时配色；强退后恢复入口：sh "%s"\n' "$jobs_style_recovery" >&2
    jobs_style_changed=1
    printf '\033]10;#ffffff\007\033]11;#000000\007\033]12;#ffffff\007' > /dev/tty
    jobs_style_index=0
    for jobs_style_color in 000000 ff5f56 5fd787 ffd75f 5fafff d787ff 5fd7ff eeeeee 9e9e9e ff8787 87ffaf ffff87 87bfff ffafff afffff ffffff; do
        printf '\033]4;%s;#%s\007' "$jobs_style_index" "$jobs_style_color" > /dev/tty
        jobs_style_index=$((jobs_style_index + 1))
    done
    printf '\033[0m' > /dev/tty
    jobs_style_stty=$(stty -g 2>/dev/null < /dev/tty) || { jobs_style_exit_status=1; exit 1; }
    stty -echo -icanon min 0 time 1 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=1
    jobs_style_probe_ok=1
    jobs_style_targets_ok=1
    while IFS='|' read -r jobs_style_key jobs_style_original; do
        [ -n "$jobs_style_key" ] || continue
        if ! jobs_terminal_style_query "$jobs_style_key"; then
            jobs_style_probe_ok=0
            break
        fi
        jobs_style_applied_rows="$jobs_style_applied_rows$jobs_style_key|$jobs_style_normalized|$jobs_style_original
"
        if ! jobs_terminal_style_accepts_target "$jobs_style_key"; then
            jobs_style_targets_ok=0
        fi
    done <<JOBS_STYLE_ORIGINAL
$jobs_style_saved_rows
JOBS_STYLE_ORIGINAL
    stty "$jobs_style_stty" 2>/dev/null < /dev/tty || { jobs_style_exit_status=1; exit 1; }
    jobs_style_query_active=0
    if [ "$jobs_style_probe_ok" != 1 ]; then
        printf '%s\n' '无法核实本次临时配色，已停止启动业务。' >&2
        jobs_style_exit_status=1
        exit 1
    fi
    jobs_style_applied_complete=1
    if [ "$jobs_style_targets_ok" != 1 ]; then
        jobs_terminal_style_cleanup 0 continue
        jobs_style_changed=0
        if [ "$jobs_style_cleanup_status" != 0 ]; then
            jobs_style_exit_status=1
            exit 1
        fi
        trap 'jobs_style_exit_status=129; exit 129' HUP
        trap 'jobs_style_exit_status=130; exit 130' INT
        trap 'jobs_style_exit_status=143; exit 143' TERM
        printf '%s\n' '终端未接受本次配色，已恢复原配色并使用纯文本。' >&2
        jobs_terminal_style_plain "$@"
    fi
    printf '%s\n' '本次终端已临时使用黑底白字。' >&2
    JOBS_TERMINAL_STYLE_TTY=$jobs_style_tty
    JOBS_TERMINAL_STYLE_OWNER=$$
    export JOBS_TERMINAL_STYLE_TTY JOBS_TERMINAL_STYLE_OWNER
    if "$@"; then
        jobs_style_exit_status=0
    else
        jobs_style_exit_status=$?
    fi
    exit "$jobs_style_exit_status"
}
# 仅监督直接执行的入口；被 source 时不切换配色、不重新执行业务。
jobs_terminal_style_bootstrap() {
    jobs_style_bootstrap_script=$1
    shift
    if [ -n "${ZSH_VERSION:-}" ]; then
        case ${ZSH_EVAL_CONTEXT:-} in
            *:file|*:file:*) return 0 ;;
        esac
    elif [ -n "${BASH_VERSION:-}" ] && [ "${BASH_SOURCE:-$jobs_style_bootstrap_script}" != "$jobs_style_bootstrap_script" ]; then
        return 0
    fi
    if [ "${JOBS_TERMINAL_STYLE_REEXEC:-}" = "$jobs_style_bootstrap_script" ]; then
        unset JOBS_TERMINAL_STYLE_REEXEC
        return 0
    fi
    if [ ! -t 0 ] || [ ! -t 1 ] || [ -z "${TERM:-}" ] ||
       [ "${TERM:-}" = dumb ] || [ "${NO_COLOR+x}" = x ] ||
       [ "${PLAIN_OUTPUT:-0}" = 1 ] || [ "${IS_SOURCETREE_RUNTIME:-0}" = 1 ] ||
       [ -n "${TMUX:-}${STY:-}" ] ||
       env | LC_ALL=C grep -qiE '^(SOURCETREE|SOURCE_TREE)'; then
        return 0
    fi
    case ${JOBS_TERMINAL_STYLE_OWNER:-} in
        ''|*[!0-9]*) ;;
        *)
            if kill -0 "$JOBS_TERMINAL_STYLE_OWNER" 2>/dev/null &&
               [ "${JOBS_TERMINAL_STYLE_TTY:-}" = "$(tty 2>/dev/null)" ]; then
                return 0
            fi
            ;;
    esac
    JOBS_TERMINAL_STYLE_REEXEC=$jobs_style_bootstrap_script
    export JOBS_TERMINAL_STYLE_REEXEC
    jobs_terminal_style_run /bin/zsh "$jobs_style_bootstrap_script" "$@"
    jobs_style_bootstrap_result=$?
    exit "$jobs_style_bootstrap_result"
}
jobs_terminal_style_bootstrap "$0" "$@"
# <<< Jobs terminal style protection v1 <<<

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
