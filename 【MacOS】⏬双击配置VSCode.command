#!/bin/zsh
set -euo pipefail

# ================================== 基础信息 ==================================
SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
cd "$SCRIPT_DIR" || {
  echo "❌ 无法进入脚本目录：$SCRIPT_DIR"
  exit 1
}

SCRIPT_BASENAME="$(basename "${(%):-%x}" | sed 's/\.[^.]*$//')"
LOG_FILE="$SCRIPT_DIR/${SCRIPT_BASENAME}.log"

PROJECT_REPO_URL="https://github.com/JobsKits/VSCodeConfigByFlutter.git"
GLOBAL_REPO_URL="https://github.com/JobsKits/JobsConfigByVSCode.git"

PROJECT_VSCODE_DIR="$SCRIPT_DIR/.vscode"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
VSCODE_PARENT_DIR="$HOME/Library/Application Support/Code"

# ================================== 统一输出 ==================================
log()           { echo -e "$1" | tee -a "$LOG_FILE"; }
info_echo()     { log "\033[1;34mℹ $1\033[0m"; }
success_echo()  { log "\033[1;32m✔ $1\033[0m"; }
warn_echo()     { log "\033[1;33m⚠ $1\033[0m"; }
error_echo()    { log "\033[1;31m✖ $1\033[0m"; }
note_echo()     { log "\033[1;36m➜ $1\033[0m"; }

pause_enter() {
  echo -n $'\n'"按回车继续..."$'\n' | tee -a "$LOG_FILE"
  IFS= read -r _
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error_echo "缺少命令：$cmd"
    exit 1
  fi
}

# ================================== 工具函数 ==================================
dir_has_content() {
  local dir="$1"
  [[ -d "$dir" ]] || return 1
  [[ -n "$(find "$dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null || true)" ]]
}

backup_dir_to_zip_and_remove() {
  local source_dir="$1"
  local backup_prefix="$2"

  [[ -d "$source_dir" ]] || return 0
  dir_has_content "$source_dir" || return 0

  local ts
  ts="$(date +"%Y%m%d-%H%M%S")"

  local parent_dir
  parent_dir="$(dirname "$source_dir")"

  local backup_dir="${parent_dir}/${backup_prefix}_${ts}"
  local zip_path="${parent_dir}/${backup_prefix}_${ts}.zip"

  warn_echo "检测到已有目录且非空：$source_dir"
  info_echo "开始备份到：$zip_path"

  mv "$source_dir" "$backup_dir"

  if ditto -c -k --sequesterRsrc --keepParent "$backup_dir" "$zip_path"; then
    success_echo "备份完成：$zip_path"
    rm -rf "$backup_dir"
    success_echo "旧目录已移除：$source_dir"
  else
    error_echo "压缩备份失败：$zip_path"
    warn_echo "已保留备份目录：$backup_dir"
    exit 1
  fi
}

copy_repo_contents() {
  local repo_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"

  (
    setopt local_options dot_glob null_glob
    cp -R "$repo_dir"/* "$target_dir"/
  )

  rm -rf \
    "$target_dir/.git" \
    "$target_dir/.github" \
    "$target_dir/.gitignore"
}

replace_dir_with_repo() {
  local repo_url="$1"
  local target_dir="$2"
  local backup_prefix="$3"

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  {
    backup_dir_to_zip_and_remove "$target_dir" "$backup_prefix"

    info_echo "下载仓库：$repo_url"
    git clone --depth=1 "$repo_url" "$tmp_dir/repo"
    success_echo "仓库下载完成"

    rm -rf "$target_dir"
    mkdir -p "$target_dir"

    info_echo "写入目标目录：$target_dir"
    copy_repo_contents "$tmp_dir/repo" "$target_dir"
    success_echo "替换完成：$target_dir"
  } always {
    rm -rf "$tmp_dir"
  }
}

wait_for_vscode_user_parent() {
  local url="https://code.visualstudio.com/"

  while [[ ! -d "$VSCODE_PARENT_DIR" ]]; do
    warn_echo "未检测到 VS Code 目录：$VSCODE_PARENT_DIR"
    note_echo "将打开 VS Code 官网。请先安装 VS Code，安装完成后回到这里按回车继续检测。"
    open "$url" >/dev/null 2>&1 || true
    pause_enter
  done

  success_echo "已检测到 VS Code 目录：$VSCODE_PARENT_DIR"
}

print_readme() {
  clear
  cat <<EOF | tee -a "$LOG_FILE"
==================== VSCode 配置初始化脚本 ====================

将执行以下操作：

1) 处理脚本所在目录的 .vscode
   - 若 .vscode 已存在且非空：先压缩备份
   - 再用仓库内容完整替换：
     $PROJECT_REPO_URL

2) 处理 VS Code 全局 User 目录
   - 目标目录：
     $VSCODE_USER_DIR
   - 若 User 已存在且非空：先压缩备份
   - 再用仓库内容完整替换：
     $GLOBAL_REPO_URL

注意：
- 这是破坏性替换，不是增量合并
- 不会打开 VS Code
- 不会重启 VS Code
- 日志文件：
  $LOG_FILE

==============================================================
EOF
}

setup_project_vscode() {
  info_echo "开始配置项目 .vscode"
  replace_dir_with_repo "$PROJECT_REPO_URL" "$PROJECT_VSCODE_DIR" ".vscode_backup"
}

setup_global_vscode_user() {
  info_echo "开始配置 VS Code 全局 User"
  wait_for_vscode_user_parent
  replace_dir_with_repo "$GLOBAL_REPO_URL" "$VSCODE_USER_DIR" "Code_User_backup"
}

main() {
  : > "$LOG_FILE"

  require_cmd git
  require_cmd ditto

  print_readme
  pause_enter

  setup_project_vscode
  setup_global_vscode_user

  success_echo "全部完成 ✅"
  note_echo "项目配置目录：$PROJECT_VSCODE_DIR"
  note_echo "全局配置目录：$VSCODE_USER_DIR"
  note_echo "日志文件：$LOG_FILE"

  pause_enter
}

main "$@"
