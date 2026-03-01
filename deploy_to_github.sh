#!/bin/bash
# Markdown Web Service - GitHub 部署脚本
# 
# 说明：此脚本会引导你完成 GitHub CLI 安装、认证和推送
# 作者: Monke 小助手 🐒

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Markdown Web Service${NC}"
echo -e "${CYAN}  GitHub 部署脚本${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 配置
REPO_NAME="markdown-web-service"
REPO_DESCRIPTION="Markdown 文档 Web 服务，支持四阶段安全部署"
REPO_LICENSE="MIT"
TARGET_DIR="/Users/zhangxiang/markdown-web-service"
GITHUB_USERNAME="zhangxlab"  # 请修改为你的 GitHub 用户名

# 检查目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ 错误: 目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}[1/7] 检查环境...${NC}"

# 1. 检查 Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ 错误: Git 未安装${NC}"
    echo -e "${YELLOW}请先安装 Git:${NC}"
    echo -e "${CYAN}Ubuntu/Debian: sudo apt install -y git${NC}"
    echo -e "${CYAN}CentOS/RHEL: sudo yum install -y git${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

# 2. 检查 GitHub CLI
HAS_GH_CLI=false
if command -v gh &> /dev/null; then
    HAS_GH_CLI=true
    echo -e "${GREEN}✓ GitHub CLI (gh) 已安装${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) 未安装${NC}"
    echo -e "${YELLOW}将使用 Git 命令行操作${NC}"
fi

echo ""

# 3. 进入目标目录
echo -e "${BLUE}[2/7] 进入项目目录...${NC}"
cd "$TARGET_DIR"
echo -e "${GREEN}✓ 当前目录: $(pwd)${NC}"

# 4. 初始化 Git 仓库
echo ""
echo -e "${BLUE}[3/7] 初始化 Git 仓库...${NC}"
git rev-parse --git-dir > /dev/null 2>&1 || git init
echo -e "${GREEN}✓ Git 仓库已初始化${NC}"

# 5. 添加所有文件
echo ""
echo -e "${BLUE}[4/7] 添加文件到暂存区...${NC}"
git add .
echo -e "${GREEN}✓ 文件已添加${NC}"

# 6. 提交更改
echo ""
echo -e "${BLUE}[5/7] 提交更改...${NC}"
git commit -m "Add Markdown Web Service v1.0

- Complete deployment skill
- One-click installation
- 4-stage security deployment" || echo -e "${YELLOW}⚠️ 没有新的更改需要提交${NC}"

# 7. 创建 GitHub 仓库（如果使用 gh）
echo ""
if [ "$HAS_GH_CLI" = true ]; then
    echo -e "${BLUE}[6/7] 使用 GitHub CLI 创建仓库...${NC}"
    echo -e "${YELLOW}⚠️  如果尚未认证，将打开浏览器进行授权${NC}"
    echo ""
    
    gh auth status
    AUTH_STATUS=$?
    
    if [ $AUTH_STATUS -ne 0 ]; then
        echo ""
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}  请先登录 GitHub CLI:${NC}"
        echo -e "${RED}========================================${NC}"
        echo ""
        echo -e "${CYAN}在另一个终端窗口运行以下命令：${NC}"
        echo -e "${GREEN}gh auth login${NC}"
        echo ""
        echo -e "${YELLOW}登录完成后，按回车键继续此脚本...${NC}"
        echo ""
        read -p "按回车键继续..."
        
        # 重新检查认证状态
        gh auth status
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ GitHub CLI 认证失败${NC}"
            echo -e "${YELLOW}请检查认证状态后重试${NC}"
            exit 1
        fi
    fi
    
    # 创建仓库
    echo -e "${BLUE}正在创建仓库: $REPO_NAME...${NC}"
    gh repo create "$REPO_NAME" \
        --public \
        --description "$REPO_DESCRIPTION" \
        --license "$REPO_LICENSE"
        
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 仓库创建成功！${NC}"
    else
        echo -e "${RED}❌ 仓库创建失败${NC}"
        echo -e "${YELLOW}可能原因: 仓库名已存在${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}[6/7] ${YELLOW}跳过 GitHub CLI（未安装）${NC}"
    echo -e "${YELLOW}请手动在 GitHub 上创建仓库: $REPO_NAME${NC}"
    echo -e "${CYAN}创建地址: https://github.com/new${NC}"
    echo ""
    read -p "按回车键确认已创建仓库..."
fi

# 8. 添加远程仓库并推送
echo ""
echo -e "${BLUE}[7/7] 添加远程仓库并推送...${NC}"
echo -e "${YELLOW}注意: 如果未配置 SSH 或凭据助手，可能会提示输入用户名和密码${NC}"
echo ""

# 构建 Git 远程 URL（需要替换 YOUR_USERNAME）
REMOTE_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# 检查远程是否已存在
if git remote get-url origin &> /dev/null; then
    echo -e "${YELLOW}检测到已存在的远程 origin，正在更新...${NC}"
    git remote set-url origin "$REMOTE_URL"
else
    echo -e "${BLUE}添加远程仓库 origin...${NC}"
    git remote add origin "$REMOTE_URL"
fi

echo ""
echo -e "${GREEN}远程仓库: $REMOTE_URL${NC}"
echo ""

# 推送代码
echo -e "${BLUE}正在推送代码到 GitHub...${NC}"
git push -u origin main

# 检查推送结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  推送成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}你的仓库地址:${NC}"
    echo -e "${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
    echo ""
    echo -e "${YELLOW}下一步操作:${NC}"
    echo -e "${YELLOW}1. 在 GitHub 仓库页面创建 Release（可选）${NC}"
    echo -e "${YELLOW}2. 克隆仓库到其他机器: git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git${NC}"
    echo -e "${YELLOW}3. 运行 ./install.sh 一键安装服务${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  推送失败！${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}常见错误:${NC}"
    echo -e "${YELLOW}1. 认证失败: 请检查 GitHub 用户名/密码或 SSH 密钥${NC}"
    echo -e "${YELLOW}2. 网络问题: 请检查网络连接${NC}"
    echo -e "${YELLOW}3. 仓库名冲突: 仓库名可能已存在${NC}"
    echo -e "${YELLOW}4. 权限问题: 请检查 SSH 密钥配置${NC}"
    echo ""
    echo -e "${YELLOW}调试命令:${NC}"
    echo -e "${CYAN}git remote -v${NC}"
    echo -e "${CYAN}git push -v origin main${NC}"
    exit 1
fi
