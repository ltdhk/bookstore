# HTTPS + Nginx + Docker 部署指南

本文档详细说明如何在 AWS EC2 上使用 Docker、Nginx 和 Let's Encrypt 配置 HTTPS，实现内购 Webhook 的安全通信。

---

## 目录

1. [前置条件](#前置条件)
2. [AWS Route 53 域名配置](#aws-route-53-域名配置)
3. [AWS 安全组配置](#aws-安全组配置)
4. [SSL 证书申请（Let's Encrypt）](#ssl-证书申请lets-encrypt)
5. [Nginx 配置](#nginx-配置)
6. [Docker 容器部署](#docker-容器部署)
7. [SSL 证书自动续期](#ssl-证书自动续期)
8. [测试与验证](#测试与验证)
9. [Webhook 配置（App Store & Google Play）](#webhook-配置)
10. [常见问题](#常见问题)

---

## 前置条件

### 环境信息
- **服务器**: AWS EC2（Amazon Linux 2）
- **公网 IP**: 18.118.241.217
- **域名**: api.novelpop.com
- **后端端口**: 8080（Spring Boot）
- **前端端口**: 80, 443（Nginx）

### 所需工具
- Docker（已安装）
- Certbot（Let's Encrypt 客户端）
- SSH 密钥

---

## AWS Route 53 域名配置

### 步骤 1: 在 Route 53 创建 A 记录

1. 登录 [AWS Console](https://console.aws.amazon.com/)
2. 导航到 **Route 53** → **Hosted zones**
3. 选择你的域名（例如: `novelpop.com`）
4. 点击 **Create record**，填写以下信息：

| 字段 | 值 |
|------|-----|
| Record name | `api` |
| Record type | `A` |
| Value | `18.118.241.217` |
| TTL (seconds) | `300` |
| Routing policy | Simple routing |

5. 点击 **Create records** 保存

### 步骤 2: 验证 DNS 解析

```bash
# 使用 nslookup 验证
nslookup api.novelpop.com

# 或使用 dig
dig api.novelpop.com

# 期望输出:
# api.novelpop.com.  300  IN  A  18.118.241.217
```

**注意**: DNS 传播可能需要 5-15 分钟

---

## AWS 安全组配置

### 配置入站规则

1. 进入 **EC2** → **Security Groups**
2. 选择你的实例所用的安全组
3. 点击 **Edit inbound rules**
4. 添加以下规则：

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| Custom TCP | TCP | 81 | 0.0.0.0/0 | HTTP traffic (custom port) |
| Custom TCP | TCP | 81 | ::/0 | HTTP traffic (IPv6) |
| Custom TCP | TCP | 4433 | 0.0.0.0/0 | HTTPS traffic (custom port) |
| Custom TCP | TCP | 4433 | ::/0 | HTTPS traffic (IPv6) |
| Custom TCP | TCP | 8080 | 172.17.0.0/16 | Docker internal |
| SSH | TCP | 22 | Your-IP/32 | SSH access |

5. 点击 **Save rules**

**注意**：如果需要使用 Let's Encrypt 的 HTTP-01 验证方式申请证书，还需要临时开放标准 80 端口，或使用 DNS-01 验证方式。

---

## SSL 证书申请（Let's Encrypt）

### 步骤 1: SSH 连接到 EC2

```bash
ssh -i C:\Users\ltdhk\Documents\DevTools\novelpop_key.pem ec2-user@ec2-18-118-241-217.us-east-2.compute.amazonaws.com
```

### 步骤 2: 安装 Certbot

```bash
# Amazon Linux 2
sudo yum install -y certbot

# Ubuntu/Debian
# sudo apt-get update
# sudo apt-get install -y certbot
```

### 步骤 3: 创建目录结构

```bash
# 创建必要的目录
sudo mkdir -p /home/nginx/conf/conf.d
sudo mkdir -p /home/nginx/log
sudo mkdir -p /home/nginx/html
sudo mkdir -p /home/nginx/ssl
sudo mkdir -p /home/nginx/certbot
sudo mkdir -p /home/scripts
```

### 步骤 4: 停止临时 Nginx（如果运行中）

```bash
# 检查是否有运行的 Nginx 容器
docker ps

# 停止并删除旧容器
docker stop novelpop-nginx 2>/dev/null
docker rm novelpop-nginx 2>/dev/null
```

### 步骤 5: 申请 SSL 证书

**方法一：使用 standalone 模式（需要临时使用标准 80 端口）**

```bash
# 1. 停止 Nginx 容器释放端口
docker stop novelpop-nginx 2>/dev/null

# 2. 临时允许 80 端口流量（在 AWS 安全组中添加规则）
# Type: HTTP, Port: 80, Source: 0.0.0.0/0

# 3. 使用 standalone 模式申请证书
sudo certbot certonly --standalone \
  -d api.novelpop.com \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive

# 4. 申请成功后，可以移除 80 端口的安全组规则
```

**方法二：使用 DNS-01 验证（推荐，无需标准端口）**

```bash
# 使用 DNS 验证方式，无需开放 80 端口
sudo certbot certonly --manual \
  --preferred-challenges dns \
  -d api.novelpop.com \
  --email your-email@example.com \
  --agree-tos

# 按提示在 Route 53 添加 TXT 记录进行验证
# 记录类型: TXT
# 记录名: _acme-challenge.api
# 记录值: （Certbot 会提供）
```

**方法三：使用 webroot 模式（与 Nginx 配合，推荐用于续期）**

```bash
# 在非标准端口上使用 webroot 验证
# 需要配置 Nginx 的 /.well-known/acme-challenge/ 路径
# 详见下方的 Nginx 配置
```

**成功后的输出**:
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/api.novelpop.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/api.novelpop.com/privkey.pem
```

### 步骤 6: 复制证书到挂载目录

```bash
# 复制证书文件
sudo cp /etc/letsencrypt/live/api.novelpop.com/fullchain.pem /home/nginx/ssl/
sudo cp /etc/letsencrypt/live/api.novelpop.com/privkey.pem /home/nginx/ssl/

# 设置正确的权限
sudo chmod 644 /home/nginx/ssl/fullchain.pem
sudo chmod 600 /home/nginx/ssl/privkey.pem

# 验证文件存在
ls -lh /home/nginx/ssl/
```

---

## Nginx 配置

### 步骤 1: 获取默认配置

```bash
# 启动临时容器获取默认配置
docker run --name nginx-temp -d nginx
docker cp nginx-temp:/etc/nginx/nginx.conf /home/nginx/conf/nginx.conf
docker cp nginx-temp:/etc/nginx/conf.d /home/nginx/conf/
docker rm -f nginx-temp
```

### 步骤 2: 配置 nginx.conf 和 conf.d 的区别

**nginx.conf** (主配置文件):
- 位置: `/etc/nginx/nginx.conf`
- 作用: 全局配置，定义 worker 进程、日志、事件模型
- 修改频率: 很少修改
- 引入子配置: `include /etc/nginx/conf.d/*.conf;`

**conf.d/** (模块化配置目录):
- 位置: `/etc/nginx/conf.d/*.conf`
- 作用: 存放具体的站点配置（server 块）
- 修改频率: 经常修改（添加新站点）
- 优势: 便于管理多个网站/应用

### 步骤 3: 创建 Webhook 配置文件

```bash
# 编辑 Webhook 配置
sudo nano /home/nginx/conf/conf.d/bookstore-webhook.conf
```

**粘贴以下配置**:

```nginx
# BookStore Backend upstream
upstream bookstore_backend {
    # Docker 容器访问宿主机
    server host.docker.internal:8080;

    # 如果上面不工作，使用 Docker 桥接网络 IP
    # server 172.17.0.1:8080;

    # 连接池配置
    keepalive 32;
}

# ==========================================
# HTTP Server - 重定向到 HTTPS
# ==========================================
server {
    listen 80;
    listen [::]:80;
    server_name api.novelpop.com;

    # Let's Encrypt ACME challenge（用于证书续期）
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # 其他所有请求重定向到 HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# ==========================================
# HTTPS Server
# ==========================================
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.novelpop.com;

    # ----------------
    # SSL 证书配置
    # ----------------
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    # SSL 协议和加密套件
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    # SSL 会话缓存
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # ----------------
    # 安全头配置
    # ----------------
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # ----------------
    # 日志配置
    # ----------------
    access_log /var/log/nginx/bookstore_access.log;
    error_log /var/log/nginx/bookstore_error.log;

    # ----------------
    # 上传限制
    # ----------------
    client_max_body_size 100M;
    client_body_buffer_size 128k;

    # ==========================================
    # Apple App Store Webhook
    # ==========================================
    location /api/webhook/apple {
        proxy_pass http://bookstore_backend/api/webhook/apple;

        # 基础代理头
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Webhook 特定配置
        proxy_buffering off;              # 关闭缓冲，立即转发
        proxy_request_buffering off;      # 不缓冲请求体

        # 超时配置（Webhook 处理可能较长）
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # HTTP/1.1 支持
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        # 单独的日志文件
        access_log /var/log/nginx/webhook_apple.log;
    }

    # ==========================================
    # Google Play Webhook
    # ==========================================
    location /api/webhook/google {
        proxy_pass http://bookstore_backend/api/webhook/google;

        # 基础代理头
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Webhook 特定配置
        proxy_buffering off;
        proxy_request_buffering off;

        # 超时配置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # HTTP/1.1 支持
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        # 单独的日志文件
        access_log /var/log/nginx/webhook_google.log;
    }

    # ==========================================
    # 通用 API 路由
    # ==========================================
    location /api/ {
        proxy_pass http://bookstore_backend/api/;

        # 基础代理头
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 标准超时配置
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;

        # HTTP/1.1 支持
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    # ==========================================
    # 健康检查端点（可选）
    # ==========================================
    location /health {
        proxy_pass http://bookstore_backend/actuator/health;
        access_log off;
    }
}
```

保存文件：`Ctrl + O`, `Enter`, `Ctrl + X`

---

## Docker 容器部署

### 启动 Nginx 容器（包含 SSL 支持）

**重要说明**：由于宿主机使用非标准端口映射（81→80, 4433→443），需要注意：
- 容器内部配置保持标准端口（80 和 443）
- 端口映射在 Docker 启动命令中处理
- 外部访问需要使用：`https://api.novelpop.com:4433` 或配置前端代理

```bash
# 删除旧容器（如果存在）
docker stop novelpop-nginx 2>/dev/null
docker rm novelpop-nginx 2>/dev/null

# 启动新容器（使用非标准端口映射）
docker run \
  -p 81:80 \
  -p 4433:443 \
  --name novelpop-nginx \
  -v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
  -v /home/nginx/conf/conf.d:/etc/nginx/conf.d \
  -v /home/nginx/log:/var/log/nginx \
  -v /home/nginx/html:/usr/share/nginx/html \
  -v /home/nginx/ssl:/etc/nginx/ssl:ro \
  -v /home/nginx/certbot:/var/www/certbot:ro \
  --restart unless-stopped \
  -d nginx:latest
```

**参数说明**:
- `-p 81:80`: HTTP 端口映射（宿主机 81 → 容器 80）
- `-p 4433:443`: HTTPS 端口映射（宿主机 4433 → 容器 443）
- `-v /home/nginx/ssl:/etc/nginx/ssl:ro`: 挂载 SSL 证书（只读）
- `-v /home/nginx/certbot:/var/www/certbot:ro`: 挂载 Certbot 验证目录
- `--restart unless-stopped`: 自动重启策略

### 验证容器状态

```bash
# 查看容器状态
docker ps

# 测试 Nginx 配置
docker exec novelpop-nginx nginx -t

# 输出应该是:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# 重载配置
docker exec novelpop-nginx nginx -s reload

# 查看日志
docker logs -f novelpop-nginx
```

---

## SSL 证书自动续期

Let's Encrypt 证书有效期为 90 天，需要设置自动续期。

### 步骤 1: 创建续期脚本

```bash
sudo nano /home/scripts/renew-cert.sh
```

**脚本内容**:

```bash
#!/bin/bash

# SSL 证书自动续期脚本
# 用途: 续期 Let's Encrypt 证书并重启 Nginx

LOG_FILE="/var/log/certbot-renew.log"

echo "======================================" >> $LOG_FILE
echo "Certificate renewal started at $(date)" >> $LOG_FILE

# 停止 Nginx 容器
echo "Stopping Nginx container..." >> $LOG_FILE
docker stop novelpop-nginx

# 续期证书
echo "Renewing certificate..." >> $LOG_FILE
certbot renew --quiet --deploy-hook "echo 'Certificate renewed successfully'"

# 复制新证书到挂载目录
echo "Copying certificates..." >> $LOG_FILE
cp /etc/letsencrypt/live/api.novelpop.com/fullchain.pem /home/nginx/ssl/
cp /etc/letsencrypt/live/api.novelpop.com/privkey.pem /home/nginx/ssl/

# 设置权限
chmod 644 /home/nginx/ssl/fullchain.pem
chmod 600 /home/nginx/ssl/privkey.pem

# 启动 Nginx 容器
echo "Starting Nginx container..." >> $LOG_FILE
docker start novelpop-nginx

# 等待容器启动
sleep 5

# 重载 Nginx 配置
echo "Reloading Nginx..." >> $LOG_FILE
docker exec novelpop-nginx nginx -s reload

echo "Certificate renewal completed at $(date)" >> $LOG_FILE
echo "======================================" >> $LOG_FILE
```

### 步骤 2: 设置执行权限

```bash
sudo chmod +x /home/scripts/renew-cert.sh
```

### 步骤 3: 测试脚本

```bash
# 手动运行测试
sudo /home/scripts/renew-cert.sh

# 查看日志
cat /var/log/certbot-renew.log
```

### 步骤 4: 添加 Cron 定时任务

```bash
# 编辑 root 用户的 crontab
sudo crontab -e
```

**添加以下行**（每周日凌晨 2 点执行）:

```cron
# SSL Certificate Auto-Renewal (Every Sunday at 2:00 AM)
0 2 * * 0 /home/scripts/renew-cert.sh
```

保存并退出

### 步骤 5: 验证 Cron 任务

```bash
# 查看当前 cron 任务
sudo crontab -l

# 查看 cron 日志
sudo tail -f /var/log/cron
```

---

## 测试与验证

### 1. 测试 HTTPS 连接（使用非标准端口）

```bash
# 测试 HTTPS 是否正常（注意使用 4433 端口）
curl -I https://api.novelpop.com:4433/api/webhook/apple

# 期望输出:
# HTTP/2 200
# server: nginx
# ...
```

### 2. 测试 HTTP 到 HTTPS 重定向

```bash
# 测试 HTTP 重定向（注意使用 81 端口）
curl -I http://api.novelpop.com:81/api/webhook/apple

# 期望输出:
# HTTP/1.1 301 Moved Permanently
# Location: https://api.novelpop.com/api/webhook/apple
# 注意：重定向到标准 HTTPS URL，可能需要调整 Nginx 配置
```

### 3. 测试 Apple Webhook

```bash
# 使用非标准端口测试
curl -X POST https://api.novelpop.com:4433/api/webhook/apple \
  -H "Content-Type: application/json" \
  -d '{
    "notificationType": "TEST",
    "notificationUuid": "test-uuid-123"
  }'

# 期望输出:
# {"code":200,"message":"success","data":"Notification processed successfully"}
```

### 4. 测试 Google Webhook

```bash
# 使用非标准端口测试
curl -X POST https://api.novelpop.com:4433/api/webhook/google \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "data": "eyJ0ZXN0IjoidGVzdCJ9",
      "messageId": "test-123"
    }
  }'
```

### 5. 查看实时日志

```bash
# Nginx 主日志
docker logs -f novelpop-nginx

# Webhook 日志
tail -f /home/nginx/log/webhook_apple.log
tail -f /home/nginx/log/webhook_google.log

# 访问日志
tail -f /home/nginx/log/bookstore_access.log

# 错误日志
tail -f /home/nginx/log/bookstore_error.log
```

### 6. 检查 SSL 证书信息

```bash
# 查看证书有效期
openssl x509 -in /home/nginx/ssl/fullchain.pem -noout -dates

# 输出示例:
# notBefore=Jan  1 00:00:00 2025 GMT
# notAfter=Apr  1 00:00:00 2025 GMT

# 查看证书详细信息
openssl x509 -in /home/nginx/ssl/fullchain.pem -text -noout
```

### 7. 在线 SSL 测试

使用 [SSL Labs](https://www.ssllabs.com/ssltest/) 测试你的 SSL 配置：

```
https://www.ssllabs.com/ssltest/analyze.html?d=api.novelpop.com
```

---

## Webhook 配置

### Apple App Store Connect

#### 配置步骤

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 选择你的应用
3. 导航到 **App Information** → **App Store Server Notifications**
4. 配置 Webhook URL:

**如果使用非标准端口 4433：**

| 环境 | URL |
|------|-----|
| Production | `https://api.novelpop.com:4433/api/webhook/apple` |
| Sandbox | `https://api.novelpop.com:4433/api/webhook/apple` |

**推荐方案**：在服务器前配置标准端口代理，使用标准 443 端口：
- 在前端添加一个监听 443 的反向代理指向 4433
- 或使用 AWS Application Load Balancer (ALB)
- 这样 Webhook URL 可以使用标准格式：`https://api.novelpop.com/api/webhook/apple`

5. 点击 **Test** 按钮测试连接
6. 保存配置

#### 验证 Apple Webhook

Apple 会发送测试通知，你可以在日志中查看：

```bash
tail -f /home/nginx/log/webhook_apple.log
```

### Google Play Console

#### 配置步骤

1. 登录 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建 Pub/Sub Topic:
   - 导航到 **Pub/Sub** → **Topics**
   - 点击 **Create Topic**
   - Topic ID: `novelpop-iap-notifications`

3. 创建 Push Subscription:
   - 在 Topic 页面，点击 **Create Subscription**
   - Subscription ID: `novelpop-webhook-push`
   - Delivery type: **Push**
   - Endpoint URL: `https://api.novelpop.com:4433/api/webhook/google`（如果使用非标准端口）
   - 或使用标准端口代理：`https://api.novelpop.com/api/webhook/google`（推荐）
   - 点击 **Create**

4. 配置 Google Play Console:
   - 登录 [Google Play Console](https://play.google.com/console/)
   - 选择你的应用
   - 导航到 **Monetization setup** → **Real-time developer notifications**
   - 选择之前创建的 Pub/Sub Topic: `novelpop-iap-notifications`
   - 点击 **Save**

#### 验证 Google Webhook

```bash
# 查看 Google Webhook 日志
tail -f /home/nginx/log/webhook_google.log

# 查看 Spring Boot 日志
# docker logs -f <spring-boot-container>
```

---

## 常见问题

### 1. 无法访问 HTTPS

**症状**: 浏览器显示"无法连接"

**排查**:
```bash
# 1. 检查安全组是否开放 443 端口
# AWS Console → EC2 → Security Groups

# 2. 检查容器是否运行
docker ps | grep novelpop-nginx

# 3. 检查端口监听
sudo netstat -tlnp | grep :443

# 4. 检查证书文件
docker exec novelpop-nginx ls -la /etc/nginx/ssl
```

### 2. 502 Bad Gateway

**症状**: Nginx 返回 502 错误

**排查**:
```bash
# 1. 检查 Spring Boot 后端是否运行
curl http://localhost:8080/api/health

# 2. 检查 Docker 网络连接
docker exec novelpop-nginx ping -c 3 host.docker.internal

# 3. 如果 host.docker.internal 不工作，修改配置
sudo nano /home/nginx/conf/conf.d/bookstore-webhook.conf
# 将 server host.docker.internal:8080; 改为:
# server 172.17.0.1:8080;

# 4. 重载 Nginx
docker exec novelpop-nginx nginx -s reload

# 5. 查看错误日志
tail -f /home/nginx/log/bookstore_error.log
```

### 3. 证书申请失败

**症状**: Certbot 报错 "Failed to obtain certificate"

**排查**:
```bash
# 1. 确认 DNS 已生效
nslookup api.novelpop.com

# 2. 确认 80 端口未被占用
sudo netstat -tlnp | grep :80

# 3. 停止所有使用 80 端口的进程
docker stop novelpop-nginx

# 4. 重新申请证书
sudo certbot certonly --standalone \
  -d api.novelpop.com \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive \
  --debug

# 5. 查看详细日志
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

### 4. 证书过期

**症状**: 浏览器显示"证书已过期"

**解决**:
```bash
# 1. 手动续期
sudo /home/scripts/renew-cert.sh

# 2. 强制续期
sudo certbot renew --force-renewal

# 3. 复制新证书
sudo cp /etc/letsencrypt/live/api.novelpop.com/*.pem /home/nginx/ssl/

# 4. 重启 Nginx
docker restart novelpop-nginx

# 5. 验证新证书
openssl x509 -in /home/nginx/ssl/fullchain.pem -noout -dates
```

### 5. Webhook 收不到通知

**Apple Webhook**:
```bash
# 1. 查看日志
tail -f /home/nginx/log/webhook_apple.log

# 2. 测试端点
curl -X POST https://api.novelpop.com/api/webhook/apple \
  -H "Content-Type: application/json" \
  -d '{"notificationType":"TEST"}'

# 3. 检查 App Store Connect 配置
# 确认 URL 正确且状态为 "Active"

# 4. 查看 Spring Boot 日志
# 查找 "Received Apple webhook notification"
```

**Google Webhook**:
```bash
# 1. 查看日志
tail -f /home/nginx/log/webhook_google.log

# 2. 验证 Pub/Sub Subscription
# Google Cloud Console → Pub/Sub → Subscriptions
# 查看 "Delivery type" 是否为 "Push"

# 3. 测试端点
curl -X POST https://api.novelpop.com/api/webhook/google \
  -H "Content-Type: application/json" \
  -d '{"message":{"data":"eyJ0ZXN0IjoidGVzdCJ9"}}'

# 4. 检查权限
# 确保 Pub/Sub Service Account 有发送权限
```

### 6. Docker 容器无法启动

**排查**:
```bash
# 1. 查看容器日志
docker logs novelpop-nginx

# 2. 检查配置语法
docker exec novelpop-nginx nginx -t

# 3. 检查挂载的文件是否存在
ls -la /home/nginx/conf/nginx.conf
ls -la /home/nginx/conf/conf.d/
ls -la /home/nginx/ssl/

# 4. 检查端口冲突
sudo netstat -tlnp | grep -E '(80|443)'

# 5. 强制重建容器
docker rm -f novelpop-nginx
# 重新运行启动命令
```

---

## 常用运维命令

### Docker 操作

```bash
# 查看容器状态
docker ps -a

# 启动容器
docker start novelpop-nginx

# 停止容器
docker stop novelpop-nginx

# 重启容器
docker restart novelpop-nginx

# 查看实时日志
docker logs -f novelpop-nginx

# 进入容器
docker exec -it novelpop-nginx bash

# 删除容器
docker rm -f novelpop-nginx
```

### Nginx 操作

```bash
# 测试配置
docker exec novelpop-nginx nginx -t

# 重载配置（无需重启）
docker exec novelpop-nginx nginx -s reload

# 查看 Nginx 版本
docker exec novelpop-nginx nginx -v

# 查看编译参数
docker exec novelpop-nginx nginx -V

# 查看进程
docker exec novelpop-nginx ps aux | grep nginx
```

### 日志查看

```bash
# 实时查看所有日志
tail -f /home/nginx/log/*.log

# 查看访问日志
tail -f /home/nginx/log/bookstore_access.log

# 查看错误日志
tail -f /home/nginx/log/bookstore_error.log

# 查看 Webhook 日志
tail -f /home/nginx/log/webhook_apple.log
tail -f /home/nginx/log/webhook_google.log

# 搜索特定内容
grep "webhook" /home/nginx/log/bookstore_access.log

# 查看最近 100 行
tail -n 100 /home/nginx/log/bookstore_access.log
```

### 证书操作

```bash
# 查看证书有效期
openssl x509 -in /home/nginx/ssl/fullchain.pem -noout -dates

# 查看证书详细信息
openssl x509 -in /home/nginx/ssl/fullchain.pem -text -noout

# 列出所有证书
sudo certbot certificates

# 手动续期证书
sudo certbot renew

# 强制续期
sudo certbot renew --force-renewal

# 删除证书
sudo certbot delete --cert-name api.novelpop.com
```

---

## 监控和告警

### 设置日志轮转

```bash
# 创建 logrotate 配置
sudo nano /etc/logrotate.d/nginx-docker
```

内容:

```
/home/nginx/log/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        docker exec novelpop-nginx nginx -s reload > /dev/null 2>&1 || true
    endscript
}
```

### 监控脚本（可选）

```bash
# 创建监控脚本
sudo nano /home/scripts/monitor-nginx.sh
```

内容:

```bash
#!/bin/bash

# 检查 Nginx 容器是否运行
if ! docker ps | grep -q novelpop-nginx; then
    echo "Nginx container is down! Restarting..." | mail -s "Nginx Alert" your-email@example.com
    docker start novelpop-nginx
fi

# 检查 HTTPS 是否正常
if ! curl -sf https://api.novelpop.com/health > /dev/null; then
    echo "HTTPS endpoint is not responding!" | mail -s "HTTPS Alert" your-email@example.com
fi
```

---

## 总结

本文档完整介绍了如何在 AWS EC2 上使用 Docker、Nginx 和 Let's Encrypt 配置 HTTPS，并实现内购 Webhook 的安全通信。

**关键要点**:
1. ✅ 使用 Let's Encrypt 免费 SSL 证书
2. ✅ Docker 容器化部署 Nginx
3. ✅ 自动化证书续期
4. ✅ 分离式 Nginx 配置管理（nginx.conf + conf.d）
5. ✅ 完整的监控和日志方案

**安全建议**:
- 定期检查证书有效期
- 监控 Webhook 日志，及时发现异常
- 保持 Docker 和 Nginx 版本更新
- 定期备份配置文件和证书

**相关文档**:
- [SETUP.md](SETUP.md) - 项目部署文档
- [IAP_Optimization_Summary.md](IAP_Optimization_Summary.md) - 内购优化总结

---

## 非标准端口特别说明

### 当前配置（81 → 80, 4433 → 443）

#### 优点
- 可以与其他服务共存（其他服务使用标准 80/443）
- 灵活的端口管理

#### 缺点
- 客户端访问需要指定端口号：`https://api.novelpop.com:4433`
- Apple/Google Webhook 配置中也需要带端口号
- SSL 证书申请时需要使用 DNS 验证或临时开放标准 80 端口
- 用户体验不如标准端口

### 推荐解决方案

#### 方案一：使用 iptables 端口转发

在宿主机上配置端口转发，将标准端口转发到非标准端口：

```bash
# 将 80 转发到 81
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 81

# 将 443 转发到 4433
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 4433

# 保存规则（Amazon Linux 2）
sudo service iptables save

# 或在 Ubuntu/Debian
# sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

这样外部可以使用标准端口访问，而容器仍然使用 81/4433。

#### 方案二：使用 Nginx 代理（推荐）

在宿主机上运行一个轻量级 Nginx 监听 80/443，代理到容器的 81/4433：

**宿主机 Nginx 配置** (`/etc/nginx/sites-available/port-proxy`):

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name api.novelpop.com;

    location / {
        proxy_pass http://127.0.0.1:81;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.novelpop.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass https://127.0.0.1:4433;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 方案三：使用 AWS Application Load Balancer (ALB)

创建一个 ALB 监听 80/443，转发到 EC2 实例的 81/4433：

1. 创建 ALB
2. 配置监听器：
   - 监听器 1: 80 → 转发到目标组（端口 81）
   - 监听器 2: 443 → 转发到目标组（端口 4433）
3. 在 ALB 上配置 SSL 证书
4. 更新 DNS 记录指向 ALB

#### 方案四：直接使用标准端口

如果没有端口冲突，直接修改 Docker 启动命令使用标准端口：

```bash
docker run \
  -p 80:80 \
  -p 443:443 \
  --name novelpop-nginx \
  # ... 其他参数
```

### Nginx 容器配置保持不变

**重要提醒**：无论选择哪种方案，Nginx 容器内部的配置文件都应该保持标准端口：

```nginx
server {
    listen 80;        # 容器内部监听 80
    listen [::]:80;
}

server {
    listen 443 ssl http2;   # 容器内部监听 443
    listen [::]:443 ssl http2;
}
```

端口映射只在 Docker 启动命令中处理，配置文件不需要改变。

---

**文档维护**: 最后更新于 2025-12-04
