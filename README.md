# Markdown Web Service 📚

> **将 Markdown 文档快速部署为美观的 Web 服务**

![Python](https://img.shields.io/badge/python-3.7+-blue.svg)
![Flask](https://img.shields.io/badge/flask-3.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

---

## ✨ 特性

- 📖 **Markdown 渲染**：自动转换为美观的 HTML
- 📋 **文档浏览**：直观的文档列表界面
- 🎨 **代码高亮**：支持 Fenced Code Blocks 语法高亮
- 📊 **表格支持**：自动渲染 Markdown 表格
- 📑 **目录生成**：自动生成文档目录（TOC）
- 🔗 **侧边栏导航**：文档列表快速切换
- 🔌 **API 接口**：提供 REST API 获取文档内容和列表
- 📱 **响应式设计**：支持桌面和移动端访问
- 🚀 **一键安装**：自动安装依赖并启动服务
- 🚀 **一键部署**：支持 GitHub CLI 和 Git 命令行自动部署

---

## 🚀 快速开始

### 方式一：GitHub 自动部署（推荐）

#### 前置要求

1. **安装 Git**
   ```bash
   # Ubuntu/Debian
   sudo apt install -y git
   
   # CentOS/RHEL
   sudo yum install -y git
   ```

2. **安装 GitHub CLI（可选但推荐）**
   ```bash
   # Linux (x86_64)
   curl -fsSL https://cli.github.com/packages/githubcli-linux-amd64_v2.51.0.tar.gz | tar xz
   sudo mv gh /usr/local/bin/
   sudo chmod +x /usr/local/bin/gh
   
   # macOS
   brew install gh
   ```

3. **克隆或下载此仓库**
   ```bash
   # 方式 A: 克隆
   git clone https://github.com/YOUR_USERNAME/markdown-web-service.git
   cd markdown-web-service
   
   # 方式 B: 下载 ZIP 并解压
   wget https://github.com/YOUR_USERNAME/markdown-web-service/archive/refs/heads/main.zip
   unzip main.zip
   cd markdown-web-service-main
   ```

#### 一键部署步骤

**步骤 1：运行 GitHub 部署脚本**

```bash
# 进入项目目录
cd markdown-web-service

# 运行 GitHub 部署脚本
chmod +x deploy_to_github.sh
./deploy_to_github.sh
```

**脚本会自动完成：**
1. ✅ 检查 Git 环境
2. ✅ 检查 GitHub CLI 是否安装
3. ✅ 初始化 Git 仓库
4. ✅ 添加所有文件
5. ✅ 提交更改
6. ✅ 如果使用 GitHub CLI，自动创建仓库
7. ✅ 添加远程仓库
8. ✅ 推送代码到 GitHub

**重要提示：**
- 🔑 **安全认证**：如果使用 GitHub CLI，脚本会引导你通过浏览器安全登录（无需暴露 Token）
- 📋 **配置用户名**：脚本中有一个 `GITHUB_USERNAME="YOUR_USERNAME"` 变量，请修改为你的 GitHub 用户名
- ⏸️ **未安装 CLI**：如果没有 GitHub CLI，脚本会使用 Git 命令行（可能需要输入用户名/密码或使用凭据助手）

**步骤 2：验证部署**

推送成功后，你可以访问：
```
https://github.com/YOUR_USERNAME/markdown-web-service
```

---

### 方式二：手动 Git 命令行部署

```bash
# 1. 进入项目目录
cd markdown-web-service

# 2. 初始化 Git 仓库
git init

# 3. 添加所有文件
git add .

# 4. 提交更改
git commit -m "Add Markdown Web Service v1.0
- Complete deployment skill
- One-click installation script
- 4-stage security deployment"

# 5. 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/markdown-web-service.git

# 6. 推送到 GitHub
git push -u origin main
```

---

### 方式三：GitHub Desktop 部署（推荐非程序员）

1. **下载 GitHub Desktop**：https://desktop.github.com/
2. **克隆空仓库**：
   - 打开 GitHub Desktop
   - 点击 "File" → "Clone repository"
   - 粘贴仓库 URL：`https://github.com/YOUR_USERNAME/markdown-web-service.git`
   - 选择本地路径
3. **复制文件**：
   - 将 `markdown-web-service` 目录中的所有文件复制到克隆的仓库文件夹
   - GitHub Desktop 会显示变更
4. **提交并推送**：
   - 在 GitHub Desktop 中输入 Commit 信息：
     ```
     Add Markdown Web Service v1.0
     ```
   - 点击 "Push origin" 或 "Publish branch"

---

## 📖 使用方法

### 添加文档

将你的 Markdown 文件放入 `docs/` 目录：

```bash
# 创建示例文档
cat > docs/01-introduction.md << 'EOF'
# 项目介绍

这是一个示例 Markdown 文档。

## 功能列表

1. Markdown 渲染
2. 文档浏览
3. API 接口
EOF
```

### Web 界面使用

- **首页**：http://localhost:5000
  - 📚 查看所有文档列表
  - 📊 显示文档大小和修改时间

- **文档查看**：http://localhost:5000/view/01-introduction.md
  - 📖 渲染 Markdown 为 HTML
  - 🔗 侧边栏快速导航
  - 🎨 代码高亮、表格渲染

### API 接口使用

**获取文件列表：**
```bash
curl http://localhost:5000/api/files
```

**获取文件内容：**
```bash
curl http://localhost:5000/api/file/01-introduction.md
```

---

## 📄 文档说明

| 文件 | 说明 |
|------|------|
| `SKILL.md` | 详细技能说明和四阶段部署教程 |
| `README.md` | 仓库说明和快速开始指南（本文件） |
| `deploy_to_github.sh` | **GitHub 自动部署脚本（推荐）** |
| `install.sh` | 一键安装脚本（本地部署） |
| `scripts/quick_deploy.sh` | 快速部署脚本 |
| `scripts/health_check.sh` | 健康检查脚本 |
| `assets/markdown_server.py` | Flask 应用主文件 |
| `assets/markdown_server.service` | Systemd 服务文件 |
| `assets/nginx-markdown.conf` | Nginx 配置 |
| `assets/requirements.txt` | Python 依赖 |

---

## 🌐 四阶段部署

### 阶段一：基础版（本地访问）

直接运行 `markdown_server.py`，绑定到 `0.0.0.0`。

**优点：**
- ✅ 部署最简单
- ✅ 无需额外软件
- ✅ 快速上线

**缺点：**
- ⚠️ 安全性较低（无反向代理）
- ⚠️ 无域名绑定

### 阶段二：进阶版（Nginx 反向代理）

使用 `assets/nginx-markdown.conf` 配置 Nginx。

**优点：**
- ✅ 支持域名访问
- ✅ 隐藏后端端口
- ✅ 支持 SSL/HTTPS

**缺点：**
- ⚠️ 需要配置 Nginx
- ⚠️ 配置稍复杂

### 阶段三：安全版（Tailscale VPN）

使用 Tailscale 实现内网穿透。

**优点：**
- ✅ 端到端加密
- ✅ 内网穿透
- ✅ 无需公网 IP
- ✅ 动态 IP 无影响

**缺点：**
- ⚠️ 需要安装 Tailscale
- ⚠️ 访问者需要 Tailscale 客户端

### 阶段四：生产版（Systemd 管理）

使用 `assets/markdown_server.service` 配置 Systemd。

**优点：**
- ✅ 自动启动和重启
- ✅ 完善的日志管理
- ✅ 服务监控

**缺点：**
- ⚠️ 配置相对复杂
- ⚠️ 需要 root 权限

---

## 🛠️ 常见问题

### Q1: Git 推送失败

**可能原因：**
1. 认证失败（用户名/密码错误）
2. 仓库不存在
3. 网络连接问题
4. 权限不足

**解决方法：**
```bash
# 检查远程仓库
git remote -v

# 测试连接
git push -u origin main --dry-run

# 查看详细日志
git push -u origin main 2>&1
```

### Q2: 脚本执行失败

**可能原因：**
1. Git 未安装
2. GitHub CLI 未安装或未认证
3. 文件权限问题
4. 目录结构错误

**解决方法：**
```bash
# 手动检查 Git
git --version

# 手动检查 GitHub CLI
gh auth status

# 检查文件权限
ls -la
```

### Q3: 服务无法访问

**可能原因：**
1. 端口被占用
2. 防火墙未开放
3. 绑定地址错误

**解决方法：**
```bash
# 检查端口监听
netstat -tulnp | grep 5000

# 检查防火墙
sudo ufw status

# 检查服务状态
sudo systemctl status markdown-service
```

### Q4: Markdown 渲染错误

**可能原因：**
1. 文件编码问题（应为 UTF-8）
2. Markdown 语法错误
3. 缺少扩展

**解决方法：**
```python
# 确保文件编码为 UTF-8
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()
```

---

## 🔧 配置说明

### 修改端口

编辑 `assets/markdown_server.py`：

```python
PORT = 8080  # 修改为你喜欢的端口
```

### 修改文档目录

编辑 `assets/markdown_server.py`：

```python
DOCS_DIR = Path("/path/to/your/docs")  # 修改为你的文档目录
```

### 修改 GitHub 用户名

编辑 `deploy_to_github.sh`：

```bash
GITHUB_USERNAME="YOUR_USERNAME"  # 修改为你的 GitHub 用户名
```

---

## 📊 部署检查清单

部署前请确认：

- [ ] Git 已安装
- [ ] GitHub CLI 已安装（如使用自动部署）
- [ ] 所有文件已添加到 Git
- [ ] Commit 信息已填写
- [ ] GitHub 用户名已配置（在脚本中）
- [ ] 远程仓库 URL 正确
- [ ] GitHub 仓库已创建（如使用 CLI）

---

## 📞 技术支持

如遇到问题，请参考：

1. **详细部署教程**：查看 `SKILL.md`
2. **GitHub CLI 文档**：https://cli.github.com/manual/
3. **Git 文档**：https://git-scm.com/docs/
4. **社区支持**：相关技术社区

---

## 📄 License

MIT License

---

**版本**: v1.0
**作者**: Monke 小助手 🐒
**最后更新**: 2026-02-12
