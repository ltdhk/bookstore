# BookStore Docker Compose 部署指南

## 服务架构

| 服务 | 容器名 | 端口 | 说明 |
|------|--------|------|------|
| MySQL 8.0 | bookstore-mysql | 3307:3306 | 数据库服务 |
| Backend | bookstore-backend | 8090:8090 | Spring Boot 后端 |
| Nginx | bookstore-nginx | 81:80, 4433:443 | 反向代理 + Admin 静态托管 |
| Portainer | bookstore-portainer | 9090:9000 | Docker 管理界面 |

## 目录结构

```
Deploy/
├── docker-compose.yml          # 主编排文件
├── .env                        # 环境变量 (需要修改)
├── mysql/
│   ├── conf/my.cnf             # MySQL 配置
│   ├── data/                   # 数据目录 (自动生成)
│   ├── logs/                   # 日志目录
│   └── init/                   # 初始化 SQL (可选)
├── nginx/
│   ├── conf/nginx.conf         # Nginx 主配置
│   ├── conf.d/default.conf     # 站点配置
│   ├── ssl/                    # SSL 证书目录
│   ├── logs/                   # 日志目录
│   └── html/                   # Admin 静态文件
├── backend/
│   ├── app/app.jar             # JAR 包
│   ├── logs/                   # 应用日志
│   └── config/                 # 配置文件
└── portainer/
    └── data/                   # Portainer 数据
```

## 部署前准备

### 1. 配置环境变量

编辑 `.env` 文件，设置以下必要配置：

```bash
# 数据库密码 (必须修改!)
DB_PASSWORD=your_secure_password

# AWS S3 配置
AWS_ACCESS_KEY=xxx
AWS_SECRET_KEY=xxx

# Apple 登录配置
APPLE_TEAM_ID=xxx
APPLE_KEY_ID=xxx
APPLE_SHARED_SECRET=xxx

# Google 登录配置
GOOGLE_WEB_CLIENT_ID=xxx
GOOGLE_ANDROID_CLIENT_ID=xxx
GOOGLE_IOS_CLIENT_ID=xxx
```

### 2. 放置 SSL 证书

将 Let's Encrypt 证书放入 `nginx/ssl/` 目录：

```bash
cp /path/to/fullchain.pem nginx/ssl/
cp /path/to/privkey.pem nginx/ssl/
```

### 3. 放置 Backend JAR 包

构建后端项目并放置 JAR 包：

```bash
# 在 Backend 目录构建
cd ../Backend
mvn clean package -DskipTests

# 复制 JAR 包
cp target/novelpop-backend-0.0.1-SNAPSHOT.jar ../Deploy/backend/app/app.jar
```

### 4. 放置 Google 服务账户文件

```bash
cp /path/to/google-service-account.json backend/config/
```

### 5. 部署 Admin 管理后台

构建 Admin 项目并复制到 nginx/html：

```bash
# 在 Admin 目录构建
cd ../Admin
npm install
npm run build

# 复制构建产物
cp -r dist/* ../Deploy/nginx/html/
```

### 6. (可选) 放置数据库初始化脚本

如有初始化 SQL，放入 `mysql/init/` 目录，文件将在首次启动时自动执行。

## 启动服务

```bash
# 进入 Deploy 目录
cd Deploy

# 启动所有服务 (后台运行)
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
docker-compose logs -f nginx
docker-compose logs -f mysql
```

## 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷 (危险! 会删除数据库数据)
docker-compose down -v
```

## 常用命令

```bash
# 重启单个服务
docker-compose restart backend

# 重新构建并启动
docker-compose up -d --build

# 进入容器
docker exec -it bookstore-backend sh
docker exec -it bookstore-mysql mysql -u root -p

# 查看容器资源使用
docker stats
```

## 访问地址

- **Admin 管理后台**: https://your-domain:4433
- **API 接口**: https://your-domain:4433/api/
- **Portainer**: http://your-domain:9090
- **MySQL**: localhost:3307 (仅本地访问)

## 故障排查

### 1. Backend 启动失败

```bash
# 检查日志
docker-compose logs backend

# 常见问题:
# - JAR 包路径错误
# - MySQL 未就绪 (等待健康检查)
# - 环境变量配置错误
```

### 2. Nginx 启动失败

```bash
# 检查配置语法
docker exec bookstore-nginx nginx -t

# 检查日志
docker-compose logs nginx

# 常见问题:
# - SSL 证书路径错误
# - 配置文件语法错误
```

### 3. MySQL 连接失败

```bash
# 检查 MySQL 状态
docker-compose logs mysql

# 进入 MySQL 容器测试
docker exec -it bookstore-mysql mysql -u root -p

# 检查端口
netstat -tlnp | grep 3307
```

## 数据备份

```bash
# 备份 MySQL 数据
docker exec bookstore-mysql mysqldump -u root -p${DB_PASSWORD} novelpop_db > backup.sql

# 恢复数据
docker exec -i bookstore-mysql mysql -u root -p${DB_PASSWORD} novelpop_db < backup.sql
```

## 证书续期

Let's Encrypt 证书需要定期续期 (90天)：

```bash
# 续期后复制新证书
cp /path/to/new/fullchain.pem nginx/ssl/
cp /path/to/new/privkey.pem nginx/ssl/

# 重载 Nginx
docker exec bookstore-nginx nginx -s reload
```



portainer  admin Ltd50302290!