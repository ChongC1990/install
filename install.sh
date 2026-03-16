#!/usr/bin/env bash
# SkillFree 一键安装脚本
# curl -fsSL https://cdn.jsdelivr.net/gh/ChongC1990/install@main/install.sh | bash

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
echo -e "  还没有账号？${CYAN}https://skillfree.tech/app${NC} 免费注册"
echo -e "  注册后进入控制台 → ${BOLD}API Keys${NC} → 创建一个 Key，粘贴到下方"
echo ""

API_KEY=""
while true; do
  # 强制从 /dev/tty 读取，避免 curl | bash 时 stdin 被占用
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

  # 验证 Key
  printf "  验证中..."
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $API_KEY" \
    "https://skillfree.tech/v1/balance")

  if [ "$HTTP_CODE" = "200" ]; then
    echo -e " ${GREEN}✓${NC}"
    break
  else
    echo -e " ${RED}✗${NC} (HTTP $HTTP_CODE)"
    echo -e "  ${RED}✗${NC} Key 无效，请检查后重试\n"
    API_KEY=""
  fi
done

# 有效 Key → 交给 CLI 写入配置
if [ -n "$API_KEY" ]; then
  SKILLFREE_API_KEY="$API_KEY" skillfree auth save "$API_KEY"
fi

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
echo -e "  ${DIM}  skillfree models     # 查看所有模型${NC}"
echo -e "  ${DIM}  skillfree credits    # 查看积分余额${NC}"
echo ""
echo -e "  ${DIM}充值积分：${NC}${CYAN}https://skillfree.tech/app/topup${NC}"
echo ""
