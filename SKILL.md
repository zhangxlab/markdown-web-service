---
name: markdown-web-deploy
description: "Deploy Markdown documentation to web services with progressive security stages. Use when setting up documentation sites with Flask, Nginx, Tailscale, or Systemd service management. Supports 4 deployment stages: basic (public access), advanced (Nginx reverse proxy), secure (Tailscale VPN), and production (Systemd management)."
---

# Markdown Web Service Deployment

Deploy Markdown documentation to web services with 4 progressive security stages.

## Quick Start

Choose your deployment stage and follow corresponding instructions below:

- **Stage 1**: Basic public access (Flask only)
- **Stage 2**: Nginx reverse proxy (production-ready)
- **Stage 3**: Tailscale VPN (secure, no public ports)
- **Stage 4**: Systemd management (auto-start, auto-restart)

## Stage 1: Basic Deployment

### Create Flask Application

Copy Flask application template:
```bash
cp assets/markdown_server.py ./
```

### Configure Application

Edit `markdown_server.py` and modify these lines:
```python
DOCS_DIR = Path("/path/to/your/docs")  # Change to your docs directory
PORT = 5000  # Change to your desired port
```

### Install Dependencies
```bash
pip3 install -r assets/requirements.txt
```

### Start Service
```bash
python3 markdown_server.py
```

### Configure Firewall

Open port in your cloud provider security group (e.g., port 5000).

Access at: `http://<public-ip>:5000`

## Stage 2: Nginx Reverse Proxy

### Install Nginx
```bash
# CentOS/RHEL
sudo yum install -y nginx

# Ubuntu/Debian
sudo apt install -y nginx
```

### Configure Nginx
```bash
cp assets/nginx-markdown.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl restart nginx
```

### Update Flask

Change `host='0.0.0.0'` to `host='127.0.0.1'` in `markdown_server.py`

### Configure Firewall
- Close port 5000
- Open port 80

Access at: `http://<public-ip>`

## Stage 3: Tailscale VPN

### Install Tailscale
```bash
# CentOS/RHEL
sudo yum install -y tailscale
sudo systemctl enable --now tailscaled

# Ubuntu/Debian
sudo apt install -y tailscale
sudo systemctl enable --now tailscaled
```

### Login to Tailscale
```bash
sudo tailscale up
```

Access via Tailscale:
```bash
tailscale ip -4
```

Access at: `http://<tailscale-ip>:5000` or `http://<tailscale-ip>:80`

## Stage 4: Systemd Management

### Create Systemd Service
```bash
cp assets/markdown-server.service /etc/systemd/system/
```

### Configure Service

Edit `markdown-server.service` and modify:
```ini
WorkingDirectory=/path/to/your/project
ExecStart=/usr/bin/python3 /path/to/your/project/markdown_server.py
Environment="DEPLOYMENT_STAGE=2"
```

### Enable and Start
```bash
sudo systemctl daemon-reload
sudo systemctl enable markdown-server
sudo systemctl start markdown-server
```

### Check Service Status
```bash
sudo systemctl status markdown-server
```

### View Logs
```bash
sudo journalctl -u markdown-server -f
```

## Automated Deployment

### Quick Deploy Script

Use automated deployment for any stage:
```bash
# Stage 1: Basic deployment
scripts/quick_deploy.sh 1 /path/to/project 5000 /path/to/docs

# Stage 2: Nginx reverse proxy
scripts/quick_deploy.sh 2 /path/to/project 5000 /path/to/docs

# Stage 3: Tailscale VPN
scripts/quick_deploy.sh 3 /path/to/project 5000 /path/to/docs

# Stage 4: Systemd management
scripts/quick_deploy.sh 4 /path/to/project 5000 /path/to/docs
```

### Health Check

Verify service health:
```bash
scripts/health_check.sh 5000
```

## Troubleshooting

### Service Won't Start
```bash
# Check port
netstat -tulnp | grep 5000

# Check logs
sudo journalctl -u markdown-server -n 50

# Check service status
sudo systemctl status markdown-server
```

### Cannot Access Service
```bash
# Test local access
curl http://localhost:5000

# Check firewall
sudo firewall-cmd --list-all

# Check Nginx (if using)
curl http://localhost:80
```

### Tailscale Issues
```bash
# Check status
sudo tailscale status

# Re-login
sudo tailscale up --reset

# Get Tailscale IP
tailscale ip -4
```

## Recommended Deployment

- **For development**: Stage 1
- **For production**: Stage 2 + Stage 4
- **For high security**: Stage 3 + Stage 4
- **Best practice**: Stage 2 + Stage 3 + Stage 4

## Files Structure

```
markdown-web-deploy/
├── SKILL.md                          # This file
├── assets/                           # Configuration files
│   ├── markdown_server.py            # Flask application template
│   ├── requirements.txt               # Python dependencies
│   ├── nginx-markdown.conf            # Nginx configuration
│   └── markdown-server.service       # Systemd service template
└── scripts/                          # Automation scripts
    ├── quick_deploy.sh              # Automated deployment
    └── health_check.sh             # Health check script
```

## Next Steps

1. Choose your deployment stage
2. Copy and configure files
3. Run deployment script or follow manual steps
4. Verify with health check
5. Access your documentation
