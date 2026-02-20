#!/bin/bash
# Markdown Web Service 一键安装脚本

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 输出标题
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Markdown Web Service${NC}"
echo -e "${BLUE}  一键安装脚本${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 1. 检查 Python 3
echo -e "${BLUE}[1/6] 检查 Python 3...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 错误: Python 3 未安装${NC}"
    echo -e "${YELLOW}请先安装 Python 3: https://www.python.org/downloads/${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python 3 已安装${NC}"

# 2. 检查 pip
echo ""
echo -e "${BLUE}[2/6] 检查 pip...${NC}"
if command -v pip3 &> /dev/null; then
    PIP="pip3"
elif command -v pip &> /dev/null; then
    PIP="pip"
else
    echo -e "${YELLOW}⚠️  警告: pip/pip3 未找到，尝试使用 python3 -m pip${NC}"
    PIP="python3 -m pip"
fi
echo -e "${GREEN}✓ pip 可用: $PIP${NC}"

# 3. 安装依赖
echo ""
echo -e "${BLUE}[3/6] 安装 Python 依赖...${NC}"
if [ -f "assets/requirements.txt" ]; then
    $PIP install -r assets/requirements.txt
    echo -e "${GREEN}✓ 依赖安装完成${NC}"
else
    echo -e "${YELLOW}⚠️  警告: assets/requirements.txt 不存在${NC}"
fi

# 4. 创建必要目录
echo ""
echo -e "${BLUE}[4/6] 创建目录结构...${NC}"
mkdir -p docs
mkdir -p templates
echo -e "${GREEN}✓ docs/ 目录已创建${NC}"
echo -e "${GREEN}✓ templates/ 目录已创建${NC}"

# 5. 检查 Flask 应用
echo ""
echo -e "${BLUE}[5/6] 检查 Flask 应用...${NC}"
if [ -f "assets/markdown_server.py" ]; then
    echo -e "${GREEN}✓ assets/markdown_server.py 已存在${NC}"
else
    echo -e "${RED}❌ 错误: assets/markdown_server.py 不存在${NC}"
    exit 1
fi

# 6. 检查脚本权限
echo ""
echo -e "${BLUE}[6/6] 检查脚本权限...${NC}"
chmod +x scripts/quick_deploy.sh
chmod +x scripts/health_check.sh
echo -e "${GREEN}✓ 脚本权限已设置${NC}"

# 7. 显示完成信息
echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}下一步操作：${NC}"
echo ""
echo -e "${YELLOW}1. 启动服务：${NC}"
echo -e "   ${BLUE}python3 assets/markdown_server.py${NC}"
echo ""
echo -e "${YELLOW}2. 或使用快速部署脚本：${NC}"
echo -e "   ${BLUE}./scripts/quick_deploy.sh${NC}"
echo ""
echo -e "${YELLOW}3. 检查服务状态：${NC}"
echo -e "   ${BLUE}./scripts/health_check.sh${NC}"
echo ""
echo -e "${YELLOW}4. 访问 Web 界面：${NC}"
echo -e "   ${BLUE}http://localhost:5000${NC}"
echo ""
echo -e "${BLUE}======================================${NC}"
echo ""
