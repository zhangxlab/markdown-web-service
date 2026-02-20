#!/bin/bash
# Markdown Web Service - GitHub 自动部署脚本
# 使用 GitHub CLI 为用户名 cloudinbanana 创建仓库并推送

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  GitHub 自动部署脚本${NC}"
echo -e "${CYAN}  用户: cloudinbanana${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 配置
REPO_NAME="markdown-web-service"
REPO_DESCRIPTION="Markdown 文档 Web 服务，支持四阶段安全部署"
REPO_LICENSE="MIT"
TARGET_DIR="/workspace/markdown-web-service"
GITHUB_USERNAME="zhangxlab"

# 1. 检查目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ 错误: 目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}[1/9] 检查 Git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git 未安装，正在安装...${NC}"
    apt-get update && apt-get install -y git
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

echo -e "${BLUE}[2/9] 检查 GitHub CLI...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI 未安装${NC}"
    echo -e "${CYAN}正在安装 GitHub CLI...${NC}"
    echo ""
    
    # 下载并安装
    wget https://cli.github.com/packages/githubcli-linux-amd64_v2.51.0.tar.gz -O /tmp/gh.tar.gz
    tar -xzf /tmp/gh.tar.gz -C /tmp/gh
    rm /tmp/gh.tar.gz
    sudo cp /tmp/gh/gh /usr/local/bin/
    sudo chmod +x /usr/local/bin/gh
    
    echo -e "${GREEN}✓ GitHub CLI 已安装${NC}"
else
    echo -e "${GREEN}✓ GitHub CLI 已安装${NC}"
    
    # 检查认证状态
    if ! gh auth status &> /dev/null; then
        echo -e "${CYAN}[2.5/9] 需要认证...${NC}"
        echo -e "${YELLOW}请在新终端运行以下命令进行认证：${NC}"
        echo ""
        echo -e "${GREEN}gh auth login${NC}"
        echo ""
        echo -e "${YELLOW}认证完成后，按回车键继续此脚本...${NC}"
        read -p "按回车键继续..."
        
        # 重新检查
        if ! gh auth status &> /dev/null; then
            echo -e "${RED}❌ 认证失败${NC}"
            echo -e "${YELLOW}请检查浏览器是否正常打开并授权${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ 认证成功${NC}"
    fi
fi

# 2. 进入目标目录
echo ""
echo -e "${BLUE}[3/9] 进入项目目录...${NC}"
cd "$TARGET_DIR"
echo -e "${GREEN}✓ 当前目录: $(pwd)${NC}"

# 3. 初始化 Git 仓库
echo ""
echo -e "${BLUE}[4/9] 初始化 Git 仓库...${NC}"
git rev-parse --git-dir > /dev/null 2>&1 || git init
echo -e "${GREEN}✓ Git 仓库已初始化${NC}"

# 4. 添加所有文件
echo ""
echo -e "${BLUE}[5/9] 添加文件到暂存区...${NC}"
git add .
echo -e "${GREEN}✓ 文件已添加${NC}"

# 5. 提交更改
echo ""
echo -e "${BLUE}[6/9] 提交更改...${NC}"
git commit -m "Add Markdown Web Service v1.0

- Complete deployment skill
- One-click installation script
- 4-stage security deployment" || echo -e "${YELLOW}⚠️  没有新的更改需要提交${NC}"

# 6. 创建 GitHub 仓库
echo ""
echo -e "${BLUE}[7/9] 创建 GitHub 仓库...${NC}"
echo -e "${CYAN}仓库名称: $REPO_NAME${NC}"
echo -e "${CYAN}所有者: $GITHUB_USERNAME${NC}"

gh repo create "$REPO_NAME" \
    --public \
    --description "$REPO_DESCRIPTION" \
    --license "$REPO_LICENSE" \
    --source=. \
    --remote

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 仓库创建成功！${NC}"
else
    echo -e "${RED}❌ 仓库创建失败${NC}"
    echo -e "${YELLOW}可能原因: 仓库名已存在或认证失败${NC}"
    exit 1
fi

# 7. 推送代码
echo ""
echo -e "${BLUE}[8/9] 推送代码到 GitHub...${NC}"
git push -u origin main

# 8. 检查推送结果
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
    echo -e "${YELLOW}1. 访问仓库: https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
    echo -e "${YELLOW}2. 克隆到其他机器: git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git${NC}"
    echo -e "${YELLOW}3. 在仓库页面创建 Release (v1.0)${NC}"
    echo ""
    echo -e "${BLUE}其他用户使用方法:${NC}"
    echo -e "${CYAN}git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git${NC}"
    echo -e "${CYAN}cd markdown-web-service${NC}"
    echo -e "${CYAN}chmod +x install.sh${NC}"
    echo -e "${CYAN}./install.sh${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  推送失败！${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}常见错误:${NC}"
    echo -e "${YELLOW}1. 认证失败: gh auth login${NC}"
    echo -e "${YELLOW}2. 仓库名冲突: 请在 GitHub 网页删除同名仓库${NC}"
    echo -e "${YELLOW}3. 网络问题: 请检查网络连接${NC}"
    echo ""
    echo -e "${YELLOW}调试命令:${NC}"
    echo -e "${CYAN}git remote -v${NC}"
    echo -e "${CYAN}git push -v origin main${NC}"
    exit 1
fi
