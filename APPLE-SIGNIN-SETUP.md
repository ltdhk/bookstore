# Sign in with Apple 完整配置指南

## 📋 概述

本指南将帮助你完成 Apple Sign In 的端到端配置，包括：
- Apple Developer Console 配置
- iOS/macOS App 配置
- Flutter 代码配置
- 后端服务配置

---

## 🍎 第一步：Apple Developer Console 配置

### 前置要求
- ✅ Apple Developer Program 账号（$99/年）
- ✅ Bundle ID: `com.novel.pop`

### 1.1 创建/配置 App ID

1. 访问 [Apple Developer Console](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 选择 **Identifiers** → 点击 **+** 按钮

#### 如果 App ID 已存在：
1. 找到并点击你的 Bundle ID: `com.novel.pop`
2. 在 **Capabilities** 中找到 **Sign in with Apple**
3. 勾选启用 ✅
4. 点击 **Save**

#### 如果 App ID 不存在：
1. 选择 **App IDs** → **Continue**
2. 选择 **App** → **Continue**
3. 填写：
   - **Description**: NovelPop App
   - **Bundle ID**: `com.novel.pop`
4. 在 **Capabilities** 中勾选 ✅ **Sign in with Apple**
5. **Continue** → **Register**

---

### 1.2 创建 Services ID（用于后端验证）

1. 在 **Identifiers** 页面，点击 **+**
2. 选择 **Services IDs** → **Continue**
3. 填写：
   - **Description**: NovelPop Backend Service
   - **Identifier**: `com.novel.pop.backend`
4. 勾选 ✅ **Sign in with Apple**
5. 点击 **Configure** 按钮

#### 配置域名和回调 URL：
- **Primary App ID**: 选择 `com.novel.pop`
- **Domains and Subdomains**:
  ```
  api.novelpop.com
  ```
  （如果使用 IP，需要先配置域名）

- **Return URLs**:
  ```
  https://api.novelpop.com/api/auth/apple/callback
  ```

6. **Save** → **Continue** → **Register**

---

### 1.3 创建密钥（Key）

1. 在左侧菜单选择 **Keys**
2. 点击 **+** 创建新密钥
3. 填写：
   - **Key Name**: NovelPop Sign in with Apple Key
4. 勾选 ✅ **Sign in with Apple**
5. 点击 **Configure**
6. 选择 **Primary App ID**: `com.novel.pop`
7. **Save** → **Continue** → **Register**

#### ⚠️ 重要 - 下载并保存密钥：
1. 点击 **Download** 下载 `.p8` 文件
   - 文件名格式：`AuthKey_XXXXXXXXXX.p8`
   - **只能下载一次！** 请妥善保存
2. 记录 **Key ID**（10位字符，如 `ABC123XYZ9`）
3. 复制到安全位置：
   ```bash
   # 示例
   cp ~/Downloads/AuthKey_ABC123XYZ9.p8 ~/.ssh/apple/
   chmod 600 ~/.ssh/apple/AuthKey_ABC123XYZ9.p8
   ```

---

### 1.4 获取 Team ID

**方式 1：从首页获取**
1. 访问 https://developer.apple.com/account/
2. 右上角查看 **Team ID**

**方式 2：从 Membership 页面**
1. 选择 **Membership**
2. 查看 **Team ID**（10位字符，如 `A1B2C3D4E5`）

---

## 📱 第二步：iOS/macOS App 配置

### 2.1 Xcode 配置

1. 打开 Xcode 项目：
   ```bash
   open App/ios/Runner.xcworkspace
   ```

2. 选择 **Runner** target
3. 选择 **Signing & Capabilities** 标签
4. 点击 **+ Capability**
5. 搜索并添加 **Sign in with Apple**
6. 确保 Bundle Identifier 是 `com.novel.pop`

### 2.2 验证配置

在 `Runner.entitlements` 中应该自动添加：
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

## 💻 第三步：Flutter App 配置

### 3.1 依赖包（已安装）

你的项目已经安装了 `sign_in_with_apple` 包，无需额外配置。

### 3.2 代码示例（参考）

查看现有实现：
- [lib/src/features/auth/data/apple_sign_in_service.dart](App/lib/src/features/auth/data/apple_sign_in_service.dart)
- [lib/src/features/auth/presentation/login_screen.dart](App/lib/src/features/auth/presentation/login_screen.dart)

基本流程：
```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// 1. 请求授权
final credential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

// 2. 发送到后端验证
final response = await dio.post('/api/auth/apple', data: {
  'identityToken': credential.identityToken,
  'authorizationCode': credential.authorizationCode,
  'user': credential.userIdentifier,
});
```

---

## 🖥️ 第四步：后端配置

### 4.1 准备配置信息

你需要以下三个关键信息：

| 配置项 | 说明 | 示例 |
|--------|------|------|
| **APPLE_TEAM_ID** | 团队ID，从 Membership 获取 | `A1B2C3D4E5` |
| **APPLE_KEY_ID** | 密钥ID，创建 Key 时显示 | `ABC123XYZ9` |
| **APPLE_CLIENT_ID** | App Bundle ID | `com.novel.pop` |

### 4.2 放置私钥文件

**开发环境**：
```bash
# 复制 .p8 文件到项目
cp ~/Downloads/AuthKey_ABC123XYZ9.p8 Backend/src/main/resources/

# 添加到 .gitignore（重要！）
echo "src/main/resources/AuthKey_*.p8" >> Backend/.gitignore
```

**生产环境**：
```bash
# 放到安全目录
sudo mkdir -p /opt/novelpop/keys
sudo cp AuthKey_ABC123XYZ9.p8 /opt/novelpop/keys/
sudo chmod 600 /opt/novelpop/keys/AuthKey_ABC123XYZ9.p8
sudo chown root:root /opt/novelpop/keys/AuthKey_ABC123XYZ9.p8
```

### 4.3 配置环境变量

编辑 `Backend/.env` 文件：

```bash
# Apple Sign In Configuration
APPLE_TEAM_ID=A1B2C3D4E5
APPLE_KEY_ID=ABC123XYZ9
APPLE_CLIENT_ID=com.novel.pop

# 私钥文件路径（可选，如果不放在 resources 目录）
# APPLE_PRIVATE_KEY_PATH=/opt/novelpop/keys/AuthKey_ABC123XYZ9.p8
```

### 4.4 验证后端配置

查看当前配置：
```bash
cat Backend/src/main/resources/application.yml | grep -A 5 "apple:"
```

应该看到：
```yaml
apple:
  signin:
    team-id: ${APPLE_TEAM_ID:your-team-id}
    key-id: ${APPLE_KEY_ID:your-key-id}
    client-id: ${APPLE_CLIENT_ID:com.novel.pop}
```

---

## 🧪 第五步：测试 Sign in with Apple

### 5.1 在 iOS 模拟器测试

1. 打开 iOS 模拟器的设置
2. 登录 iCloud 账号（需要真实的 Apple ID）
3. 运行 App 并点击 "Sign in with Apple"
4. 第一次会要求授权，选择分享或隐藏邮箱
5. 检查后端日志，确认收到 token

### 5.2 在真机测试

1. 确保设备已登录 Apple ID
2. 确保 App 使用正确的 Bundle ID
3. 使用开发证书签名
4. 运行并测试登录流程

### 5.3 验证后端接收

查看后端日志：
```bash
docker logs -f bookstore-backend | grep -i "apple"
```

或测试 API：
```bash
curl -X POST http://localhost:8090/api/auth/apple \
  -H "Content-Type: application/json" \
  -d '{
    "identityToken": "eyJhbGc...",
    "authorizationCode": "c1234...",
    "user": "001234.abc..."
  }'
```

---

## 📋 配置检查清单

### Apple Developer Console
- [ ] App ID 已创建并启用 Sign in with Apple
- [ ] Services ID 已创建并配置域名/回调URL
- [ ] Key 已创建并下载 .p8 文件
- [ ] 记录了 Team ID、Key ID

### iOS/macOS App
- [ ] Xcode 中添加了 Sign in with Apple capability
- [ ] Bundle ID 正确（com.novel.pop）
- [ ] Runner.entitlements 包含正确配置

### Flutter App
- [ ] sign_in_with_apple 包已安装
- [ ] 代码正确调用 Apple Sign In API
- [ ] 正确发送 token 到后端

### 后端服务
- [ ] .env 文件配置了 APPLE_TEAM_ID
- [ ] .env 文件配置了 APPLE_KEY_ID
- [ ] .env 文件配置了 APPLE_CLIENT_ID
- [ ] .p8 私钥文件已放置在安全位置
- [ ] 后端代码能正确读取 .p8 文件
- [ ] API 端点已实现并测试

---

## 🐛 常见问题

### Q1: "invalid_client" 错误

**原因**：Client ID 配置错误

**解决**：
1. 检查 `APPLE_CLIENT_ID` 是否正确
2. 确认使用的是 App Bundle ID，不是 Services ID
3. 对于 iOS App，应该是 `com.novel.pop`

### Q2: "invalid_grant" 错误

**原因**：Token 已过期或被使用过

**解决**：
- Authorization Code 只能使用一次
- 确保后端在 5 分钟内验证 token
- 检查系统时间是否正确

### Q3: 无法读取 .p8 私钥文件

**原因**：文件路径或权限问题

**解决**：
```bash
# 检查文件是否存在
ls -la Backend/src/main/resources/AuthKey_*.p8

# 检查文件权限
chmod 600 Backend/src/main/resources/AuthKey_*.p8

# 验证文件内容
cat Backend/src/main/resources/AuthKey_*.p8
# 应该看到 -----BEGIN PRIVATE KEY-----
```

### Q4: 模拟器无法登录 Apple ID

**原因**：模拟器需要真实的 Apple ID

**解决**：
1. 在模拟器的设置中登录真实的 Apple ID
2. 或者使用真机测试
3. 确保网络连接正常

### Q5: 域名验证失败

**原因**：使用了 IP 地址或未验证的域名

**解决**：
1. Apple 要求使用 HTTPS 和有效域名
2. 本地测试可以使用 ngrok 等工具创建临时域名
3. 生产环境必须使用正式域名和 SSL 证书

---

## 📚 相关资源

- [Apple Sign In 官方文档](https://developer.apple.com/sign-in-with-apple/)
- [sign_in_with_apple Flutter 包](https://pub.dev/packages/sign_in_with_apple)
- [Apple ID Token 验证指南](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user)

---

## 🔐 安全提示

1. **永远不要提交私钥文件到 Git**
   ```bash
   # 添加到 .gitignore
   echo "*.p8" >> .gitignore
   echo "AuthKey_*.p8" >> Backend/.gitignore
   ```

2. **生产环境使用严格的文件权限**
   ```bash
   chmod 600 /path/to/AuthKey_*.p8
   chown root:root /path/to/AuthKey_*.p8
   ```

3. **定期轮换密钥**
   - 建议每年更新一次 Sign in with Apple Key

4. **监控异常登录**
   - 记录所有 Apple Sign In 请求
   - 检测异常 token 使用模式

---

## ✅ 配置完成后

配置完成后，你应该能够：

1. ✅ 在 iOS App 中点击 "Sign in with Apple" 按钮
2. ✅ 看到 Apple 登录界面
3. ✅ 授权后获得 identity token
4. ✅ 后端成功验证 token 并创建用户会话
5. ✅ 用户成功登录到 App

祝配置顺利！🎉
