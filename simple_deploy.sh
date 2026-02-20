#!/bin/bash
# Markdown Web Service - Git 简化部署脚本
# 不需要 GitHub CLI，直接使用 Git 命令

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Markdown Web Service${NC}"
echo -e "${CYAN}  Git 简化部署脚本${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 配置
REPO_NAME="markdown-web-service"
REPO_URL="https://github.com/cloudinbanana/markdown-web-service.git"
TARGET_DIR="/root/clawd/github-deploy/markdown-web-service"

# 1. 检查目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}❌ 错误: 目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${BLUE}[1/7] 检查 Git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git 未安装${NC}"
    echo -e "${YELLOW}正在安装 Git...${NC}"
    
    # 尝试使用 apt 或 yum
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y git
    elif command -v yum &> /dev/null; then
        yum install -y git
    elif command -v dnf &> /dev/null; then
        dnf install -y git
    else
        echo -e "${RED}❌ 无法自动安装 Git${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

# 2. 进入目录
echo ""
echo -e "${BLUE}[2/7] 进入项目目录...${NC}"
cd "$TARGET_DIR"
echo -e "${GREEN}✓ 当前目录: $(pwd)${NC}"

# 3. 初始化 Git 仓库
echo ""
echo -e "${BLUE}[3/7] 初始化 Git 仓库...${NC}"
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Git 仓库已存在，跳过初始化${NC}"
else
    git init
    echo -e "${GREEN}✓ Git 仓库已初始化${NC}"
fi

# 4. 添加文件
echo ""
echo -e "${BLUE}[4/7] 添加所有文件...${NC}"
git add .
echo -e "${GREEN}✓ 文件已添加${NC}"

# 5. 提交
echo ""
echo -e "${BLUE}[5/7] 提交更改...${NC}"
if git diff --cached --quiet 2>/dev/null; then
    git commit -m "Add Markdown Web Service v1.0
- Complete deployment skill
- One-click installation script
- 4-stage security deployment" || echo -e "${YELLOW}⚠️  没有新的更改${NC}"
else
    echo -e "${YELLOW}⚠️  没有新的更改${NC}"
fi

# 6. 添加远程仓库
echo ""
echo -e "${BLUE}[6/7] 添加远程仓库...${NC}"
echo -e "${CYAN}仓库地址: $REPO_URL${NC}"

if git remote get-url origin &> /dev/null; then
    git remote set-url origin "$REPO_URL"
    echo -e "${GREEN}✓ 远程仓库已更新${NC}"
else
    git remote add origin "$REPO_URL"
    echo -e "${GREEN}✓ 远程仓库已添加${NC}"
fi

# 7. 推送
echo ""
echo -e "${BLUE}[7/7] 推送代码到 GitHub...${NC}"
echo -e "${YELLOW}注意: 可能需要输入 GitHub 用户名和密码（或 Personal Access Token）${NC}"
echo ""

git push -u origin main

# 8. 检查结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  推送成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}你的仓库地址:${NC}"
    echo -e "${CYAN}https://github.com/cloudinbanana/markdown-web-service${NC}"
    echo ""
    echo -e "${YELLOW}下一步操作:${NC}"
    echo -e "${YELLOW}1. 访问仓库: https://github.com/cloudinbanana/markdown-web-service${NC}"
    echo -e "${YELLOW}2. 在仓库页面创建 Release (v1.0)${NC}"
    echo -e "${YELLOW}3. 克隆到其他机器: git clone https://github.com/cloudinbanana/markdown-web-service.git${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  推送失败！${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}常见错误:${NC}"
    echo -e "${YELLOW}1. 认证失败: 请检查用户名/密码或 Token${NC}"
    echo -e "${YELLOW}2. 仓库不存在: 请先在 GitHub 网页创建仓库${NC}"
    echo -e "${YELLOW}3. 网络问题: 请检查网络连接${NC}"
    echo ""
    echo -e "${YELLOW}调试命令:${NC}"
    echo -e "${CYAN}git remote -v${NC}"
    echo -e "${CYAN}git push -v origin main${NC}"
    exit 1
fi
