#!/bin/zsh
# Flutter CI: explicit analysis scope, real regression suites and the complete iOS app.
# Analyze/test require an already-resolved package configuration. Only the GitHub
# runner may invoke ios, which can install CocoaPods dependencies and build outputs.

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
    flutter --version --machine > "$LOG_DIR/flutter-version.log"
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
