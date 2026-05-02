#!/bin/zsh

set -e

REPO_URL="https://github.com/JobsKits/JobsMockData.git"
REPO_NAME="JobsMockData"

# 脚本当前目录（不是终端执行目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

TARGET_DIR="${SCRIPT_DIR}/${REPO_NAME}"

echo "脚本目录: $SCRIPT_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ 未检测到 git，请先安装 git"
  exit 1
fi

if [[ -d "$TARGET_DIR/.git" || -f "$TARGET_DIR/.git" ]]; then
  echo "⚠️ 仓库已存在，开始更新: $TARGET_DIR"
  git -C "$TARGET_DIR" pull --rebase
elif [[ -e "$TARGET_DIR" ]]; then
  echo "❌ 目标路径已存在，但不是 git 仓库: $TARGET_DIR"
  exit 1
else
  echo "🚀 开始克隆到: $SCRIPT_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

echo "✅ 完成"
