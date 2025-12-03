# Google Play 和 App Store 内购部署指南

本文档介绍如何部署和配置 Google Play 和 App Store 内购功能。

## 目录
- [概述](#概述)
- [前置要求](#前置要求)
- [Apple App Store 配置](#apple-app-store-配置)
- [Google Play 配置](#google-play-配置)
- [后端配置](#后端配置)
- [Webhook 配置](#webhook-配置)
- [测试](#测试)
- [常见问题](#常见问题)

---

## 概述

已实现的功能：
- ✅ 三档订阅产品（周卡、月卡、年卡）
- ✅ iOS App Store 内购
- ✅ Android Google Play 内购
- ✅ 服务器端收据验证
- ✅ 分销商佣金系统（30%）
- ✅ Webhook 处理（续订、取消、退款）
- ✅ 订阅事件跟踪

订阅产品定价：
- 周卡：$19.90（自动续订）
- 月卡：$49.99
- 年卡：$269.99

---

## 前置要求

### Apple 开发者账号
- [ ] Apple Developer Program 会员（$99/年）
- [ ] 应用已在 App Store Connect 中创建
- [ ] Bundle ID: `com.novel.pop`

### Google 开发者账号
- [ ] Google Play Console 访问权限（$25 一次性费用）
- [ ] 应用已在 Google Play Console 中创建
- [ ] Package Name: `com.novel.pop`

### 其他要求
- [ ] HTTPS 域名（用于 Webhook）
- [ ] 服务器部署环境
- [ ] Google Cloud Platform 账号（用于 Google Play API）

---

## Apple App Store 配置

### 1. 创建应用内购买产品

在 App Store Connect 中：

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 选择你的应用 **NovelPop**
3. 进入 **功能 > 应用内购买项目**
4. 点击 **+** 创建新产品

#### 产品 1: 周卡
- **类型**: 自动续期订阅
- **引用名称**: Weekly Subscription
- **产品 ID**: `com.novel.pop.weekly`
- **订阅群组**: NovelPop Subscriptions
- **订阅时长**: 1周
- **价格**: $19.99（选择价格等级）

#### 产品 2: 月卡
- **类型**: 自动续期订阅
- **引用名称**: Monthly Subscription
- **产品 ID**: `com.novel.pop.monthly`
- **订阅群组**: NovelPop Subscriptions（同一群组）
- **订阅时长**: 1个月
- **价格**: $49.99

#### 产品 3: 年卡
- **类型**: 自动续期订阅
- **引用名称**: Yearly Subscription
- **产品 ID**: `com.novel.pop.yearly`
- **订阅群组**: NovelPop Subscriptions（同一群组）
- **订阅时长**: 1年
- **价格**: $269.99

### 2. 配置 Shared Secret

1. 在 App Store Connect 中，进入 **用户和访问 > 共享的密钥**
2. 如果没有，点击 **生成共享的密钥**
3. 复制生成的密钥
4. 在后端配置中设置环境变量：
   ```bash
   export APPLE_SHARED_SECRET="your-shared-secret-here"
   ```

### 3. 配置 App Store Server Notifications

1. 在 App Store Connect 中，进入应用的 **App 信息**
2. 滚动到 **App Store Server Notifications**
3. 配置以下 URL：
   - **生产环境 URL**: `https://your-domain.com/api/webhook/apple`
   - **沙盒环境 URL**: `https://your-domain.com/api/webhook/apple`
4. 点击 **保存**

### 4. 配置测试账号

1. 在 App Store Connect 中，进入 **用户和访问 > 沙盒测试员**
2. 点击 **+** 创建测试账号
3. 填写邮箱和密码（虚拟邮箱即可）
4. 在测试设备上使用此账号登录

---

## Google Play 配置

### 1. 创建订阅产品

在 Google Play Console 中：

1. 登录 [Google Play Console](https://play.google.com/console/)
2. 选择应用 **NovelPop**
3. 进入 **获利 > 订阅**
4. 点击 **创建订阅**

#### 产品 1: 周卡
- **产品 ID**: `novelpop_weekly`
- **名称**: Weekly Subscription
- **说明**: Unlimited access for 1 week
- **计费周期**: 每 1 周
- **价格**: $19.99

#### 产品 2: 月卡
- **产品 ID**: `novelpop_monthly`
- **名称**: Monthly Subscription
- **说明**: Unlimited access for 1 month
- **计费周期**: 每 1 个月
- **价格**: $49.99

#### 产品 3: 年卡
- **产品 ID**: `novelpop_yearly`
- **名称**: Yearly Subscription
- **说明**: Unlimited access for 1 year - Best Value!
- **计费周期**: 每 1 年
- **价格**: $269.99

### 2. 配置 Google Cloud API

#### 2.1 启用 Google Play Android Developer API

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 进入 **API 和服务 > 库**
4. 搜索 "Google Play Android Developer API"
5. 点击 **启用**

#### 2.2 创建服务账号

1. 在 Google Cloud Console 中，进入 **IAM 和管理 > 服务账号**
2. 点击 **创建服务账号**
3. 名称：`novelpop-iap-backend`
4. 角色：（暂时不需要选择）
5. 点击 **完成**
6. 点击创建的服务账号
7. 进入 **密钥** 标签
8. 点击 **添加密钥 > 创建新密钥**
9. 选择 **JSON** 格式
10. 下载 JSON 文件，保存为 `google-service-account.json`

#### 2.3 关联服务账号到 Play Console

1. 在 Google Play Console 中，进入 **设置 > API 访问权限**
2. 如果尚未关联，点击 **关联** 将项目与 Play Console 关联
3. 在 **服务账号** 部分，找到刚创建的账号
4. 点击 **授予访问权限**
5. 选择以下权限：
   - **查看财务数据、订单和订阅取消调查回复**
   - **管理订单和订阅**
6. 点击 **应用**

### 3. 配置实时开发者通知 (RTDN)

#### 3.1 创建 Pub/Sub 主题

1. 在 Google Cloud Console 中，进入 **Pub/Sub > 主题**
2. 点击 **创建主题**
3. 主题 ID：`novelpop-iap-notifications`
4. 点击 **创建**

#### 3.2 创建推送订阅

1. 点击刚创建的主题
2. 进入 **订阅** 标签
3. 点击 **创建订阅**
4. 订阅 ID：`novelpop-webhook-subscription`
5. 传送类型：**推送**
6. 端点 URL：`https://your-domain.com/api/webhook/google`
7. 点击 **创建**

#### 3.3 在 Play Console 中配置

1. 在 Google Play Console 中，进入 **获利 > 获利设置**
2. 滚动到 **实时开发者通知**
3. 启用通知
4. 输入主题名称：`projects/your-project-id/topics/novelpop-iap-notifications`
5. 点击 **保存更改**

---

## 后端配置

### 1. 上传 Google 服务账号密钥

将下载的 `google-service-account.json` 放到以下位置：

```
Backend/src/main/resources/google-service-account.json
```

**重要**: 不要将此文件提交到 Git！确保 `.gitignore` 中包含：
```
google-service-account.json
*.json
```

### 2. 配置环境变量

在 `application.yml` 或环境变量中配置：

```yaml
iap:
  apple:
    production-url: https://buy.itunes.apple.com/verifyReceipt
    sandbox-url: https://sandbox.itunes.apple.com/verifyReceipt
    shared-secret: ${APPLE_SHARED_SECRET:your-apple-shared-secret}
    bundle-id: com.novel.pop
  google:
    package-name: com.novel.pop
    service-account-file: classpath:google-service-account.json
```

或通过环境变量：

```bash
export APPLE_SHARED_SECRET="your-apple-shared-secret"
export GOOGLE_SERVICE_ACCOUNT_FILE="/path/to/google-service-account.json"
```

### 3. 更新数据库

运行数据库迁移脚本：

```bash
mysql -u root -p bookstore < Backend/src/main/resources/db/migration_add_iap_tables.sql
```

这将创建：
- `subscription_events` 表（订阅事件）
- `distributor_commissions` 表（分销商佣金）
- 更新订阅产品价格

---

## Webhook 配置

### 1. 确保 HTTPS

Webhook 端点必须使用 HTTPS。建议使用：
- Nginx + Let's Encrypt SSL 证书
- Cloudflare
- AWS ALB/CloudFront

### 2. 测试 Webhook

#### Apple Webhook 测试

```bash
curl -X POST https://your-domain.com/api/webhook/apple \
  -H "Content-Type: application/json" \
  -d '{
    "notification_type": "TEST",
    "notification_uuid": "test-uuid-123",
    "data": {
      "app_apple_id": 123456789,
      "bundle_id": "com.novel.pop",
      "environment": "Sandbox"
    }
  }'
```

#### Google Webhook 测试

Google Play Console 会在配置 RTDN 时自动发送测试通知。

### 3. 监控 Webhook

检查应用日志：

```bash
tail -f Backend/logs/application.log | grep -i webhook
```

---

## 测试

### 沙盒测试流程

#### iOS 沙盒测试

1. **准备测试环境**
   - 在测试设备上退出 App Store 账号
   - 不要在设置中登录沙盒账号（在购买时登录）

2. **开始测试**
   - 运行应用（Debug 模式）
   - 打开订阅对话框
   - 选择订阅套餐
   - 点击订阅
   - 使用沙盒测试账号登录
   - 完成购买

3. **验证**
   - 检查应用是否显示订阅成功
   - 检查用户状态是否变为 SVIP
   - 检查后端日志是否显示收据验证成功

#### Android 沙盒测试

1. **添加测试账号**
   - 在 Google Play Console 中，进入 **设置 > 许可测试**
   - 添加测试邮箱地址

2. **安装测试版本**
   - 上传 APK 到内部测试轨道
   - 邀请测试账号
   - 在测试设备上从 Play Store 安装

3. **开始测试**
   - 运行应用
   - 打开订阅对话框
   - 选择订阅套餐
   - 完成购买（测试账号不会被扣款）

4. **验证**
   - 检查订阅状态
   - 检查后端收据验证
   - 测试取消订阅功能

### 测试清单

- [ ] iOS 沙盒购买成功
- [ ] Android 测试购买成功
- [ ] 收据验证成功
- [ ] 用户状态更新为 SVIP
- [ ] 订单创建成功
- [ ] 佣金计算正确（如果有分销商）
- [ ] Webhook 接收成功
- [ ] 订阅续订处理
- [ ] 订阅取消处理
- [ ] 退款处理

---

## 常见问题

### Q1: iOS 收据验证失败，返回 21002

**原因**: 可能使用了沙盒收据但调用了生产环境 API。

**解决方案**:
- 检查 `AppleReceiptVerificationService` 是否正确处理了 21007 错误码
- 确保代码会自动切换到沙盒环境

### Q2: Android 收据验证返回 401 Unauthorized

**原因**: 服务账号权限不足或 JSON 密钥文件配置错误。

**解决方案**:
1. 确认服务账号已在 Play Console 中授权
2. 确认 JSON 文件路径正确
3. 检查权限是否包含 "查看财务数据" 和 "管理订单"

### Q3: Webhook 没有收到通知

**原因**:
- Webhook URL 不可访问
- HTTPS 证书问题
- URL 配置错误

**解决方案**:
1. 确认 URL 可以从公网访问
2. 使用 SSL Labs 测试证书有效性
3. 检查 Apple/Google 配置中的 URL 是否正确
4. 查看服务器日志确认是否收到请求

### Q4: 订阅产品在应用中无法加载

**原因**:
- 产品 ID 不匹配
- 产品未批准
- 应用未签名或使用错误的 Bundle ID

**解决方案**:
1. 检查产品 ID 在 `PlatformProductConfig` 中是否正确
2. 确认产品已在 App Store Connect/Play Console 中批准
3. 确认应用的 Bundle ID/Package Name 正确

### Q5: 佣金计算不正确

**原因**: 可能是价格配置或计算逻辑问题。

**解决方案**:
1. 检查数据库中的产品价格是否正确
2. 验证 `SubscriptionServiceImpl` 中的佣金计算逻辑（30%）
3. 检查 `distributor_commissions` 表中的记录

---

## 生产环境部署清单

### 上线前检查

- [ ] 所有订阅产品已在 App Store Connect 和 Google Play Console 中创建并批准
- [ ] Apple Shared Secret 已配置
- [ ] Google 服务账号 JSON 已上传并配置
- [ ] Webhook URL 已配置并测试
- [ ] 数据库迁移已运行
- [ ] 所有测试通过
- [ ] 日志监控已配置
- [ ] 错误告警已配置

### 监控指标

建议监控以下指标：
- 订阅购买成功率
- 收据验证失败率
- Webhook 处理成功率
- 订阅续订率
- 退款率
- 佣金计算准确性

### 备份和回滚

- 定期备份 `orders` 和 `subscription_events` 表
- 保存所有 Webhook 通知数据以便审计
- 准备回滚计划以防出现问题

---

## 联系支持

- **Apple Developer Support**: https://developer.apple.com/support/
- **Google Play Support**: https://support.google.com/googleplay/android-developer/
- **技术文档**:
  - Apple: https://developer.apple.com/documentation/storekit
  - Google: https://developer.android.com/google/play/billing

---

**文档版本**: 1.0
**最后更新**: 2025-12-03
