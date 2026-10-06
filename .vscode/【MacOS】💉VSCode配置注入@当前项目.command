#!/bin/zsh

# 仅渲染自述：标题红色加粗，编号正文蓝色常规字重；非彩色终端输出纯文本。
jobs_intro_style() {
  local intro_color=0
  if [ -t 1 ] && [ -n "${TERM:-}" ] && [ "${TERM:-}" != dumb ] &&
     [ -z "${NO_COLOR+x}" ] && [ "${PLAIN_OUTPUT:-0}" != 1 ] &&
     [ "${IS_SOURCETREE_RUNTIME:-0}" != 1 ]; then
    intro_color=1
  fi
  /usr/bin/awk -v color="$intro_color" -v role="${1:-body}" '
    BEGIN { esc = sprintf("%c", 27) }
    {
      gsub(esc "\\[[0-9;]*m", "")
      gsub(/\\(033|e|x1[bB])\[[0-9;]*m/, "")
      if (!color || $0 ~ /^[[:space:]]*$/) { print; next }
      numbered = ($0 ~ /^[[:space:]➤ℹ🔹✔⚠]*([0-9]+[、.)）]|[0-9]+️⃣|[-•])/)
      heading = ($0 ~ /^[[:space:]]*#{1,6}[[:space:]]/ || $0 ~ /[：:][[:space:]]*$/ || $0 ~ /^[[:space:]]*[=━─-]{3}/)
      title = (!numbered && (role == "title" || heading))
      if (role == "auto" && !seen && !numbered) title = 1
      if ($0 !~ /^[[:space:]]*[=━─-]+[[:space:]]*$/) seen = 1
      printf "%s%s%s\n", esc (title ? "[1;31m" : "[0;34m"), $0, esc "[0m"
    }
  '
}
main() {
  set -euo pipefail

  local REPO_URL="https://github.com/JobsKits/VScodeConfigByFlutter.git"
  local SCRIPT_DIR
  local TARGET_DIR
  local TMP_DIR

  # ✅ 定位到脚本当前目录（不是终端 pwd，不是桌面）
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
  cd "$SCRIPT_DIR" || {
    echo "❌ 无法进入脚本目录：$SCRIPT_DIR"
    exit 1
  }

  TARGET_DIR="$SCRIPT_DIR/.vscode"

  echo "==================================================" | jobs_intro_style title
  echo "即将执行以下操作：" | jobs_intro_style title
  echo "1. 删除脚本所在目录下的 VS Code 工程配置目录：$TARGET_DIR" | jobs_intro_style body
  echo "2. 从 GitHub 下载配置仓库：$REPO_URL" | jobs_intro_style body
  echo "3. 将仓库中的配置文件写入脚本所在目录的 .vscode/" | jobs_intro_style body
  echo | jobs_intro_style body
  echo "警告：这是破坏性操作，脚本所在目录下已有的 .vscode 配置会被整个替换。" | jobs_intro_style body
  echo "如果你还没备份，现在按 Ctrl+C 取消。" | jobs_intro_style body
  echo "确认继续的话，请按回车。" | jobs_intro_style body
  echo "==================================================" | jobs_intro_style title
  read -r

  if ! command -v git >/dev/null 2>&1; then
    echo "错误：当前系统没有安装 git，脚本无法继续。"
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  echo
  echo "[1/4] 删除旧的 .vscode 目录..."
  rm -rf "$TARGET_DIR"

  echo "[2/4] 重新创建目标目录..."
  mkdir -p "$TARGET_DIR"

  echo "[3/4] 下载仓库..."
  git clone --depth=1 "$REPO_URL" "$TMP_DIR/repo"

  echo "[4/4] 复制配置到脚本所在目录的 .vscode 目录..."
  cp -R "$TMP_DIR/repo/"* "$TARGET_DIR/" 2>/dev/null || true
  cp -R "$TMP_DIR/repo/".* "$TARGET_DIR/" 2>/dev/null || true

  rm -rf \
    "$TARGET_DIR/.git" \
    "$TARGET_DIR/.github" \
    "$TARGET_DIR/.gitignore"

  echo
  echo "完成。"
  echo "当前工程的 VS Code 配置已替换到："
  echo "$TARGET_DIR"
}

main "$@"
