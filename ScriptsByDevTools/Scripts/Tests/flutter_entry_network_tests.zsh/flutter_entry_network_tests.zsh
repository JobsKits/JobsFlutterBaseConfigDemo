#!/bin/zsh
# 脚本自述：只提取旧入口的SDK薄适配块，在中文空格临时包验证定位与退出码；不执行原业务。
setopt NO_NOMATCH
SCRIPTS_ROOT="$(CDPATH= cd -P -- "$(dirname -- "$0")/../.." && pwd)"
ENTRY_ROOT="${SCRIPTS_ROOT:h}"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp/}JobsFlutterEntries.XXXXXXXX")" || exit 1
TEST_COUNT=0
TEST_FAILURES=0
TRAPEXIT() { [[ -d "$TEST_ROOT" && "${TEST_ROOT:t}" == JobsFlutterEntries.* ]] && /bin/rm -r -- "$TEST_ROOT"; }
# 每项保留入口文件名和解释器，所有SDK及下载层明确替换。
verify_entry() {
  local entry="$1" target="$TEST_ROOT/中文 空格/$TEST_COUNT" interpreter='' result=0
  /bin/mkdir -p "$target/Scripts/【MacOS】FlutterSDK命令适配.sh" "$target/Scripts/【MacOS】FlutterSDK网络选路.zsh" "$target/sdk/bin" "$target/project"
  /bin/cp "$SCRIPTS_ROOT/【MacOS】FlutterSDK命令适配.sh/【MacOS】FlutterSDK命令适配.sh" "$target/Scripts/【MacOS】FlutterSDK命令适配.sh/"
  export TEST_TRACE="$target/calls" TEST_TARGET="$target" FAKE_FLUTTER="$target/sdk/bin/flutter"
  : > "$TEST_TRACE"
  /bin/cat > "$target/Scripts/【MacOS】FlutterSDK网络选路.zsh/【MacOS】FlutterSDK网络选路.zsh" <<'NETWORK'
#!/bin/zsh
if [[ "$1" == --cache-dir ]]; then /bin/mkdir -p "$TEST_TARGET/cache"; /bin/chmod 700 "$TEST_TARGET/cache"; print -r -- "$TEST_TARGET/cache"; exit 0; fi
print -r -- "$1" >> "$TEST_TRACE"
shift 5
"$@"
NETWORK
  /bin/cat > "$FAKE_FLUTTER" <<'FLUTTER'
#!/bin/zsh
print -r -- "flutter|${(j:|:)@}" >> "$TEST_TRACE"
[[ "$1" == --version ]] && exit 0
exit 7
FLUTTER
  /bin/chmod +x "$FAKE_FLUTTER"
  interpreter="$(/usr/bin/head -n1 "$entry")"
  print -r -- "$interpreter" > "$target/${entry:t}"
  /usr/bin/awk '/^# JOBS_FLUTTER_NETWORK_ADAPTER_BEGIN$/{show=1} show{print} /^# JOBS_FLUTTER_NETWORK_ADAPTER_END$/{exit}' "$entry" >> "$target/${entry:t}"
  /bin/cat >> "$target/${entry:t}" <<'ENTRY'
cd "$TEST_TARGET/project" || exit 1
jobs_flutter_sdk_command "$FAKE_FLUTTER" build 'space arg'
ENTRY
  interpreter="${interpreter#\#!}"
  interpreter="$(print -r -- "$interpreter" | /usr/bin/sed 's/^[[:space:]]*//')"
  "$interpreter" "$target/${entry:t}" || result=$?
  [[ "$result" == 7 ]] && [[ "$(/usr/bin/grep -Fxc 'flutter|--version' "$TEST_TRACE")" == 1 ]] &&
    [[ "$(/usr/bin/grep -Fxc 'flutter|build|space arg' "$TEST_TRACE")" == 1 ]] &&
    /usr/bin/grep -Fxq -- --run "$TEST_TRACE" && /usr/bin/grep -Fxq -- --once "$TEST_TRACE"
}
main() {
  local entry=''
  for entry in "$ENTRY_ROOT"/*.command(N); do
    /usr/bin/grep -q '^# JOBS_FLUTTER_NETWORK_ADAPTER_BEGIN$' "$entry" || continue
    (( TEST_COUNT++ ))
    if (verify_entry "$entry"); then print -r -- "PASS ${entry:t}"; else (( TEST_FAILURES++ )); print -u2 -r -- "FAIL ${entry:t}"; fi
  done
  print -r -- "结果：${TEST_COUNT}个入口，失败${TEST_FAILURES}。"
  (( TEST_COUNT > 0 && TEST_FAILURES == 0 ))
}
main "$@"
