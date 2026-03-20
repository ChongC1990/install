#!/usr/bin/env bash
# SkillFree 一键安装脚本
# curl -fsSL https://skillfree.tech/install.sh | bash

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
echo -e "  ${DIM}🦞  模型与技能严选平台 — 只选每个场景最好用的那一个${NC}"
echo -e "  ${DIM}    Claude · GPT · Gemini · nano banana · Veo · 合合 OCR${NC}"
echo ""
echo -e "  ${DIM}────────────────────────────────────────────────────${NC}"
echo ""

# ── Step 1: 检查环境 ──────────────────────────────────────────────────────────
step "[ 1 / 3 ]  检查环境"

if ! command -v node &>/dev/null; then
  err "未检测到 Node.js，请先安装：https://nodejs.org（需要 18+）"
fi
NODE_VER=$(node -e "process.stdout.write(process.versions.node.split('.')[0])")
if [ "$NODE_VER" -lt 18 ]; then
  err "Node.js 版本过低（当前 v$(node -v)），需要 18+"
fi
success "Node.js $(node -v)"

if ! command -v npm &>/dev/null; then
  err "未检测到 npm，请检查 Node.js 安装"
fi
success "npm $(npm -v)"

# ── Step 2: 安装 CLI ──────────────────────────────────────────────────────────
step "[ 2 / 3 ]  安装 SkillFree CLI"
echo ""
echo -e "  ${DIM}正在从 npm 安装 skillfree...${NC}"
echo ""

INSTALL_OK=false
if npm install -g skillfree 2>&1 | sed 's/^/    /'; then
  INSTALL_OK=true
else
  echo ""
  warn "权限不足，尝试 sudo..."
  echo ""
  if sudo npm install -g skillfree 2>&1 | sed 's/^/    /'; then
    INSTALL_OK=true
  fi
fi

if [ "$INSTALL_OK" = false ]; then
  err "安装失败，请手动运行：sudo npm install -g skillfree"
fi

echo ""
success "SkillFree CLI 安装完成"

# 刷新 PATH
hash -r 2>/dev/null || true
export PATH="$(npm root -g)/../bin:$PATH"

if ! command -v skillfree &>/dev/null; then
  warn "CLI 已安装，但当前终端 PATH 未更新"
  warn "请新开一个终端窗口，然后运行：skillfree auth login"
  echo ""
  exit 0
fi

# ── Step 3: 登录（从 /dev/tty 读取，兼容 curl | bash）────────────────────────
step "[ 3 / 3 ]  登录账号"
echo ""
echo -e "  还没有账号？${CYAN}https://skillfree.tech/app${NC} 免费注册，注册即送 ¥5"
echo -e "  注册后进入控制台 → ${BOLD}API Keys${NC} → 创建一个 Key，粘贴到下方"
echo ""

API_KEY=""
while true; do
  printf "  请粘贴 API Key (sk-sf-...)，输入 q 跳过: "
  read -r API_KEY </dev/tty

  if [ "$API_KEY" = "q" ] || [ -z "$API_KEY" ]; then
    echo ""
    warn "已跳过登录，稍后可运行 ${CYAN}skillfree auth login${NC} 完成配置"
    API_KEY=""
    break
  fi

  if [[ "$API_KEY" != sk-sf-* ]]; then
    echo -e "  ${RED}✗${NC} 格式不对，Key 应以 sk-sf- 开头，请重试\n"
    continue
  fi

  success "API Key 已保存"
  break
done

if [ -n "$API_KEY" ]; then
  SKILLFREE_API_KEY="$API_KEY" skillfree auth save "$API_KEY"
fi

# ── 完成 ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${DIM}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD_GREEN}  🎉 安装完成！不要先研究命令，直接抄下面这些就能开始：${NC}"
echo ""

echo -e "  ${CYAN}做一个网站：${NC}"
echo -e "  ${DIM}  $ skillfree chat \"帮我做一个极简风 SaaS 官网，包含首页文案、功能区块、价格表、FAQ，并输出完整 HTML + CSS + JS\"${NC}"
echo ""

echo -e "  ${CYAN}写一个短视频脚本：${NC}"
echo -e "  ${DIM}  $ skillfree chat \"帮我写一个 60 秒短视频脚本，主题是 AI 如何帮助中小企业降本增效，要有开场钩子、正文、结尾 CTA\"${NC}"
echo ""

echo -e "  ${CYAN}生成一张官网头图：${NC}"
echo -e "  ${DIM}  $ skillfree pilot --type image --prompt \"科技感蓝紫色 AI 工作台插画，适合官网头图\" --output ./hero.png${NC}"
echo ""

echo -e "  ${CYAN}做一个视频：${NC}"
echo -e "  ${DIM}  $ skillfree pilot --type video --prompt \"一只未来感龙虾在霓虹都市中行走，电影感运镜\" --seconds 8 --size 1920x1080 --output ./video.mp4${NC}"
echo ""

echo -e "  ${CYAN}解析一份合同/文档：${NC}"
echo -e "  ${DIM}  $ skillfree pilot --type ocr --file ./contract.pdf --output ./result.md${NC}"
echo ""

echo -e "  ${DIM}更多命令：${NC}"
echo -e "  ${DIM}  skillfree models      # 查看全部模型和定价${NC}"
echo -e "  ${DIM}  skillfree balance     # 查看账户余额${NC}"
echo -e "  ${DIM}  skillfree auth status # 查看登录状态${NC}"
echo ""
echo -e "  ${DIM}充值地址：${NC}${CYAN}https://skillfree.tech/app/billing${NC}"
echo ""
