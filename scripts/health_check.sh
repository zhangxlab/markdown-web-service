#!/bin/bash
# 健康检查脚本 - Markdown Web 服务
# 用途: 检查 Markdown Web 服务的健康状态

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
PORT="${1:-5000}"

echo "=========================================="
echo "  Markdown Web 服务健康检查"
echo "=========================================="
echo ""
echo "检查端口: $PORT"
echo ""

# 1. 检查端口监听
echo -n "1. 检查端口监听..."
if netstat -tulnp 2>/dev/null | grep -q ":$PORT "; then
    echo -e " ${GREEN}✅ 端口正在监听${NC}"
else
    echo -e " ${RED}❌ 端口未监听${NC}"
    exit 1
fi

# 2. 检查服务状态
echo -n "2. 检查服务状态..."
if systemctl is-active --quiet markdown-server 2>/dev/null; then
    echo -e " ${GREEN}✅ 服务正在运行${NC}"
else
    echo -e "${YELLOW}⚠️  服务未通过 Systemd 管理${NC}"
fi

# 3. 检查本地访问
echo -n "3. 检查本地访问..."
if curl -s -f -m 5 "http://localhost:$PORT/" > /dev/null 2>&1; then
    echo -e " ${GREEN}✅ 本地访问正常${NC}"
else
    echo -e "${RED}❌ 本地访问失败${NC}"
    exit 1
fi

# 4. 检查健康端点
echo -n "4. 检查健康端点..."
if curl -s -f -m 5 "http://localhost:$PORT/health" > /dev/null 2>&1; then
    echo -e " ${GREEN}✅ 健康端点正常${NC}"
else
    echo -e "${YELLOW}⚠️  健康端点不存在（非致命）${NC}"
fi

# 5. 检查 API
echo -n "5. 检查 API..."
if curl -s -f -m 5 "http://localhost:$PORT/api/files" > /dev/null 2>&1; then
    echo -e " ${GREEN}✅ API 正常${NC}"
else
    echo -e "${RED}❌ API 失败${NC}"
    exit 1
fi

# 6. 检查日志
echo -n "6. 检查日志错误..."
if journalctl -u markdown-server -n 20 2>/dev/null | grep -q "ERROR"; then
    echo -e "${RED}❌ 日志中发现错误${NC}"
    echo ""
    echo "最近的错误："
    journalctl -u markdown-server -n 20 --no-pager | grep "ERROR" | tail -5
else
    echo -e "${GREEN}✅ 日志无错误${NC}"
fi

echo ""
echo "=========================================="
echo "  健康检查完成"
echo "=========================================="
echo ""
echo "✅ 所有检查通过！"
echo ""
echo "访问地址:"
echo "  - 本地: http://localhost:$PORT"
echo "  - 公网: http://<公网IP>:$PORT"
echo "  - Tailscale: http://<Tailscale_IP>:$PORT"
