# novelpop Backend - Docker 部署指南

## 快速开始

### 1. 准备环境变量

复制 `.env.example` 并创建 `.env` 文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件，填入你的实际配置信息。

**重要说明**：
- 生产环境使用 `SPRING_PROFILES_ACTIVE=docker`，会加载 `application-docker.yml`
- 数据库连接和密码通过**环境变量**配置，优先级最高
- 配置优先级：环境变量 > application-docker.yml > application.yml

### 2. 使用 Docker Compose 运行

#### 运行完整环境（包括 MySQL）

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f backend

# 停止服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v
```

#### 仅运行后端（使用外部数据库）

如果你想使用现有的数据库（如 AWS RDS），可以只运行后端服务：

```bash
# 修改 docker-compose.yml，注释掉 mysql 服务
# 或者只启动 backend 服务
docker-compose up -d backend
```

确保在 `.env` 中配置正确的数据库连接信息。

### 3. 直接使用 Docker 命令

#### 构建镜像

```bash
cd Backend
docker build -t novelpop-backend:latest .
```

#### 运行容器

```bash
docker run -d \
  --name novelpop-backend \
  -p 8090:8090 \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://your-db-host:3306/novelpop_db?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai" \
  -e SPRING_DATASOURCE_USERNAME=root \
  -e SPRING_DATASOURCE_PASSWORD=your-db-password \
  -e AWS_ACCESS_KEY=your-aws-access-key \
  -e AWS_SECRET_KEY=your-aws-secret-key \
  -e APPLE_SHARED_SECRET=your-apple-shared-secret \
  -v $(pwd)/logs:/app/logs \
  novelpop-backend:latest
```

#### 查看日志

```bash
docker logs -f novel pop-backend
```

#### 停止和删除容器

```bash
docker stop novelpop-backend
docker rm novelpop-backend
```

### 4. 验证健康检查

Spring Boot Actuator 已配置，提供健康检查端点：

```bash
# 检查应用健康状态
curl http://localhost:8090/actuator/health

# 预期响应
{
  "status": "UP"
}

# 查看更多端点
curl http://localhost:8090/actuator
```

**可用的 Actuator 端点：**
- `/actuator/health` - 健康检查
- `/actuator/info` - 应用信息
- `/actuator/metrics` - 性能指标

**Docker 健康检查：**
```bash
# 查看容器健康状态
docker ps

# 查看健康检查日志
docker inspect novelpop-backend | grep -A 10 Health
```

## 生产环境部署

### ⚠️ 多平台支持 - 重要！

**如果在 Apple Silicon Mac (ARM64) 上构建，但要部署到 AWS/云服务器 (AMD64)，必须构建多平台镜像！**

#### 方法 1: 使用 buildx 构建多平台镜像（推荐）

```bash
# 创建 buildx builder
docker buildx create --name multiplatform --use
docker buildx inspect --bootstrap

# 构建并推送多平台镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t your-dockerhub-username/novelpop-backend:latest \
  --push .

# 或只构建 AMD64 平台（用于 AWS/大多数云服务器）
docker buildx build \
  --platform linux/amd64 \
  -t your-dockerhub-username/novelpop-backend:latest \
  --push .
```

#### 方法 2: 使用 docker build 指定平台

```bash
# 构建 AMD64 镜像（用于 AWS）
docker build --platform linux/amd64 -t novelpop-backend:latest .

# 标记并推送
docker tag novelpop-backend:latest your-dockerhub-username/novelpop-backend:latest
docker push your-dockerhub-username/novelpop-backend:latest
```

### 使用 Docker Hub

#### 1. 标记镜像

```bash
docker tag novelpop-backend:latest your-dockerhub-username/novelpop-backend:latest
docker tag novelpop-backend:latest your-dockerhub-username/novelpop-backend:v1.0.0
```

#### 2. 推送到 Docker Hub

```bash
docker login
docker push your-dockerhub-username/novelpop-backend:latest
docker push your-dockerhub-username/novelpop-backend:v1.0.0
```

#### 3. 在服务器上拉取并运行

```bash
docker pull your-dockerhub-username/novelpop-backend:latest
docker run -d \
  --name novelpop-backend \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=docker \
  --env-file .env \
  your-dockerhub-username/novelpop-backend:latest
```

### 使用 AWS ECR

#### 1. 登录到 ECR

```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin your-account-id.dkr.ecr.us-east-2.amazonaws.com
```

#### 2. 创建仓库

```bash
aws ecr create-repository --repository-name novelpop-backend --region us-east-2
```

#### 3. 标记并推送镜像

```bash
docker tag novelpop-backend:latest your-account-id.dkr.ecr.us-east-2.amazonaws.com/novelpop-backend:latest
docker push your-account-id.dkr.ecr.us-east-2.amazonaws.com/novelpop-backend:latest
```

### 使用 AWS ECS 部署

1. 创建 ECS 集群
2. 创建任务定义（Task Definition）
3. 创建服务（Service）
4. 配置负载均衡器（可选）

### 使用 Kubernetes 部署

创建 Kubernetes 部署配置文件：

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: novelpop-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: novelpop-backend
  template:
    metadata:
      labels:
        app: novelpop-backend
    spec:
      containers:
      - name: backend
        image: your-dockerhub-username/novelpop-backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: docker
        envFrom:
        - secretRef:
            name: novelpop-secrets
        resources:
          limits:
            memory: "1Gi"
            cpu: "500m"
          requests:
            memory: "512Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: novelpop-backend-service
spec:
  selector:
    app: novelpop-backend
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

部署到 Kubernetes：

```bash
kubectl apply -f k8s/deployment.yml
kubectl get pods
kubectl get services
```

## 健康检查

容器包含健康检查端点：

```bash
# 检查容器健康状态
docker inspect --format='{{.State.Health.Status}}' novelpop-backend

# 手动检查健康端点
curl http://localhost:8080/actuator/health
```

## 日志管理

### 查看实时日志

```bash
docker-compose logs -f backend
```

### 日志持久化

日志已挂载到宿主机的 `./logs` 目录，可以使用 ELK、Fluentd 等工具收集分析。

## 性能优化

### JVM 参数调优

在 `docker-compose.yml` 中修改 `JAVA_OPTS`：

```yaml
environment:
  JAVA_OPTS: "-Xms1g -Xmx2g -XX:+UseG1GC"
```

### 资源限制

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '1'
      memory: 1G
```

## 故障排查

### 容器无法启动

```bash
# 查看容器日志
docker logs novelpop-backend

# 进入容器调试
docker exec -it novelpop-backend sh

# 检查环境变量
docker exec novelpop-backend env
```

### 数据库连接失败

1. 检查数据库地址是否正确
2. 确认网络连通性
3. 验证数据库凭证
4. 检查防火墙规则

### 内存溢出

调整 JVM 堆内存大小：

```bash
JAVA_OPTS="-Xms1g -Xmx2g"
```

## 安全建议

1. **不要在镜像中硬编码敏感信息**，使用环境变量
2. **使用非 root 用户运行容器**（已在 Dockerfile 中配置）
3. **定期更新基础镜像**
4. **使用 Docker secrets** 管理敏感信息（生产环境）
5. **限制容器资源使用**
6. **启用 TLS/SSL** 加密通信

## 监控

推荐使用以下工具监控容器：

- **Prometheus + Grafana** - 指标监控
- **ELK Stack** - 日志分析
- **cAdvisor** - 容器监控
- **Jaeger** - 分布式追踪

## 备份与恢复

### 数据库备份

```bash
# 备份数据库
docker exec novelpop-mysql mysqldump -u root -p novelpop_db > backup.sql

# 恢复数据库
docker exec -i novelpop-mysql mysql -u root -p novelpop_db < backup.sql
```

## 参考资料

- [Docker 官方文档](https://docs.docker.com/)
- [Spring Boot Docker 指南](https://spring.io/guides/gs/spring-boot-docker/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
