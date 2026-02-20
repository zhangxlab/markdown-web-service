#!/bin/bash
# 快速部署脚本 - Markdown Web 服务
# 用途: 一键部署 Markdown Web 服务到指定阶段

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 默认配置
STAGE="${1:-1}"
PROJECT_DIR="${2:-$(pwd)}"
PORT="${3:-5000}"
DOCS_DIR="${4:-$PROJECT_DIR}"

echo "=========================================="
echo "  Markdown Web 服务快速部署"
echo "=========================================="
echo ""
echo "配置信息："
echo "  部署阶段: $STAGE"
echo "  项目目录: $PROJECT_DIR"
echo "  服务端口: $PORT"
echo "  文档目录: $DOCS_DIR"
echo ""

# 阶段选择
case $STAGE in
    1)
        echo -e "${GREEN}阶段 1: 基础部署（公开访问）${NC}"
        echo ""
        echo "步骤 1: 安装依赖..."
        pip3 install -r assets/requirements.txt

        echo ""
        echo "步骤 2: 启动服务..."
        cd "$PROJECT_DIR"
        python3 assets/markdown_server.py &
        echo "✅ 服务启动成功！"
        echo ""
        echo "访问地址:"
        echo "  - 本地: http://localhost:$PORT"
        echo "  - 公网: http://<公网IP>:$PORT"
        echo ""
        echo "⚠️  记得开放安全组端口 $PORT"
        ;;
    2)
        echo -e "${GREEN}阶段 2: Nginx 反向代理${NC}"
        echo ""
        echo "步骤 1: 安装 Nginx..."
        if command -v yum &> /dev/null; then
            sudo yum install -y nginx
        elif command -v apt &> /dev/null; then
            sudo apt install -y nginx
        fi

        echo ""
        echo "步骤 2: 复制配置文件..."
        sudo cp assets/nginx-markdown.conf /etc/nginx/conf.d/
        sudo nginx -t

        echo ""
        echo "步骤 3: 重启 Nginx..."
        sudo systemctl restart nginx

        echo ""
        echo "步骤 4: 修改 Flask 监听地址..."
        sed -i "s/host='0.0.0.0'/host='127.0.0.1'/" "$PROJECT_DIR/markdown_server.py"

        echo ""
        echo "步骤 5: 启动 Flask 服务..."
        cd "$PROJECT_DIR"
        DEPLOYMENT_STAGE=2 python3 assets/markdown_server.py &
        echo "✅ 服务启动成功！"
        echo ""
        echo "访问地址:"
        echo "  - 本地: http://localhost:80"
        echo "  - 公网: http://<公网IP>:80"
        echo ""
        echo "⚠️  记得开放安全组端口 80"
        ;;
    3)
        echo -e "${GREEN}阶段 3: Tailscale VPN${NC}"
        echo ""
        echo "步骤 1: 安装 Tailscale..."
        if command -v yum &> /dev/null; then
            sudo yum install -y tailscale
        elif command -v apt &> /dev/null; then
            sudo apt install -y tailscale
        fi

        echo ""
        echo "步骤 2: 启动 Tailscale..."
        sudo systemctl enable --now tailscaled

        echo ""
        echo "步骤 3: 登录 Tailscale..."
        echo "请在浏览器中打开显示的链接完成登录"
        sudo tailscale up

        echo ""
        echo "步骤 4: 获取 Tailscale IP..."
        TAILSCALE_IP=$(tailscale ip -4)
        echo "✅ Tailscale IP: $TAILSCALE_IP"
        echo ""
        echo "访问地址:"
        echo "  - Tailscale: http://$TAILSCALE_IP:$PORT"
        echo ""
        echo "⚠️  关闭公网端口以提高安全性"
        ;;
    4)
        echo -e "${GREEN}阶段 4: Systemd 服务管理${NC}"
        echo ""
        echo "步骤 1: 修改服务配置..."
        sed -i "s|/path/to/your/project|$PROJECT_DIR|g" assets/markdown-server.service
        sed -i "s|/path/to/your/project|$PROJECT_DIR|g" assets/markdown-server.service

        echo ""
        echo "步骤 2: 复制服务配置..."
        sudo cp assets/markdown-server.service /etc/systemd/system/

        echo ""
        echo "步骤 3: 重载 systemd..."
        sudo systemctl daemon-reload

        echo ""
        echo "步骤 4: 启用并启动服务..."
        sudo systemctl enable markdown-server
        sudo systemctl start markdown-server

        echo ""
        echo "✅ 服务启动成功！"
        echo ""
        echo "访问地址:"
        echo "  - 本地: http://localhost:$PORT"
        echo ""
        echo "管理命令:"
        echo "  - 状态: sudo systemctl status markdown-server"
        echo "  - 重启: sudo systemctl restart markdown-server"
        echo "  - 日志: sudo journalctl -u markdown-server -f"
        ;;
    *)
        echo -e "${RED}错误: 无效的阶段 $STAGE${NC}"
        echo ""
        echo "使用方法:"
        echo "  $0 <阶段> [项目目录] [端口] [文档目录]"
        echo ""
        echo "阶段说明:"
        echo "  1 - 基础部署（公开访问）"
        echo "  2 - Nginx 反向代理"
        echo "  3 - Tailscale VPN"
        echo "  4 - Systemd 服务管理"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  部署完成"
echo "=========================================="
