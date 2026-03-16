#!/usr/bin/env bash
# SkillFree 一键安装脚本
# curl -fsSL https://cdn.jsdelivr.net/gh/ChongC1990/install@main/install.sh | bash

set -e

# ── 颜色定义 ─────────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
BOLD_CYAN='\033[1;36m'
GREEN='\033[0;32m'
BOLD_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${CYAN}  →${NC} $*"; }
success() { echo -e "${BOLD_GREEN}  ✓${NC} $*"; }
warn()    { echo -e "${YELLOW}  ⚠${NC}  $*"; }
err()     { echo -e "${RED}  ✗${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}$*${NC}"; }

# ── ASCII Banner ──────────────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD_CYAN}"
cat << 'EOF'
  ███████╗██╗  ██╗██╗██╗     ██╗     ███████╗██████╗ ███████╗███████╗
  ██╔════╝██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗██╔════╝██╔════╝
  ███████╗█████╔╝ ██║██║     ██║     █████╗  ██████╔╝█████╗  █████╗
  ╚════██║██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝
  ███████║██║  ██╗██║███████╗███████╗██║     ██║  ██║███████╗███████╗
  ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝
EOF
echo -e "${NC}"
echo -e "  ${DIM}🦞  一个 Key，调用 53+ 顶级 AI 模型${NC}"
echo -e "  ${DIM}    Chat · Image · Video · TTS · Music · OCR · Search${NC}"
echo ""
echo -e "  ${DIM}────────────────────────────────────────────────────${NC}"
echo ""

# ── Step 1: 检查环境 ──────────────────────────────────────────────────────────
step "[ 1 / 3 ]  检查环境"

# 检查 Node.js
if ! command -v node &>/dev/null; then
  err "未检测到 Node.js，请先安装：https://nodejs.org（需要 18+）"
fi
NODE_VER=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
if [ "$NODE_VER" -lt 18 ]; then
  err "Node.js 版本过低（当前 v$(node -v)），需要 18+，请升级后重试"
fi
success "Node.js $(node -v) ✓"

# 检查 npm
if ! command -v npm &>/dev/null; then
  err "未检测到 npm，请检查 Node.js 安装是否完整"
fi
success "npm $(npm -v) ✓"

# ── Step 2: 安装 CLI ──────────────────────────────────────────────────────────
step "[ 2 / 3 ]  安装 SkillFree CLI"
echo ""
echo -e "  ${DIM}正在从 npm 安装 skillfree...${NC}"
echo ""

# 尝试全局安装，失败时提示 sudo
if ! npm install -g skillfree 2>&1 | sed 's/^/    /'; then
  echo ""
  warn "全局安装失败，尝试使用 sudo..."
  if ! sudo npm install -g skillfree 2>&1 | sed 's/^/    /'; then
    err "安装失败，请手动运行：sudo npm install -g skillfree"
  fi
fi

echo ""
success "SkillFree CLI 安装完成"

# 验证 CLI 可用
if ! command -v skillfree &>/dev/null; then
  warn "CLI 已安装但未在 PATH 中，请重启终端后运行 skillfree auth login"
  echo ""
  echo -e "  ${DIM}或手动运行：${NC}"
  echo -e "  ${CYAN}  $(npm root -g)/.bin/skillfree auth login${NC}"
  echo ""
  exit 0
fi

# ── Step 3: 登录 ──────────────────────────────────────────────────────────────
step "[ 3 / 3 ]  登录账号"
echo ""
echo -e "  ${DIM}即将打开登录流程，请按提示操作${NC}"
echo -e "  ${DIM}没有账号？前往注册：${CYAN}https://skillfree.tech${NC}"
echo ""

# 调用 CLI 的 auth login 命令
skillfree auth login

# ── 完成 ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${DIM}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD_GREEN}  🎉 全部搞定！开始召唤龙虾吧${NC}"
echo ""
echo -e "  ${BOLD}快速体验：${NC}"
echo -e "  ${CYAN}  $ skillfree pilot --type chat --prompt \"你好\"${NC}"
echo -e "  ${CYAN}  $ skillfree pilot --type image --prompt \"赛博朋克的上海\" --output ./img.png${NC}"
echo -e "  ${CYAN}  $ skillfree pilot --type search --prompt \"今天的 AI 新闻\"${NC}"
echo ""
echo -e "  ${BOLD}其他命令：${NC}"
echo -e "  ${DIM}  skillfree models          # 查看所有模型${NC}"
echo -e "  ${DIM}  skillfree credits         # 查看积分余额${NC}"
echo -e "  ${DIM}  skillfree --help          # 查看帮助${NC}"
echo ""
echo -e "  ${DIM}充值积分：${NC}${CYAN}https://skillfree.tech/app/topup${NC}"
echo -e "  ${DIM}完整文档：${NC}${CYAN}https://skillfree.tech/docs${NC}"
echo ""
