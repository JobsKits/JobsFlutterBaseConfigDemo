#!/bin/zsh
# Flutter CI: explicit analysis scope, real regression suites and the complete iOS app.
# Analyze/test require an already-resolved package configuration. Only the GitHub
# runner may invoke ios, which can install CocoaPods dependencies and build outputs.

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

SCRIPT_DIR=''
PROJECT_ROOT=''
LOG_DIR=''

usage() {
    print -r -- 'Usage: /bin/zsh .github/ci/verify.zsh {toolchain|analyze|test|ios}'
    print -r -- 'Logs: JOBS_CI_LOG_DIR, otherwise the system temporary directory.'
    print -r -- 'No dependency installation is performed by toolchain/analyze/test.'
}

initialize() {
    setopt NO_NOMATCH
    SCRIPT_DIR="${${(%):-%x}:A:h}"
    PROJECT_ROOT="${SCRIPT_DIR:h:h}"
    LOG_DIR="${JOBS_CI_LOG_DIR:-${TMPDIR:-/tmp}/jobs-flutter-ci}"
    mkdir -p "$LOG_DIR"
    cd "$PROJECT_ROOT"
    source "$SCRIPT_DIR/【MacOS】PrepareFlutterSdk.zsh/【MacOS】PrepareFlutterSdk.zsh"
    print -r -- "[Flutter CI] Mode: $1; root: $PROJECT_ROOT; logs: $LOG_DIR"
}

require_commands() {
    local required_command
    for required_command in "$@"; do
        command -v "$required_command" >/dev/null || {
            print -u2 -r -- "Missing required command: $required_command"
            return 1
        }
    done
}

run_logged() {
    local log_name="$1"
    shift
    "$@" 2>&1 | tee "$LOG_DIR/$log_name.log"
}

verify_flutter() {
    require_commands flutter dart jq
    local expected_version
    local actual_version
    expected_version="$(jq -er '.flutter' .fvmrc)"
    jobs_ci_capture_version "$(command -v flutter)" "$LOG_DIR/flutter-version.log" "$LOG_DIR/sdk-version.log"
    actual_version="$(jq -er '.frameworkVersion' "$LOG_DIR/flutter-version.log")"
    [[ "$expected_version" == '3.47.7' && "$actual_version" == "$expected_version" ]] || {
        print -u2 -r -- "Flutter mismatch: .fvmrc=$expected_version actual=$actual_version expected=3.47.7"
        return 1
    }
    cat "$LOG_DIR/flutter-version.log"
}

verify_toolchain() {
    verify_flutter
    require_commands xcodebuild xcrun pod
    [[ "$(uname -m)" == arm64 ]] || {
        print -u2 -r -- 'The iOS CI requires the Apple Silicon xcode-27 runner.'
        return 1
    }
    [[ -d "${DEVELOPER_DIR:-}" ]] || {
        print -u2 -r -- 'DEVELOPER_DIR must select an installed Xcode 27.1 or newer.'
        return 1
    }
    local xcode_version
    local simulator_sdk
    xcode_version="$(xcodebuild -version | awk '/^Xcode / {print $2}')"
    simulator_sdk="$(xcrun --sdk iphonesimulator --show-sdk-version)"
    autoload -Uz is-at-least
    is-at-least 27.1 "$xcode_version" && is-at-least 27.1 "$simulator_sdk" || {
        print -u2 -r -- "Insufficient toolchain: Xcode=$xcode_version Simulator SDK=$simulator_sdk; need >=27.1."
        return 1
    }
    {
        print -r -- "DEVELOPER_DIR=$DEVELOPER_DIR"
        xcodebuild -version
        print -r -- "Simulator SDK=$simulator_sdk"
        pod --version
        git rev-parse HEAD
    } | tee "$LOG_DIR/toolchain.log"
}

analyze_scope() {
    verify_flutter
    [[ -f .dart_tool/package_config.json ]] || {
        print -u2 -r -- 'Missing package configuration; resolve pubspec.lock before analysis.'
        return 1
    }
    local analysis_target
    local analysis_count=0
    local analysis_failed=0
    : > "$LOG_DIR/analyze.log"
    while IFS= read -r analysis_target || [[ -n "$analysis_target" ]]; do
        [[ -z "$analysis_target" || "$analysis_target" == \#* ]] && continue
        (( analysis_count += 1 ))
        print -r -- "[Analyze] $analysis_target" | tee -a "$LOG_DIR/analyze.log"
        if [[ ! -e "$analysis_target" ]]; then
            print -r -- "Missing analysis target: $analysis_target" | tee -a "$LOG_DIR/analyze.log"
            analysis_failed=1
        elif dart analyze --fatal-warnings "$analysis_target" >> "$LOG_DIR/analyze.log" 2>&1; then
            print -r -- "[Analyze] passed: $analysis_target"
        else
            print -u2 -r -- "[Analyze] failed: $analysis_target (see analyze.log)"
            analysis_failed=1
        fi
    done < "$SCRIPT_DIR/analyze-scope.txt"
    cat "$LOG_DIR/analyze.log"
    (( analysis_count > 0 && analysis_failed == 0 ))
}

run_regressions() {
    verify_flutter
    run_logged tests flutter test \
        --no-pub \
        --reporter expanded \
        test/iphone_duo_layout_test.dart \
        test/umeng_demo_test.dart
}

verify_simulator_app() {
    require_commands /usr/libexec/PlistBuddy lipo ditto
    local app_path="$PROJECT_ROOT/build/ios/iphonesimulator/Runner.app"
    local app_plist="$app_path/Info.plist"
    local executable
    local platform_name
    local sdk_name
    local bundle_identifier
    [[ -f "$app_plist" ]] || {
        print -u2 -r -- "Missing built application: $app_path"
        return 1
    }
    executable="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app_plist")"
    platform_name="$(/usr/libexec/PlistBuddy -c 'Print :DTPlatformName' "$app_plist")"
    sdk_name="$(/usr/libexec/PlistBuddy -c 'Print :DTSDKName' "$app_plist")"
    bundle_identifier="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_plist")"
    [[ "$executable" == Runner && -x "$app_path/$executable" &&
       "$platform_name" == iphonesimulator &&
       "$sdk_name" == iphonesimulator* &&
       "$bundle_identifier" == com.example.jobsFlutterBaseConfigDemo ]] || {
        print -u2 -r -- "Unexpected app identity: executable=$executable platform=$platform_name SDK=$sdk_name bundle=$bundle_identifier"
        return 1
    }
    autoload -Uz is-at-least
    is-at-least 27.1 "${sdk_name#iphonesimulator}"
    lipo -verify_arch arm64 "$app_path/$executable"
    {
        print -r -- "App=Runner.app BundleID=$bundle_identifier SDK=$sdk_name"
        lipo -archs "$app_path/$executable"
        git rev-parse HEAD
    } | tee "$LOG_DIR/app-verification.log"
    ditto -c -k --sequesterRsrc --keepParent "$app_path" "$LOG_DIR/Runner.app.zip"
}

build_ios() {
    [[ "${GITHUB_ACTIONS:-}" == true ]] || {
        print -u2 -r -- 'ios mode is restricted to GitHub Actions; it may resolve Pods and build the full app.'
        return 1
    }
    verify_toolchain
    jobs_ci_precache_ios "$(command -v flutter)" "$LOG_DIR/sdk-ios-precache.log"
    run_logged ios-build flutter build ios \
        --simulator \
        --debug \
        --no-pub \
        --no-codesign \
        --target lib/main.dart
    verify_simulator_app
}

main() {
    set -euo pipefail
    local ci_mode="${1:-help}"
    case "$ci_mode" in
        toolchain|analyze|test|ios)
            initialize "$ci_mode"
            ;;
        help|--help|-h)
            usage
            return
            ;;
        *)
            usage
            return 2
            ;;
    esac
    case "$ci_mode" in
        toolchain) verify_toolchain ;;
        analyze) analyze_scope ;;
        test) run_regressions ;;
        ios) build_ios ;;
    esac
}

main "$@"
