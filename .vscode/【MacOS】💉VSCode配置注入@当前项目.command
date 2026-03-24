#!/bin/zsh

main() {
  set -euo pipefail

  local REPO_URL="https://github.com/JobsKits/VScodeConfigByFlutter.git"
  local CURRENT_DIR
  local TARGET_DIR
  local TMP_DIR
  local APP_NAME="Visual Studio Code"

  CURRENT_DIR="$(pwd)"
  TARGET_DIR="$CURRENT_DIR/.vscode"

  echo "=================================================="
  echo "即将执行以下操作："
  echo "1. 删除当前目录下的 VS Code 工程配置目录：$TARGET_DIR"
  echo "2. 从 GitHub 下载配置仓库：$REPO_URL"
  echo "3. 将仓库中的配置文件写入当前目录的 .vscode/"
  echo "4. 打开当前目录"
  echo "5. 重启 VS Code"
  echo
  echo "警告：这是破坏性操作，当前目录下已有的 .vscode 配置会被整个替换。"
  echo "如果你还没备份，现在按 Ctrl+C 取消。"
  echo "确认继续的话，请按回车。"
  echo "=================================================="
  read -r

  if ! command -v git >/dev/null 2>&1; then
    echo "错误：当前系统没有安装 git，脚本无法继续。"
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"

  echo
  echo "[1/6] 删除旧的 .vscode 目录..."
  rm -rf "$TARGET_DIR"

  echo "[2/6] 重新创建目标目录..."
  mkdir -p "$TARGET_DIR"

  echo "[3/6] 下载仓库..."
  git clone --depth=1 "$REPO_URL" "$TMP_DIR/repo"

  echo "[4/6] 复制配置到当前工程的 .vscode 目录..."
  cp -R "$TMP_DIR/repo/"* "$TARGET_DIR/" 2>/dev/null || true
  cp -R "$TMP_DIR/repo/".* "$TARGET_DIR/" 2>/dev/null || true

  rm -rf \
    "$TARGET_DIR/.git" \
    "$TARGET_DIR/.github" \
    "$TARGET_DIR/.gitignore"

  echo "[5/6] 打开当前目录..."
  open "$CURRENT_DIR"

  echo "[6/6] 重启 VS Code..."
  osascript -e 'tell application "Visual Studio Code" to quit' >/dev/null 2>&1 || true
  sleep 1
  pkill -x "Code" >/dev/null 2>&1 || true
  pkill -f "Visual Studio Code" >/dev/null 2>&1 || true
  sleep 1
  open -a "$APP_NAME" "$CURRENT_DIR"

  echo
  echo "完成。"
  echo "当前工程的 VS Code 配置已替换到："
  echo "$TARGET_DIR"

  rm -rf "$TMP_DIR"
}

main "$@"