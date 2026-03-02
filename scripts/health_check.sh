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

is_port_listening() {
    local target_port="$1"

    if command -v lsof >/dev/null 2>&1; then
        lsof -nP -iTCP:"$target_port" -sTCP:LISTEN >/dev/null 2>&1
        return $?
    fi

    if command -v ss >/dev/null 2>&1; then
        ss -ltn 2>/dev/null | grep -Eq "[:.]${target_port}[[:space:]]"
        return $?
    fi

    if command -v netstat >/dev/null 2>&1; then
        netstat -an 2>/dev/null | grep -E 'LISTEN|LISTENING' | grep -Eq "[\\.:]${target_port}([[:space:]]|$)"
        return $?
    fi

    return 2
}

check_endpoint() {
    local path="$1"
    curl -s -f -m 5 "http://localhost:${PORT}${path}" > /dev/null 2>&1 || \
    curl -s -f -m 5 "http://127.0.0.1:${PORT}${path}" > /dev/null 2>&1
}

echo "=========================================="
echo "  Markdown Web 服务健康检查"
echo "=========================================="
echo ""
echo "检查端口: $PORT"
echo ""

# 1. 检查端口监听
echo -n "1. 检查端口监听..."
if is_port_listening "$PORT"; then
    echo -e " ${GREEN}✅ 端口正在监听${NC}"
else
    if [ $? -eq 2 ]; then
        echo -e "${YELLOW} ⚠️  无可用端口检测命令（lsof/ss/netstat）${NC}"
    else
        echo -e " ${RED}❌ 端口未监听${NC}"
        exit 1
    fi
fi

# 2. 检查服务状态
echo -n "2. 检查服务状态..."
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet markdown-server 2>/dev/null; then
        echo -e " ${GREEN}✅ 服务正在运行${NC}"
    else
        echo -e "${YELLOW}⚠️  服务未通过 Systemd 管理${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  当前系统无 systemctl，跳过${NC}"
fi

# 3. 检查本地访问
echo -n "3. 检查本地访问..."
if check_endpoint "/"; then
    echo -e " ${GREEN}✅ 本地访问正常${NC}"
else
    echo -e "${RED}❌ 本地访问失败${NC}"
    exit 1
fi

# 4. 检查健康端点
echo -n "4. 检查健康端点..."
if check_endpoint "/health"; then
    echo -e " ${GREEN}✅ 健康端点正常${NC}"
else
    echo -e "${YELLOW}⚠️  健康端点不存在（非致命）${NC}"
fi

# 5. 检查 API
echo -n "5. 检查 API..."
if check_endpoint "/api/files"; then
    echo -e " ${GREEN}✅ API 正常${NC}"
else
    echo -e "${RED}❌ API 失败${NC}"
    exit 1
fi

# 6. 检查日志
echo -n "6. 检查日志错误..."
if command -v journalctl >/dev/null 2>&1; then
    if journalctl -u markdown-server -n 20 2>/dev/null | grep -q "ERROR"; then
        echo -e "${RED}❌ 日志中发现错误${NC}"
        echo ""
        echo "最近的错误："
        journalctl -u markdown-server -n 20 --no-pager | grep "ERROR" | tail -5
    else
        echo -e "${GREEN}✅ 日志无错误${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  当前系统无 journalctl，跳过${NC}"
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
