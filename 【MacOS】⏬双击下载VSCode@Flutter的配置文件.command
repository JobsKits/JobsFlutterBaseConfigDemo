#!/usr/bin/env zsh
# ==============================================================================
# 脚本名称：下载并覆盖 VSCode 配置
# 功能描述：
#   1. 自动定位 Flutter 项目根目录（支持：传参 > 脚本所在目录 > 当前目录，向上递归查找）
#   2. 从远端仓库 https://github.com/JobsKits/VScodeConfigByFlutter 克隆配置
#   3. 覆盖写入到当前项目的 .vscode 文件夹（包含 .git）
#   4. 默认在项目根的 .gitignore 里写入 ".vscode/" 忽略
#
# 环境变量：
#   DRY_RUN=1        # 干跑模式，只打印动作不执行
#   BACKUP=1         # 覆盖前，先把当前 .vscode 备份为 .vscode_backup_YYYYmmddHHMMSS
#   NO_GITIGNORE=1   # 不自动写入 .gitignore
#
# 使用方式：
#   1) 双击脚本（Finder / SourceTree）
#   2) 终端执行：./脚本.command
#   3) 终端指定项目：./脚本.command /path/to/flutter_project
#
# 注意事项：
#   - 脚本会完整复制 .git 目录，因此 .vscode 将作为一个独立仓库使用
#   - 外层仓库不会追踪 .vscode 内容
# ==============================================================================

set -euo pipefail
[[ "${DEBUG:-0}" == "1" ]] && set -x

# ============================== 路径&日志 ==============================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
SCRIPT_BASENAME=$(basename "$0" | sed 's/\.[^.]*$//')
LOG_FILE="/tmp/${SCRIPT_BASENAME}.log"; : > "$LOG_FILE"

log()  { print -r -- "$1" | tee -a "$LOG_FILE" 1>&2; }
info() { log "ℹ️  $*"; }
ok()   { log "✅ $*"; }
warn() { log "⚠️  $*"; }
err()  { log "❌ $*"; }

# 干跑封装：DRY_RUN=1 时只打印动作，不执行
dry_do() { if [[ "${DRY_RUN:-0}" == "1" ]]; then print -r -- "[DRY] $*"; else eval "$@"; fi }

# ============================== 判定/工具函数 ==============================
# 判断是否为 Flutter 根目录（要求同时存在 pubspec.yaml 与 lib/ 目录）
is_flutter_root(){ local d="$1"; [[ -f "$d/pubspec.yaml" && -d "$d/lib" ]]; }

# 规范化路径：去引号 → 展开 ~ → 转绝对路径
normalize_path(){
  local p="$1"; p="${p%\"}"; p="${p#\"}"; p="${p%\'}"; p="${p#\'}"; eval "p=\"$p\""
  [[ -e "$p" ]] && print -r -- "${p:A}" || print -r -- "$p"
}

# 向上递归查找 Flutter 根目录（包含起点）
find_upward(){
  local d="$1"; while [[ -n "$d" && "$d" != "/" ]]; do
    if is_flutter_root "$d"; then REPLY="$d"; return 0; fi; d="${d:h}"
  done; return 1
}

# 交互式读取目录（支持拖拽路径）
read_path_interactive(){
  local p=""; read "?请输入 Flutter 项目根目录（可拖拽）: " p
  [[ -z "$p" ]] && { err "输入为空"; return 1; }
  p="$(normalize_path "$p")"; [[ ! -d "$p" ]] && { err "目录不存在：$p"; return 1; }
  REPLY="$p"
}

# 拷贝工具：完整同步 src → dst（包含 .git）
copy_tree_into(){
  local src="$1" dst="$2"
  mkdir -p "$dst"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/." "$dst/."
  else
    rm -rf "$dst"/*
    cp -R "$src/." "$dst/"
  fi
}

# 确保 .gitignore 里包含 ".vscode/"，避免外层仓库追踪该目录
ensure_gitignore_vscode(){
  local root="$1" gi="$root/.gitignore"
  [[ "${NO_GITIGNORE:-0}" == "1" ]] && return 0
  if [[ -d "$root/.git" ]]; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      print -r -- "[DRY] 确保 .gitignore 含有 .vscode/"
      return 0
    fi
    touch "$gi"
    if ! grep -qxE '\.vscode/?' "$gi"; then
      printf "\n# local VSCode configs\n.vscode/\n" >> "$gi"
      ok "已将 .vscode/ 写入 .gitignore"
    else
      info ".gitignore 已包含 .vscode/（跳过）"
    fi
  else
    info "项目非 git 仓库，跳过写入 .gitignore"
  fi
}

# ============================== 主流程函数 ==============================
# 定位 Flutter 根目录：参数 > 脚本所在目录 > 当前目录；支持向上递归；找不到则循环询问
ensure_flutter_root(){
  local arg="${1:-}"; local cands=()
  [[ -n "$arg" ]] && cands+=("$(normalize_path "$arg")")
  cands+=("$SCRIPT_DIR" "$PWD")
  for base in "${cands[@]}"; do
    [[ -f "$base" ]] && base="$(dirname "$base")"
    if [[ -d "$base" ]] && find_upward "$base"; then return 0; fi
  done
  while true; do
    warn "未找到 Flutter 根（起点：$SCRIPT_DIR / $PWD）。"
    if read_path_interactive; then
      local entered="$REPLY"; if find_upward "$entered"; then return 0; fi
    fi
  done
}

# 拉取远端仓库 → 覆盖写入 .vscode
update_vscode_from_repo(){
  local root="$1"
  local repo_url="https://github.com/JobsKits/VScodeConfigByFlutter"
  local temp_dir; temp_dir="$(mktemp -d)"

  info "克隆仓库：$repo_url"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    print -r -- "[DRY] git clone --depth=1 \"$repo_url\" \"$temp_dir\""
  else
    git clone --depth=1 "$repo_url" "$temp_dir" 1>&2
  fi

  local target="$root/.vscode"

  if [[ "${BACKUP:-0}" == "1" && -d "$target" ]]; then
    local ts; ts="$(date +%Y%m%d%H%M%S)"
    local bk="$root/.vscode_backup_$ts"
    info "备份当前 .vscode → $bk"
    dry_do "cp -R \"$target\" \"$bk\""
  fi

  info "覆盖写入：$target（源=仓库根，包含 .git）"
  copy_tree_into "$temp_dir" "$target"

  dry_do "rm -rf \"$temp_dir\""
  ok ".vscode 已更新完成"
}

# ============================== 主入口 ==============================
main(){
  local start_arg="${1:-}"

  # ① 定位 Flutter 根目录（参数 > 脚本目录 > 当前目录）
  ensure_flutter_root "$start_arg"; local root="$REPLY"
  ok "已确认 Flutter 根目录：$root"

  # ② 切换到项目根目录（确保后续操作相对路径正确）
  dry_do "cd \"$root\""

  # ③ 确保 .gitignore 忽略 .vscode/（除非 NO_GITIGNORE=1）
  ensure_gitignore_vscode "$root"

  # ④ 克隆远端仓库并覆盖写入到项目 .vscode
  update_vscode_from_repo "$root"
}

main "$@"
