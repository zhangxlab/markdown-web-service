#!/bin/bash
# 快速推送脚本 - 使用 HTTPS 和 Personal Access Token

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  HTTPS 推送脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

TARGET_DIR="/root/clawd/github-deploy/markdown-web-service"
GITHUB_USERNAME="cloudinbanana"
REPO_NAME="markdown-web-service"

echo -e "${BLUE}[1/5] 进入项目目录...${NC}"
cd "$TARGET_DIR"
echo -e "${GREEN}✓ 当前目录: $(pwd)${NC}"

echo ""
echo -e "${BLUE}[2/5] 配置 Git 远程为 HTTPS...${NC}"
git remote set-url origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
echo -e "${GREEN}✓ 远程已更新${NC}"

echo ""
echo -e "${BLUE}[3/5] 准备推送...${NC}"
echo -e "${YELLOW}注意: 接下来会要求输入 GitHub 用户名和密码${NC}"
echo -e "${YELLOW}用户名: $GITHUB_USERNAME${NC}"
echo -e "${YELLOW}密码: [输入你的 GitHub 密码或 Personal Access Token]${NC}"
echo ""

echo -e "${BLUE}[4/5] 推送代码...${NC}"
git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  推送成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}你的仓库地址:${NC}"
    echo -e "${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  推送失败！${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo -e "${YELLOW}常见错误:${NC}"
    echo -e "${YELLOW}1. 仓库名不存在: 请先在 GitHub 网页创建${NC}"
    echo -e "${YELLOW}2. 认证失败: 请检查用户名/密码或 Token${NC}"
    echo -e "${YELLOW}3. 权限不足: 请检查仓库权限${NC}"
    echo ""
    echo -e "${YELLOW}解决方法:${NC}"
    echo -e "${CYAN}1. 在 GitHub 网页创建仓库: https://github.com/new${NC}"
    echo -e "${CYAN}2. 仓库名称: $REPO_NAME${NC}"
    echo -e "${CYAN}3. 重新运行此脚本${NC}"
fi
