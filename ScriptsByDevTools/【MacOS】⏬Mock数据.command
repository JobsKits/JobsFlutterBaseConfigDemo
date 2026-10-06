#!/bin/zsh
# 脚本自述：
# - 脚本名称：【MacOS】⏬Mock数据.command
# - 核心用途：Mock数据。
# - 影响范围：Git 工作区、子模块或仓库状态。
# - 运行提示：先阅读自述并按回车确认，按 Ctrl+C 取消。
JOBS_COMMAND_ENTRY_ARG0="$0"
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
# 打印固定自述，确认后才进入原有脚本流程。
show_script_intro_and_wait() {
  printf '%s\n' '【MacOS】⏬Mock数据.command' | jobs_intro_style title
  printf '%s\n' '1、核心用途：Mock数据。' | jobs_intro_style body
  printf '%s\n' '2、影响范围：Git 工作区、子模块或仓库状态。' | jobs_intro_style body
  printf '%s\n' '3、运行策略：确认后执行原有流程；后续危险操作的确认保持原样。' | jobs_intro_style body
  printf '%s\n' '4、取消方式：按 Ctrl+C 终止；确认前不执行真实业务。' | jobs_intro_style body
  if [ ! -t 0 ]; then
    printf '%s\n' '当前没有可交互输入，请在终端中重新运行。' >&2
    exit 1
  fi
  printf '%s' '已了解脚本用途与影响，按回车继续；按 Ctrl+C 取消：'
  IFS= read -r jobs_intro_answer || exit 1
}
# 确认后执行原有业务，保留原来的参数、交互和退出策略。
jobs_run_original_script() {
  0="$JOBS_COMMAND_ENTRY_ARG0"

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
}
# 编排自述确认与原有业务。
main() {
  show_script_intro_and_wait # 展示用途与影响，并等待回车确认。
  jobs_run_original_script "$@" # 继续执行原有脚本流程。
}
main "$@"
