#!/usr/bin/env python3
"""
Markdown 渲染服务
提供网页界面查看 Markdown 文档

使用说明：
1. 修改 DOCS_DIR 指向你的 Markdown 文档目录
2. 修改 PORT 设置你想要的端口
3. 运行: python3 markdown_server.py
"""

from flask import Flask, render_template, jsonify
from flask_cors import CORS
import markdown
import os
from pathlib import Path
import re
from datetime import datetime

ASSETS_DIR = Path(__file__).resolve().parent
PROJECT_DIR = ASSETS_DIR.parent
TEMPLATES_DIR = ASSETS_DIR / "templates"
if not TEMPLATES_DIR.exists():
    fallback_templates = PROJECT_DIR / "templates"
    if fallback_templates.exists():
        TEMPLATES_DIR = fallback_templates

app = Flask(__name__, template_folder=str(TEMPLATES_DIR))
CORS(app)

# 配置 - 根据需要修改
DEFAULT_DOCS_DIR = PROJECT_DIR / "docs"
DOCS_DIR = Path(os.environ.get("DOCS_DIR", str(DEFAULT_DOCS_DIR))).expanduser()
try:
    PORT = int(os.environ.get("PORT", "5000"))
except ValueError:
    PORT = 5000

def get_file_number(filepath):
    """从文件名中提取数字用于排序"""
    match = re.match(r'(\d+)', filepath.name)
    return int(match.group(1)) if match else 999

def get_preview_text(filepath, max_chars):
    """提取 Markdown 文档预览文本"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except OSError:
        return ""

    # 去掉代码块和常见 Markdown 标记，保留可读片段
    content = re.sub(r'```[\s\S]*?```', ' ', content)
    content = re.sub(r'`[^`]*`', ' ', content)
    content = re.sub(r'!\[[^\]]*\]\([^\)]*\)', ' ', content)
    content = re.sub(r'\[[^\]]*\]\([^\)]*\)', ' ', content)
    content = re.sub(r'^\s{0,3}#{1,6}\s*', '', content, flags=re.MULTILINE)
    content = re.sub(r'[*_>#-]+', ' ', content)
    content = re.sub(r'\s+', ' ', content).strip()

    if len(content) <= max_chars:
        return content
    return content[:max_chars].rstrip() + "..."

def get_file_info(filepath):
    """获取文件信息"""
    stat = filepath.stat()
    preview_short = get_preview_text(filepath, 50)
    preview_long = get_preview_text(filepath, 300)
    return {
        'name': filepath.name,
        'path': str(filepath.relative_to(DOCS_DIR)),
        'size': stat.st_size,
        'modified': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S'),
        'preview': preview_long,
        'preview_short': preview_short,
        'preview_long': preview_long,
    }

def render_markdown(filepath):
    """渲染 Markdown 文件"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 使用 markdown 扩展
    html = markdown.markdown(
        content,
        extensions=[
            'fenced_code',  # 代码块
            'tables',      # 表格
            'toc',         # 目录
            'sane_lists',  # 列表
            'nl2br',       # 换行
            'extra',       # 额外功能
        ]
    )
    return html

@app.route('/')
def index():
    """首页 - 显示所有文档列表"""
    files = []

    # 获取所有 .md 文件（按数字排序）
    for filepath in sorted(DOCS_DIR.glob('*.md'), key=get_file_number):
        files.append(get_file_info(filepath))

    return render_template('index.html', files=files)

@app.route('/view/<path:filepath>')
def view_file(filepath):
    """查看单个文档"""
    full_path = DOCS_DIR / filepath

    if not full_path.exists() or not full_path.is_file():
        return "文件不存在", 404

    # 渲染 Markdown
    html_content = render_markdown(full_path)

    # 获取文件信息
    file_info = get_file_info(full_path)

    # 获取所有文件列表（用于侧边栏导航，按数字排序）
    all_files = []
    for fp in sorted(DOCS_DIR.glob('*.md'), key=get_file_number):
        all_files.append({
            'name': fp.name,
            'path': str(fp.relative_to(DOCS_DIR)),
        })

    return render_template(
        'view.html',
        content=html_content,
        filename=file_info['name'],
        filepath=file_info['path'],
        modified=file_info['modified'],
        size=file_info['size'],
        all_files=all_files
    )

@app.route('/api/files')
def api_files():
    """API: 获取所有文件列表"""
    files = []
    for filepath in sorted(DOCS_DIR.glob('*.md'), key=get_file_number):
        files.append(get_file_info(filepath))
    return jsonify(files)

@app.route('/api/file/<path:filepath>')
def api_file(filepath):
    """API: 获取单个文件内容"""
    full_path = DOCS_DIR / filepath

    if not full_path.exists() or not full_path.is_file():
        return jsonify({'error': '文件不存在'}), 404

    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()

    return jsonify({
        'name': full_path.name,
        'path': filepath,
        'content': content
    })

@app.route('/health')
def health():
    """健康检查"""
    return {"status": "ok", "service": "markdown-server"}

if __name__ == '__main__':
    # 创建模板目录
    TEMPLATES_DIR.mkdir(parents=True, exist_ok=True)

    # 检查文档目录
    if not DOCS_DIR.exists():
        print(f"❌ 错误: 文档目录不存在: {DOCS_DIR}")
        exit(1)

    print("="*60)
    print("  Markdown 渲染服务")
    print("="*60)
    print()
    print(f"📂 文档目录: {DOCS_DIR}")
    print(f"🌐 服务地址: http://0.0.0.0:{PORT}")
    print(f"📄 首页地址: http://localhost:{PORT}")
    print()
    print("✅ 服务启动成功！")
    print("="*60)

    # 根据部署阶段选择监听地址
    # Stage 1: 0.0.0.0 (公开访问)
    # Stage 2+: 127.0.0.1 (通过 Nginx 代理)
    HOST = os.environ.get('DEPLOYMENT_STAGE', '1')
    if HOST == '1':
        app.run(host='0.0.0.0', port=PORT, debug=False)
    else:
        app.run(host='127.0.0.1', port=PORT, debug=False)
