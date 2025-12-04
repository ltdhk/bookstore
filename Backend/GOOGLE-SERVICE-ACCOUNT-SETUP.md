# Google 服务账号 JSON 文件配置指南

本文档说明如何在 Docker 环境中配置 Google Play IAP 的服务账号 JSON 文件。

## 📁 文件位置

服务账号文件：`novelpopapp-cbbe32be7e85.json`

## 🔧 三种配置方案

### 方案 1：Volume 挂载外部文件 ⭐ **推荐**

**优点：**
- ✅ 密钥不打包进镜像（安全）
- ✅ 易于更新密钥文件
- ✅ 适合生产环境

**步骤：**

1. **确保文件在 Backend 目录下：**
   ```bash
   ls -la Backend/novelpopapp-cbbe32be7e85.json
   ```

2. **使用 docker-compose 启动：**
   ```bash
   cd Backend
   docker-compose up -d
   ```

3. **文件会自动挂载到容器的 `/app/config/` 目录**

4. **验证挂载：**
   ```bash
   docker exec bookstore-backend ls -l /app/config/
   ```

**docker-compose.yml 配置：**
```yaml
environment:
  GOOGLE_SERVICE_ACCOUNT_FILE: /app/config/novelpopapp-cbbe32be7e85.json
volumes:
  - ./novelpopapp-cbbe32be7e85.json:/app/config/novelpopapp-cbbe32be7e85.json:ro
```

---

### 方案 2：打包进镜像内

**优点：**
- ✅ 简单，无需额外配置
- ✅ 文件已包含在镜像中

**缺点：**
- ❌ 密钥泄露风险（镜像包含敏感信息）
- ❌ 更新密钥需要重新构建镜像

**当前状态：** 文件已自动打包（在 `src/main/resources/` 下）

**使用方式：**
```yaml
environment:
  GOOGLE_SERVICE_ACCOUNT_FILE: classpath:novelpopapp-cbbe32be7e85.json
```

**注意：** 不要将包含此文件的镜像推送到公共 Docker Registry！

---

### 方案 3：使用 Docker Secret（推荐用于 Docker Swarm）

**优点：**
- ✅ 最安全的方式
- ✅ 适合 Docker Swarm 集群

**步骤：**

1. **创建 Docker Secret：**
   ```bash
   docker secret create google_service_account novelpopapp-cbbe32be7e85.json
   ```

2. **在 docker-compose.yml 中使用：**
   ```yaml
   services:
     backend:
       secrets:
         - google_service_account
       environment:
         GOOGLE_SERVICE_ACCOUNT_FILE: /run/secrets/google_service_account

   secrets:
     google_service_account:
       external: true
   ```

---

## 🚀 生产环境部署建议

### AWS ECS / Fargate

使用 AWS Secrets Manager 或 Parameter Store：

```bash
# 上传到 Secrets Manager
aws secretsmanager create-secret \
  --name novelpop/google-service-account \
  --secret-string file://novelpopapp-cbbe32be7e85.json
```

在 ECS Task Definition 中：
```json
{
  "secrets": [
    {
      "name": "GOOGLE_SERVICE_ACCOUNT_JSON",
      "valueFrom": "arn:aws:secretsmanager:us-east-2:xxx:secret:novelpop/google-service-account"
    }
  ]
}
```

### Kubernetes

使用 Kubernetes Secret：

```bash
# 创建 Secret
kubectl create secret generic google-service-account \
  --from-file=key.json=novelpopapp-cbbe32be7e85.json

# 在 Pod 中挂载
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: backend
spec:
  containers:
  - name: backend
    image: your-backend-image
    env:
    - name: GOOGLE_SERVICE_ACCOUNT_FILE
      value: /secrets/key.json
    volumeMounts:
    - name: google-secret
      mountPath: /secrets
      readOnly: true
  volumes:
  - name: google-secret
    secret:
      secretName: google-service-account
EOF
```

---

## 🔍 验证配置

### 1. 检查文件是否可访问

```bash
# 进入容器
docker exec -it bookstore-backend sh

# 查看文件
ls -l /app/config/novelpopapp-cbbe32be7e85.json

# 查看环境变量
env | grep GOOGLE_SERVICE_ACCOUNT_FILE
```

### 2. 检查应用日志

```bash
docker logs bookstore-backend | grep -i "google"
```

应该看到类似：
```
INFO  c.b.config.GoogleApiConfig - AndroidPublisher initialized successfully
```

### 3. 测试 IAP 验证

使用 API 测试工具测试订阅验证端点：
```bash
curl -X POST http://localhost:8090/api/subscription/verify-google \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "productId": "monthly_svip",
    "purchaseToken": "test_token"
  }'
```

---

## 🛡️ 安全最佳实践

1. ✅ **永远不要** 将 JSON 文件提交到 Git 仓库
2. ✅ **永远不要** 将包含密钥的镜像推送到公共 Registry
3. ✅ 使用 `.gitignore` 排除 `*.json` 文件
4. ✅ 使用 `.dockerignore` 排除敏感文件（可选）
5. ✅ 在生产环境使用 Secrets Manager
6. ✅ 定期轮换服务账号密钥
7. ✅ 使用只读挂载（`:ro`）

---

## ❓ 常见问题

### Q: 如何知道文件是否已打包进镜像？

```bash
docker run --rm your-image ls -la /app/BOOT-INF/classes/
```

### Q: 如何从镜像中排除 JSON 文件？

添加到 `.dockerignore`：
```
*.json
!package.json  # 保留 package.json
```

### Q: 容器启动失败，提示找不到文件？

检查：
1. 文件路径是否正确
2. Volume 挂载路径是否匹配
3. 环境变量 `GOOGLE_SERVICE_ACCOUNT_FILE` 是否设置正确

### Q: 如何更新服务账号密钥？

**方案 1（Volume 挂载）：**
```bash
# 1. 替换主机上的文件
cp new-key.json novelpopapp-cbbe32be7e85.json

# 2. 重启容器
docker-compose restart backend
```

**方案 2（打包进镜像）：**
```bash
# 需要重新构建镜像
docker-compose build backend
docker-compose up -d backend
```

---

## 📝 相关文件

- `docker-compose.yml` - Docker Compose 配置
- `.env` - 环境变量
- `application.yml` - Spring Boot 配置
- `.dockerignore` - Docker 构建排除文件
- `Dockerfile` - Docker 镜像构建文件
