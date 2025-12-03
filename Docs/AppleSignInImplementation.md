# Apple Sign In 实施总结

## 完成时间
2024年

## 实施范围
仅 iOS 平台，支持邮箱相同时自动合并账号

---

## 已完成的修改

### 后端 (Spring Boot)

#### 1. 依赖添加
**文件**: `Backend/pom.xml`
- 添加 `nimbus-jose-jwt:9.37.3` 用于验证 Apple JWT Token

#### 2. 数据库迁移
**文件**: `Backend/src/main/resources/db/migration_add_apple_signin.sql`
```sql
ALTER TABLE `users`
ADD COLUMN `apple_user_id` varchar(255) DEFAULT NULL;
ADD UNIQUE KEY `uk_apple_user_id` (`apple_user_id`);
```

**执行方法**: 需要手动在数据库中运行此 SQL 脚本

#### 3. 实体更新
**文件**: `Backend/src/main/java/com/bookstore/entity/User.java`
- 添加 `appleUserId` 字段

#### 4. 配置文件
**文件**: `Backend/src/main/resources/application.yml`
```yaml
apple:
  signin:
    team-id: ${APPLE_TEAM_ID:your-team-id}
    key-id: ${APPLE_KEY_ID:your-key-id}
    client-id: ${APPLE_CLIENT_ID:com.bookstore.app}
```

**需要设置的环境变量**:
- `APPLE_TEAM_ID`: Apple Team ID (从 Apple Developer Portal 获取)
- `APPLE_KEY_ID`: 创建的 Key ID
- `APPLE_CLIENT_ID`: iOS Bundle ID

#### 5. 新增文件
- `config/AppleSignInConfig.java` - 配置类
- `dto/AppleSignInRequest.java` - 请求 DTO
- `service/AppleSignInService.java` - 服务接口
- `service/impl/AppleSignInServiceImpl.java` - 服务实现

**核心逻辑** (AppleSignInServiceImpl):
1. 从 `https://appleid.apple.com/auth/keys` 获取 Apple 公钥
2. 验证 JWT Token 签名、过期时间、issuer、audience
3. 按以下顺序查找/创建用户：
   - 先按 `apple_user_id` 查找
   - 如未找到且有 email，按 email 查找并绑定 Apple ID
   - 仍未找到则创建新用户

#### 6. 控制器更新
**文件**: `Backend/src/main/java/com/bookstore/controller/AuthController.java`
- 添加 `POST /api/v1/auth/apple` 端点

---

### Flutter App

#### 1. 依赖添加
**文件**: `App/pubspec.yaml`
- 添加 `sign_in_with_apple: ^6.1.2`

#### 2. iOS 配置
**文件**: `App/ios/Runner/Runner.entitlements` (新建)
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

**额外步骤**: 在 Xcode 中打开项目，在 Signing & Capabilities 中添加 "Sign in with Apple" capability

#### 3. 新增文件
- `lib/src/features/auth/data/models/apple_sign_in_request.dart` - 请求模型
- `lib/src/features/auth/data/apple_sign_in_service.dart` - Apple 登录服务

**核心功能** (AppleSignInService):
- 生成随机 nonce 并 SHA256 哈希
- 调用原生 Apple Sign In API
- 处理各种错误情况（取消、失败等）
- 返回 identityToken、email、fullName

#### 4. 修改文件
- `lib/src/features/auth/data/auth_api_service.dart` - 添加 `loginWithApple()` 方法
- `lib/src/features/auth/providers/auth_provider.dart` - 添加 `loginWithApple()` 方法
- `lib/src/features/auth/presentation/login_screen.dart` - 添加 Apple 登录按钮

**登录按钮**: 仅在 iOS 设备上显示，使用 `Platform.isIOS` 判断

---

## Apple Developer Console 配置步骤

### 1. 创建 App ID
1. 访问 [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. 创建新 App ID
3. Bundle ID 设置为 `com.bookstore.app` (或你的实际 Bundle ID)
4. 启用 "Sign in with Apple" capability

### 2. 创建 Key
1. 在 Keys 页面创建新 key
2. 启用 "Sign in with Apple"
3. 下载 `.p8` 文件 (只能下载一次，请妥善保存)
4. 记录 Key ID

### 3. 获取 Team ID
在 Apple Developer Portal 右上角可以看到 Team ID (10位字符)

### 4. 配置后端环境变量
```bash
export APPLE_TEAM_ID=XXXXXXXXXX
export APPLE_KEY_ID=YYYYYYYYYY
export APPLE_CLIENT_ID=com.bookstore.app
```

或在部署环境中设置对应的环境变量

---

## 测试步骤

### 前置条件
1. ✅ 数据库已执行迁移脚本
2. ✅ 后端环境变量已配置
3. ✅ Xcode 项目中已添加 Sign in with Apple capability
4. ✅ 使用真实 iOS 设备或 iOS 13+ 模拟器

### 测试流程
1. 启动后端服务
2. 在 iOS 设备/模拟器上运行 Flutter App
3. 进入登录页面
4. 点击 "Sign in with Apple" 按钮
5. 系统弹出 Apple 登录弹窗
6. 使用 Apple ID 登录（Face ID/Touch ID/密码）
7. 首次登录会询问是否分享邮箱和姓名
8. 登录成功后跳转到首页

### 验证账号合并
1. 先用邮箱注册账号 (例如: test@example.com)
2. 登出
3. 使用相同邮箱的 Apple ID 登录
4. 应该能登录到同一个账号（数据库中 `apple_user_id` 被绑定到现有账号）

---

## 注意事项

### Email 和 Name 仅首次提供
Apple 只在用户**第一次授权**时提供 email 和 full name。后续登录这些字段为 null。

**解决方案**: 后端在首次登录时保存 email 和 nickname，后续登录从数据库读取。

### Private Relay Email
Apple 可能返回隐私中继邮箱 (例如: `xxx@privaterelay.appleid.com`)，这种邮箱无法与普通邮箱匹配。

**影响**: 如果用户先用普通邮箱注册，后用 Apple 登录但选择"隐藏邮箱"，则会创建新账号，无法自动合并。

### Token 验证
后端每次都从 Apple 服务器获取最新的公钥来验证 JWT，确保安全性。Apple 会定期轮换密钥。

### 测试限制
- Apple Sign In 需要真实设备或 iOS 13+ 模拟器
- 需要有效的 Apple Developer 账号
- 模拟器可以使用任意 iCloud 测试账号

---

## 故障排查

### 问题: "Apple Sign In is not available"
**原因**:
- 设备不支持 (需要 iOS 13+)
- 未在 Xcode 中添加 Sign in with Apple capability
- Entitlements 文件未正确配置

**解决**: 检查 iOS 版本、Xcode capability 设置、entitlements 文件

### 问题: "Invalid token audience"
**原因**: `APPLE_CLIENT_ID` 配置错误，与 iOS Bundle ID 不匹配

**解决**: 检查 `application.yml` 中的 `client-id` 是否与 iOS Bundle ID 一致

### 问题: 后端报错 "Failed to verify Apple identity token"
**原因**:
- 网络问题，无法访问 `https://appleid.apple.com/auth/keys`
- Token 过期
- Token 被篡改

**解决**: 检查服务器网络、查看详细错误日志

### 问题: 数据库错误 "Unknown column 'apple_user_id'"
**原因**: 数据库迁移脚本未执行

**解决**: 运行 `Backend/src/main/resources/db/migration_add_apple_signin.sql`

---

## 未来改进建议

1. **缓存 Apple 公钥**: 目前每次验证都获取公钥，可以添加带 TTL 的缓存
2. **Nonce 验证**: 可以在后端存储已使用的 nonce，防止重放攻击
3. **Android/Web 支持**: 需要配置 Services ID 和 Web 回调
4. **日志记录**: 增加详细的审计日志记录 Apple 登录事件
5. **错误处理**: 更细粒度的错误提示

---

## 文件清单

### 后端新增文件
- `Backend/pom.xml` (修改)
- `Backend/src/main/resources/application.yml` (修改)
- `Backend/src/main/resources/db/migration_add_apple_signin.sql` (新建)
- `Backend/src/main/java/com/bookstore/entity/User.java` (修改)
- `Backend/src/main/java/com/bookstore/config/AppleSignInConfig.java` (新建)
- `Backend/src/main/java/com/bookstore/dto/AppleSignInRequest.java` (新建)
- `Backend/src/main/java/com/bookstore/service/AppleSignInService.java` (新建)
- `Backend/src/main/java/com/bookstore/service/impl/AppleSignInServiceImpl.java` (新建)
- `Backend/src/main/java/com/bookstore/controller/AuthController.java` (修改)

### Flutter 新增/修改文件
- `App/pubspec.yaml` (修改)
- `App/ios/Runner/Runner.entitlements` (新建)
- `App/lib/src/features/auth/data/models/apple_sign_in_request.dart` (新建)
- `App/lib/src/features/auth/data/apple_sign_in_service.dart` (新建)
- `App/lib/src/features/auth/data/auth_api_service.dart` (修改)
- `App/lib/src/features/auth/providers/auth_provider.dart` (修改)
- `App/lib/src/features/auth/presentation/login_screen.dart` (修改)

---

## 下一步

1. ✅ 代码已全部实现
2. ⏭️ 在 Apple Developer Console 完成配置
3. ⏭️ 配置后端环境变量
4. ⏭️ 执行数据库迁移脚本
5. ⏭️ 在 Xcode 中添加 Sign in with Apple capability
6. ⏭️ 在真实设备上测试功能
