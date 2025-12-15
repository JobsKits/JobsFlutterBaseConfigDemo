#!/bin/zsh
set -euo pipefail

# ================================== 基础信息 ==================================
get_script_path() {
  # zsh 下拿脚本真实路径（Finder 双击时 $0 可能不可靠）
  local p="${(%):-%x}"
  [[ -z "$p" ]] && p="$0"
  echo "${p:A}"
}

SCRIPT_PATH="$(get_script_path)"
SCRIPT_DIR="${SCRIPT_PATH:h}"
SCRIPT_BASENAME="$(basename "$SCRIPT_PATH" | sed 's/\.[^.]*$//')"
LOG_FILE="/tmp/${SCRIPT_BASENAME}.log"

# ================================== 日志与语义输出 ==================================
log()            { echo -e "$1" | tee -a "$LOG_FILE"; }
color_echo()     { log "\033[1;32m$1\033[0m"; }
info_echo()      { log "\033[1;34mℹ $1\033[0m"; }
success_echo()   { log "\033[1;32m✔ $1\033[0m"; }
warn_echo()      { log "\033[1;33m⚠ $1\033[0m"; }
warm_echo()      { log "\033[1;33m$1\033[0m"; }
note_echo()      { log "\033[1;36m✦ $1\033[0m"; }
error_echo()     { log "\033[1;31m✘ $1\033[0m"; }
err_echo()       { error_echo "$1"; }
debug_echo()     { log "\033[0;90m🐞 $1\033[0m"; }
highlight_echo() { log "\033[1;35m★ $1\033[0m"; }
gray_echo()      { log "\033[0;90m$1\033[0m"; }
bold_echo()      { log "\033[1m$1\033[0m"; }
underline_echo() { log "\033[4m$1\033[0m"; }

ts() { date +"%Y%m%d_%H%M%S"; }

# ================================== Flutter 项目根目录判断（按你给的规则） ==================================
is_flutter_project_root() {
  [[ -f "$1/pubspec.yaml" && -d "$1/lib" ]]
}

# ================================== 从某个目录向上找 Flutter 项目根目录 ==================================
find_root_from() {
  local start="${1:A}"
  [[ ! -d "$start" ]] && return 1

  local d="$start"
  while [[ "$d" != "/" ]]; do
    if is_flutter_project_root "$d"; then
      echo "$d"
      return 0
    fi
    d="${d:h}"
  done
  return 1
}

# ================================== 解析用户传参（过滤 Finder 的 -psn_0_xxx） ==================================
pick_user_path_arg() {
  local a
  for a in "$@"; do
    [[ "$a" == -psn_* ]] && continue
    # 如果传的是文件路径，就取其目录；目录就直接用
    if [[ -d "$a" ]]; then
      echo "$a"
      return 0
    elif [[ -f "$a" ]]; then
      echo "${a:A:h}"
      return 0
    fi
  done
  return 1
}

# ================================== 定位项目根目录（优先：传参 > 当前目录 > 脚本目录） ==================================
resolve_flutter_project_root() {
  local candidate root

  if candidate="$(pick_user_path_arg "$@" 2>/dev/null)"; then
    root="$(find_root_from "$candidate" 2>/dev/null || true)"
    [[ -n "$root" ]] && { echo "$root"; return 0; }
  fi

  root="$(find_root_from "$PWD" 2>/dev/null || true)"
  [[ -n "$root" ]] && { echo "$root"; return 0; }

  root="$(find_root_from "$SCRIPT_DIR" 2>/dev/null || true)"
  [[ -n "$root" ]] && { echo "$root"; return 0; }

  return 1
}

# ================================== 依赖检测：Homebrew / fvm ==================================
ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    error_echo "❌ 未检测到 Homebrew（brew）。请先安装 Homebrew 再运行此脚本。"
    gray_echo "   https://brew.sh/"
    exit 1
  fi
  success_echo "Homebrew 已存在：$(command -v brew)"
}

ensure_fvm() {
  if command -v fvm >/dev/null 2>&1; then
    success_echo "fvm 已安装：$(command -v fvm)"
    return 0
  fi

  warn_echo "未检测到 fvm，开始安装（brew install fvm）..."
  brew install fvm
  success_echo "fvm 安装完成：$(command -v fvm)"
}

# ================================== 配置项目级 FVM（只在项目根目录生效） ==================================
setup_fvm_for_project() {
  local project_root="$1"
  cd "$project_root"

  info_echo "项目根目录：$project_root"
  info_echo "开始配置项目级 FVM（写入 $project_root/.fvm）"

  # 你可以把 stable 换成你想固定的版本号，比如 3.24.5
  local channel_or_version="stable"

  fvm install "$channel_or_version"
  fvm use "$channel_or_version"

  success_echo "FVM 已绑定到项目：$channel_or_version"
  gray_echo "当前项目 Flutter：$(fvm flutter --version | head -n 1 || true)"
}

# ================================== 写入项目级 VSCode 设置，让 VSCode 跟随 .fvm/flutter_sdk ==================================
ensure_vscode_settings() {
  local project_root="$1"
  local vscode_dir="$project_root/.vscode"
  local settings="$vscode_dir/settings.json"

  mkdir -p "$vscode_dir"

  if [[ -f "$settings" ]]; then
    cp "$settings" "${settings}.bak.$(ts)"
    warn_echo "已备份：${settings}.bak.$(ts)"
  fi

  # 用 python 合并/写入，尽量保留其他设置
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import json, os
p = "${settings}"
data = {}
if os.path.exists(p):
    try:
        with open(p, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}
data["dart.flutterSdkPath"] = ".fvm/flutter_sdk"
with open(p, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PY
  else
    cat > "$settings" <<'JSON'
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
JSON
  fi

  success_echo "已写入 VSCode 配置：$settings"
  gray_echo "dart.flutterSdkPath -> .fvm/flutter_sdk"
}

# ================================== 入口 ==================================
main() {
  : > "$LOG_FILE"
  bold_echo "==================== Flutter 项目必要配置（项目级 FVM + VSCode）===================="
  gray_echo "LOG_FILE: $LOG_FILE"
  gray_echo "SCRIPT: $SCRIPT_PATH"
  gray_echo "CWD:    $PWD"

  local project_root
  project_root="$(resolve_flutter_project_root "$@")" || {
    error_echo "❌ 未检测到 Flutter 项目根目录（需要同时存在：pubspec.yaml + lib/）"
    note_echo "👉 解决方式："
    gray_echo "   1) 请在 Flutter 项目根目录运行脚本；或"
    gray_echo "   2) 传入项目路径："
    gray_echo "      ./${SCRIPT_BASENAME}.command /path/to/flutter_project"
    exit 1
  }

  ensure_homebrew
  ensure_fvm
  setup_fvm_for_project "$project_root"
  ensure_vscode_settings "$project_root"

  success_echo "✅ 全部完成。建议重启 VS Code 或执行：Developer: Reload Window"
}

main "$@"
