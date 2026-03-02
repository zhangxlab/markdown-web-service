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
OS_TYPE="$(uname -s)"
DRY_RUN="false"
POSITIONAL_ARGS=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -h|--help)
            echo "使用方法:"
            echo "  $0 [--dry-run] <阶段> [项目目录] [端口] [文档目录]"
            echo ""
            echo "示例:"
            echo "  $0 --dry-run 2 /Users/zhangxiang/markdown-web-service 5000 /Users/zhangxiang/markdown-web-service/docs"
            exit 0
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}"
STAGE="${1:-1}"
PROJECT_DIR="${2:-$(pwd)}"
PORT="${3:-5000}"
DOCS_DIR="${4:-$PROJECT_DIR/docs}"

is_macos() {
    [ "$OS_TYPE" = "Darwin" ]
}

is_linux() {
    [ "$OS_TYPE" = "Linux" ]
}

print_cmd() {
    printf '%q ' "$@"
    echo ""
}

run_cmd() {
    if [ "$DRY_RUN" = "true" ]; then
        echo -n "[dry-run] "
        print_cmd "$@"
    else
        "$@"
    fi
}

run_cmd_bg() {
    if [ "$DRY_RUN" = "true" ]; then
        echo -n "[dry-run] "
        print_cmd "$@"
    else
        "$@" &
    fi
}

sed_inplace() {
    local expr="$1"
    local file="$2"
    if [ "$DRY_RUN" = "true" ]; then
        if is_macos; then
            echo "[dry-run] sed -i '' \"$expr\" \"$file\""
        else
            echo "[dry-run] sed -i \"$expr\" \"$file\""
        fi
        return 0
    fi
    if is_macos; then
        sed -i '' "$expr" "$file"
    else
        sed -i "$expr" "$file"
    fi
}

copy_with_optional_sudo() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    if [ -w "$dest_dir" ]; then
        run_cmd cp "$src" "$dest"
    else
        run_cmd sudo cp "$src" "$dest"
    fi
}

install_nginx() {
    if command -v nginx >/dev/null 2>&1; then
        echo "✅ Nginx 已安装"
        return 0
    fi

    if is_macos && command -v brew >/dev/null 2>&1; then
        run_cmd brew install nginx
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        run_cmd sudo apt-get update
        run_cmd sudo apt-get install -y nginx
        return 0
    fi

    if command -v apt >/dev/null 2>&1; then
        run_cmd sudo apt install -y nginx
        return 0
    fi

    if command -v dnf >/dev/null 2>&1; then
        run_cmd sudo dnf install -y nginx
        return 0
    fi

    if command -v yum >/dev/null 2>&1; then
        run_cmd sudo yum install -y nginx
        return 0
    fi

    return 1
}

install_tailscale() {
    if command -v tailscale >/dev/null 2>&1; then
        echo "✅ Tailscale 已安装"
        return 0
    fi

    if is_macos && command -v brew >/dev/null 2>&1; then
        run_cmd brew install --cask tailscale
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        run_cmd sudo apt-get update
        run_cmd sudo apt-get install -y tailscale
        return 0
    fi

    if command -v apt >/dev/null 2>&1; then
        run_cmd sudo apt install -y tailscale
        return 0
    fi

    if command -v dnf >/dev/null 2>&1; then
        run_cmd sudo dnf install -y tailscale
        return 0
    fi

    if command -v yum >/dev/null 2>&1; then
        run_cmd sudo yum install -y tailscale
        return 0
    fi

    return 1
}

get_nginx_conf_target() {
    if is_macos; then
        for dir in \
            /opt/homebrew/etc/nginx/servers \
            /usr/local/etc/nginx/servers \
            /opt/homebrew/etc/nginx/conf.d \
            /usr/local/etc/nginx/conf.d; do
            if [ -d "$dir" ]; then
                echo "$dir/markdown-web-service.conf"
                return 0
            fi
        done
        return 1
    fi

    if [ -d /etc/nginx/conf.d ]; then
        echo "/etc/nginx/conf.d/markdown-web-service.conf"
        return 0
    fi

    if [ -d /etc/nginx/sites-enabled ]; then
        echo "/etc/nginx/sites-enabled/markdown-web-service.conf"
        return 0
    fi

    return 1
}

restart_nginx() {
    if command -v systemctl >/dev/null 2>&1; then
        run_cmd sudo systemctl restart nginx
        return 0
    fi

    if command -v brew >/dev/null 2>&1; then
        run_cmd brew services restart nginx || true
    fi

    if [ "$DRY_RUN" = "true" ]; then
        echo "[dry-run] nginx reload/start (auto-detect running state)"
        return 0
    fi

    if pgrep -x nginx >/dev/null 2>&1; then
        nginx -s reload >/dev/null 2>&1 || sudo nginx -s reload >/dev/null 2>&1 || true
    else
        nginx >/dev/null 2>&1 || sudo nginx >/dev/null 2>&1 || true
    fi
}

echo "=========================================="
echo "  Markdown Web 服务快速部署"
echo "=========================================="
echo ""
echo "配置信息："
echo "  部署阶段: $STAGE"
echo "  项目目录: $PROJECT_DIR"
echo "  服务端口: $PORT"
echo "  文档目录: $DOCS_DIR"
echo "  当前系统: $OS_TYPE"
echo "  Dry Run: $DRY_RUN"
echo ""

# 阶段选择
case $STAGE in
    1)
        echo -e "${GREEN}阶段 1: 基础部署（公开访问）${NC}"
        echo ""
        echo "步骤 1: 安装依赖..."
        run_cmd python3 -m pip install -r "$PROJECT_DIR/assets/requirements.txt"

        echo ""
        echo "步骤 2: 启动服务..."
        cd "$PROJECT_DIR"
        run_cmd_bg env PORT="$PORT" DOCS_DIR="$DOCS_DIR" python3 assets/markdown_server.py
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
        if ! install_nginx; then
            echo -e "${RED}❌ 无法安装 Nginx，请手动安装后重试${NC}"
            exit 1
        fi

        echo ""
        echo "步骤 2: 复制配置文件..."
        NGINX_CONF_TARGET="$(get_nginx_conf_target || true)"
        if [ -z "$NGINX_CONF_TARGET" ]; then
            if [ "$DRY_RUN" = "true" ]; then
                NGINX_CONF_TARGET="/etc/nginx/conf.d/markdown-web-service.conf"
                echo -e "${YELLOW}⚠️  未检测到本机 Nginx 配置目录，Dry Run 使用示例路径: $NGINX_CONF_TARGET${NC}"
            else
                echo -e "${RED}❌ 未找到 Nginx 配置目录，请手动复制 assets/nginx-markdown.conf${NC}"
                exit 1
            fi
        fi
        copy_with_optional_sudo "$PROJECT_DIR/assets/nginx-markdown.conf" "$NGINX_CONF_TARGET"
        if [ "$DRY_RUN" = "true" ]; then
            echo "[dry-run] nginx -t (or sudo nginx -t)"
        else
            nginx -t >/dev/null 2>&1 || sudo nginx -t
        fi

        echo ""
        echo "步骤 3: 重启 Nginx..."
        restart_nginx

        echo ""
        echo "步骤 4: 启动 Flask 服务（127.0.0.1）..."
        cd "$PROJECT_DIR"
        run_cmd_bg env DEPLOYMENT_STAGE=2 PORT="$PORT" DOCS_DIR="$DOCS_DIR" python3 assets/markdown_server.py
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
        if ! install_tailscale; then
            echo -e "${RED}❌ 无法安装 Tailscale，请手动安装后重试${NC}"
            exit 1
        fi

        echo ""
        echo "步骤 2: 启动 Tailscale..."
        if command -v systemctl >/dev/null 2>&1; then
            run_cmd sudo systemctl enable --now tailscaled
        else
            echo -e "${YELLOW}⚠️  当前系统无 systemctl，请确保 Tailscale 守护进程已启动${NC}"
        fi

        echo ""
        echo "步骤 3: 登录 Tailscale..."
        echo "请在浏览器中打开显示的链接完成登录"
        if [ "$DRY_RUN" = "true" ]; then
            echo "[dry-run] sudo tailscale up (fallback: tailscale up)"
        else
            sudo tailscale up || tailscale up
        fi

        echo ""
        echo "步骤 4: 获取 Tailscale IP..."
        if [ "$DRY_RUN" = "true" ]; then
            TAILSCALE_IP="<TAILSCALE_IP>"
            echo "[dry-run] tailscale ip -4"
        else
            TAILSCALE_IP=$(tailscale ip -4)
        fi
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
        if ! is_linux || ! command -v systemctl >/dev/null 2>&1; then
            if [ "$DRY_RUN" = "true" ]; then
                echo -e "${YELLOW}⚠️  当前环境不是 Linux+systemd，Dry Run 将按 Linux 目标预演${NC}"
            else
                echo -e "${RED}❌ 阶段 4 仅支持 Linux + systemd${NC}"
                exit 1
            fi
        fi

        echo "步骤 1: 修改服务配置..."
        PYTHON_BIN="$(command -v python3)"
        if [ "$DRY_RUN" = "true" ]; then
            SERVICE_TMP="/tmp/markdown-server.service.dry-run"
            echo "[dry-run] cp \"$PROJECT_DIR/assets/markdown-server.service\" \"$SERVICE_TMP\""
            sed_inplace "s|/path/to/your/project|$PROJECT_DIR|g" "$SERVICE_TMP"
            sed_inplace "s|/usr/bin/python3|$PYTHON_BIN|g" "$SERVICE_TMP"
        else
            SERVICE_TMP="$(mktemp /tmp/markdown-server.service.XXXXXX)"
            cp "$PROJECT_DIR/assets/markdown-server.service" "$SERVICE_TMP"
            sed_inplace "s|/path/to/your/project|$PROJECT_DIR|g" "$SERVICE_TMP"
            sed_inplace "s|/usr/bin/python3|$PYTHON_BIN|g" "$SERVICE_TMP"
        fi

        echo ""
        echo "步骤 2: 复制服务配置..."
        run_cmd sudo cp "$SERVICE_TMP" /etc/systemd/system/markdown-server.service
        if [ "$DRY_RUN" != "true" ]; then
            rm -f "$SERVICE_TMP"
        fi

        echo ""
        echo "步骤 3: 重载 systemd..."
        run_cmd sudo systemctl daemon-reload

        echo ""
        echo "步骤 4: 启用并启动服务..."
        run_cmd sudo systemctl enable markdown-server
        run_cmd sudo systemctl start markdown-server

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
        echo "  $0 [--dry-run] <阶段> [项目目录] [端口] [文档目录]"
        echo ""
        echo "阶段说明:"
        echo "  1 - 基础部署（公开访问）"
        echo "  2 - Nginx 反向代理"
        echo "  3 - Tailscale VPN"
        echo "  4 - Systemd 服务管理"
        echo ""
        echo "可选参数:"
        echo "  --dry-run, -n  仅打印将执行的命令，不实际执行"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  部署完成"
echo "=========================================="
