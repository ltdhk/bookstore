# BookStore 项目部署文档

## 项目概述

BookStore 是一个完整的在线书店系统，包含以下三个主要部分：
- **Backend**: Spring Boot 后端服务（Java）
- **Admin**: React 管理后台（TypeScript + Vite）
- **App**: Flutter 移动应用

---

## 目录

1. [环境要求](#环境要求)
2. [后端部署 (Backend)](#后端部署-backend)
3. [管理后台部署 (Admin)](#管理后台部署-admin)
4. [移动应用部署 (App)](#移动应用部署-app)
5. [AWS S3 配置](#aws-s3-配置)
6. [常见问题](#常见问题)

---

## 环境要求

### 后端环境
- **Java**: JDK 17 或更高版本
- **Maven**: 3.6+
- **MySQL**: 8.0+
- **IDE**: IntelliJ IDEA / Eclipse（可选）

### 管理后台环境
- **Node.js**: 18.0+ 或更高版本
- **npm**: 9.0+ 或 pnpm/yarn

### 移动应用环境
- **Flutter**: 3.0+
- **Dart**: 3.0+
- **Android Studio** / **Xcode**（用于模拟器或真机调试）

---

## 后端部署 (Backend)

### 1. 数据库配置

#### 创建数据库
```sql
CREATE DATABASE bookdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 执行数据库脚本
数据库表会在首次启动时自动创建（通过 `schema.sql`），或手动执行：
```bash
mysql -u root -p bookdb < Backend/src/main/resources/db/schema.sql
```

### 2. 配置文件

编辑 `Backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/bookdb?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root           # 修改为你的数据库用户名
    password: your_password  # 修改为你的数据库密码

jwt:
  secret: 4d5354384e6e465344577563423234664d445a74675775684e326c46566a4d32
  expiration: 86400000 # 24小时

aws:
  s3:
    access-key: YOUR_AWS_ACCESS_KEY      # AWS Access Key
    secret-key: YOUR_AWS_SECRET_KEY      # AWS Secret Key
    region: ap-southeast-1               # AWS 区域
    bucket-name: bookstore-images        # S3 桶名称
```

### 3. 安装依赖

使用 Maven 安装依赖：
```bash
cd Backend
mvn clean install
```

### 4. 启动后端服务

#### 方式一：使用 Maven
```bash
mvn spring-boot:run
```

#### 方式二：使用 IDE
在 IntelliJ IDEA 或 Eclipse 中：
1. 导入项目为 Maven 项目
2. 找到 `com.bookstore.BookStoreApplication` 主类
3. 右键运行 `Run 'BookStoreApplication'`

#### 方式三：打包运行
```bash
mvn clean package
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

### 5. 验证后端服务

访问 `http://localhost:8080/api/admin/auth/login`，应该能看到后端服务响应。

**默认管理员账户**（需要在数据库中手动创建或通过脚本初始化）：
- 用户名: `admin`
- 密码: `admin123`

---

## 管理后台部署 (Admin)

### 1. 安装依赖

```bash
cd Admin
npm install
# 或使用 pnpm
pnpm install
# 或使用 yarn
yarn install
```

### 2. 配置代理

编辑 `Admin/vite.config.ts`，确保代理配置正确：

```typescript
server: {
  port: 5173,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',  // 后端服务地址
      changeOrigin: true,
    }
  }
}
```

### 3. 启动开发服务器

```bash
npm run dev
# 或
pnpm dev
# 或
yarn dev
```

访问 `http://localhost:5173` 即可打开管理后台。

### 4. 构建生产版本

```bash
npm run build
# 输出目录: Admin/dist
```

构建后的静态文件可以部署到 Nginx、Apache 或任何静态文件服务器。

---

## 移动应用部署 (App)

### 1. 安装依赖

```bash
cd App
flutter pub get
```

### 2. 配置 API 地址

编辑 `App/lib/src/services/networking/dio_provider.dart`，修改后端 API 地址：

```dart
final baseUrl = 'http://localhost:8080/api';  // 开发环境
// final baseUrl = 'https://your-production-api.com/api';  // 生产环境
```

**注意**：
- Android 模拟器访问本机：使用 `http://10.0.2.2:8080/api`
- iOS 模拟器访问本机：使用 `http://localhost:8080/api`
- 真机访问：使用你的电脑 IP 地址，如 `http://192.168.1.100:8080/api`

### 3. 运行应用

#### 启动模拟器/连接设备
```bash
# 查看可用设备
flutter devices

# 启动 Android 模拟器
flutter emulators
flutter emulators --launch <emulator_id>
```

#### 运行应用
```bash
flutter run
# 或指定设备
flutter run -d <device_id>
```

### 4. 构建应用

#### Android APK
```bash
flutter build apk
# 输出: App/build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (推荐用于 Google Play)
```bash
flutter build appbundle
```

#### iOS (需要 macOS)
```bash
flutter build ios
# 然后在 Xcode 中打开 App/ios/Runner.xcworkspace 进行签名和发布
```

---

## AWS S3 配置

用于存储书籍封面图片和其他静态资源。

### 1. 创建 S3 存储桶

1. 登录 [AWS 管理控制台](https://console.aws.amazon.com/)
2. 进入 S3 服务
3. 点击 "Create bucket"
4. 配置：
   - **Bucket name**: `bookstore-images`（或自定义名称）
   - **Region**: `ap-southeast-1`（新加坡）或就近区域
   - **Object Ownership**: 选择 "ACLs enabled"
   - **Block Public Access**: 取消勾选 "Block all public access"
   - 确认警告并创建

### 2. 配置存储桶策略

在创建的存储桶中，进入 "Permissions" → "Bucket policy"，添加以下策略：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bookstore-images/*"
        }
    ]
}
```

### 3. 配置 CORS

在 "Permissions" → "CORS"，添加以下配置：

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
        "AllowedOrigins": ["*"],
        "ExposeHeaders": ["ETag"]
    }
]
```

### 4. 创建 IAM 用户

1. 进入 IAM 服务
2. 创建新用户：`bookstore-s3-uploader`
3. 附加策略：`AmazonS3FullAccess` 或自定义策略：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::bookstore-images/*"
        }
    ]
}
```

4. 创建访问密钥，记录 **Access Key** 和 **Secret Key**
5. 在 `application.yml` 中填入这些密钥

---

## 快速启动命令汇总

### 后端
```bash
cd Backend
mvn spring-boot:run
```

### 管理后台
```bash
cd Admin
npm install
npm run dev
```

### 移动应用
```bash
cd App
flutter pub get
flutter run
```

---

## 常见问题

### 1. 后端启动失败

**问题**: `No static resource api/admin/books` 或 404 错误
**解决**:
- 检查 Controller 类是否有 `package` 声明
- 运行 `mvn clean install` 重新编译
- 检查 `@RestController` 和 `@RequestMapping` 注解是否正确

**问题**: 数据库连接失败
**解决**:
- 检查 MySQL 服务是否启动
- 验证 `application.yml` 中的数据库配置
- 确认数据库 `bookdb` 已创建

### 2. 管理后台启动失败

**问题**: API 请求 404
**解决**:
- 确认后端服务已启动（端口 8080）
- 检查 `vite.config.ts` 中的代理配置
- 检查浏览器控制台网络请求

**问题**: React Quill 错误（findDOMNode）
**解决**: 已使用 TextArea 替代，无需处理

### 3. 移动应用问题

**问题**: 无法连接后端 API
**解决**:
- Android 模拟器使用 `10.0.2.2:8080`
- iOS 模拟器使用 `localhost:8080`
- 真机使用电脑 IP 地址
- 确保防火墙允许端口 8080

**问题**: Flutter 依赖安装失败
**解决**:
```bash
flutter clean
flutter pub get
```

### 4. AWS S3 上传失败

**问题**: 权限错误
**解决**:
- 检查 IAM 用户是否有 S3 权限
- 验证 Access Key 和 Secret Key 是否正确
- 检查存储桶策略是否允许 PutObject

**问题**: 图片无法访问
**解决**:
- 确认存储桶的 "Block Public Access" 已关闭
- 检查对象 ACL 是否设置为 public-read
- 验证存储桶策略允许 GetObject

---

## 技术栈

### 后端
- Spring Boot 3.2.3
- MyBatis-Plus 3.5.5
- MySQL 8.0
- JWT Authentication
- AWS S3 SDK

### 管理后台
- React 19
- TypeScript
- Ant Design 5.29.1
- Vite 7.2.4
- Axios

### 移动应用
- Flutter 3.0+
- Dart 3.0+
- Go Router
- Riverpod

---

## 端口占用

- **后端服务**: 8080
- **管理后台**: 5173 (开发环境)
- **数据库**: 3306

---

## 联系方式

如有问题，请提交 Issue 或联系项目维护者。

---

## 许可证

[MIT License](../LICENSE)


ssh -i C:\path\to\private_key.pem user@192.168.1.1

ssh -i C:\Users\ltdhk\Documents\DevTools\novelpop_key.pem ec2-user@18.189.33.139




# 创建挂载目录
mkdir -p /home/nginx/conf
mkdir -p /home/nginx/log
mkdir -p /home/nginx/html

# 生成容器
docker run --name nginx -p 9001:80 -d nginx
# 将容器nginx.conf文件复制到宿主机
docker cp nginx:/etc/nginx/nginx.conf /home/nginx/conf/nginx.conf
# 将容器conf.d文件夹下内容复制到宿主机
docker cp nginx:/etc/nginx/conf.d /home/nginx/conf/conf.d
# 将容器中的html文件夹复制到宿主机
docker cp nginx:/usr/share/nginx/html /home/nginx/




# 直接执行docker rm nginx或者以容器id方式关闭容器
# 找到nginx对应的容器id
docker ps -a
# 关闭该容器
docker stop novelpop-nginx
# 删除该容器
docker rm novelpop-nginx
 
# 删除正在运行的nginx容器
docker rm -f novelpop-nginx


docker run \
-p 9002:80 \
--name novelpop-nginx \
-v /home/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /home/nginx/conf/conf.d:/etc/nginx/conf.d \
-v /home/nginx/log:/var/log/nginx \
-v /home/nginx/html:/usr/share/nginx/html \
-d nginx:latest


# 4. 启动正式的 Nginx 容器
docker run \
  -p 81:80 \
  -p 4433:443 \
  --name novelpop-nginx \
  -v /home/ec2-user/docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
  -v /home/ec2-user/docker/nginx/conf/conf.d:/etc/nginx/conf.d \
  -v /home/ec2-user/docker/nginx/log:/var/log/nginx \
  -v /home/ec2-user/docker/nginx/html:/usr/share/nginx/html \
  -v /home/ec2-user/docker/nginx/ssl:/etc/nginx/ssl:ro \
  -v /home/ec2-user/docker/nginx/certbot:/var/www/certbot:ro \
  --restart unless-stopped \
  -d nginx:latest



# 5. 测试配置
docker exec novelpop-nginx nginx -t

# 6. 重载配置
docker exec novelpop-nginx nginx -s reload

# 7. 查看日志
docker logs -f novelpop-nginx
tail -f /home/nginx/log/access.log
tail -f /home/nginx/log/error.log


# 后端运行
docker run -d \
  --name novelpop-backend \
  -p 8090:8090 \
  -e SPRING_PROFILES_ACTIVE=docker \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://<DB_HOST>:<DB_PORT>/novelpop_db?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai" \
  -e SPRING_DATASOURCE_USERNAME=<DB_USERNAME> \
  -e SPRING_DATASOURCE_PASSWORD=<DB_PASSWORD> \
  -e AWS_ACCESS_KEY=<YOUR_AWS_ACCESS_KEY> \
  -e AWS_SECRET_KEY=<YOUR_AWS_SECRET_KEY> \
  -e APPLE_SHARED_SECRET=<YOUR_APPLE_SHARED_SECRET> \
  -v /home/ec2-user/docker/backend/logs:/app/logs \
  ltdhk/novelpop-backend:latest

docker logs -f novelpop-backend


docker stop novelpop-backend
docker rm novelpop-backend


flutter build appbundle --release

flutter build apk --release

flutter run --release -d MQS0219815035438
flutter logs -d MQS0219815035438


