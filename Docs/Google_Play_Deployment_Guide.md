# Google Play 部署指南 - 打包和上传 App Bundle

本文档介绍如何打包 Android App Bundle (AAB) 并上传到 Google Play Console。

## 目录
- [前置准备](#前置准备)
- [生成签名密钥](#生成签名密钥)
- [配置签名](#配置签名)
- [打包 App Bundle](#打包-app-bundle)
- [上传到 Google Play](#上传到-google-play)
- [内购配置](#内购配置)
- [常见问题](#常见问题)

---

## 前置准备

### 必需条件
- ✅ Google Play Console 开发者账号（$25 一次性费用）
- ✅ 应用已创建：Package Name = `com.novel.pop`
- ✅ Flutter SDK 已安装
- ✅ Java JDK 已安装

### 检查版本

```bash
# 检查 Flutter 版本
flutter --version

# 检查 Java 版本
java -version
```

---

## 生成签名密钥

### 1. 创建签名密钥

在命令行运行：

```bash
cd App/android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. 填写密钥信息

系统会提示输入以下信息：

```
Enter keystore password: [输入密码，例如: MyStrongPassword123]
Re-enter new password: [再次输入密码]
What is your first and last name?
  [Unknown]: Novel Pop
What is the name of your organizational unit?
  [Unknown]: Development
What is the name of your organization?
  [Unknown]: Novel Pop Inc
What is the name of your City or Locality?
  [Unknown]: San Francisco
What is the name of your State or Province?
  [Unknown]: CA
What is the two-letter country code for this unit?
  [Unknown]: US
Is CN=Novel Pop, OU=Development, O=Novel Pop Inc, L=San Francisco, ST=CA, C=US correct?
  [no]: yes

Enter key password for <upload>
  (RETURN if same as keystore password): [直接回车或输入不同密码]
```

**重要提示**：
- 请妥善保管密钥库密码和密钥密码
- 如果丢失，将无法更新应用
- 建议使用密码管理器保存

---

## 配置签名

### 1. 创建 key.properties 文件

在 `App/android/` 目录下创建 `key.properties` 文件：

```bash
cd App/android
touch key.properties
```

内容如下：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=upload
storeFile=app/upload-keystore.jks
```

### 2. 添加到 .gitignore

⚠️ **关键安全步骤** - 确保密钥文件不会提交到 Git：

在 `App/android/.gitignore` 中添加：

```gitignore
# 签名密钥文件
key.properties
*.jks
*.keystore
upload-keystore.jks
```

在 `App/.gitignore` 中添加：

```gitignore
# Android signing keys
android/key.properties
android/app/upload-keystore.jks
```

### 3. 创建 ProGuard 规则（可选）

创建 `App/android/app/proguard-rules.pro` 文件：

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Sign In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# In-App Purchase
-keep class com.android.billingclient.api.** { *; }
```

---

## 打包 App Bundle

### 1. 清理项目

```bash
cd App
flutter clean
flutter pub get
```

### 2. 构建 App Bundle

```bash
# 构建 release 版本的 App Bundle
flutter build appbundle --release

# 如果需要指定版本号和构建号
flutter build appbundle --release --build-name=1.0.0 --build-number=1
```

### 3. 验证构建结果

构建成功后，App Bundle 位于：

```
App/build/app/outputs/bundle/release/app-release.aab
```

检查文件大小：

```bash
ls -lh App/build/app/outputs/bundle/release/app-release.aab
```

### 4. 测试 App Bundle（可选）

使用 bundletool 测试：

```bash
# 下载 bundletool
wget https://github.com/google/bundletool/releases/download/1.15.6/bundletool-all-1.15.6.jar

# 从 AAB 生成 APK
java -jar bundletool-all-1.15.6.jar build-apks \
  --bundle=App/build/app/outputs/bundle/release/app-release.aab \
  --output=app.apks \
  --mode=universal

# 解压 APK
unzip app.apks -d apks

# 安装到设备
adb install apks/universal.apk
```

---

## 上传到 Google Play

### 方法 1: 通过 Google Play Console（推荐）

#### 1. 登录 Google Play Console

访问：https://play.google.com/console/

#### 2. 选择应用

- 点击 **NovelPop** 应用
- 如果是新应用，点击 **创建应用**

#### 3. 上传 App Bundle

**对于内部测试**：
1. 左侧菜单选择 **测试 > 内部测试**
2. 点击 **创建新版本**
3. 上传 `app-release.aab`
4. 填写版本说明
5. 点击 **保存**
6. 点击 **审核版本**
7. 点击 **开始向内部测试轨道推出**

**对于生产环境**：
1. 左侧菜单选择 **生产**
2. 点击 **创建新版本**
3. 上传 `app-release.aab`
4. 填写版本说明（支持多语言）
5. 完成内容分级、目标受众等信息
6. 点击 **审核版本**
7. 点击 **开始向生产环境推出**

#### 4. 首次发布额外步骤

如果是首次发布，需要完成：

**应用信息**：
- [ ] 应用图标（512x512 PNG）
- [ ] 功能图片（1024x500 JPG/PNG）
- [ ] 应用说明（简短和完整）
- [ ] 应用分类
- [ ] 联系方式

**图形资源**：
- [ ] 至少 2 张手机截图（最多 8 张）
- [ ] 7 英寸平板截图（可选）
- [ ] 10 英寸平板截图（可选）

**内容分级**：
- [ ] 完成内容分级问卷

**定价和分发**：
- [ ] 选择国家/地区
- [ ] 设置为免费或付费
- [ ] 同意内容政策

---

## 内购配置

### 1. 创建订阅产品

在 Google Play Console 中：

1. 选择应用 **NovelPop**
2. 左侧菜单选择 **获利 > 订阅**
3. 点击 **创建订阅**

#### 产品 1: 周卡
```
产品 ID: novelpop_weekly
名称: Weekly Subscription
说明: Unlimited access to all novels for 1 week
计费周期: 每 1 周
免费试用: 3 天（可选）
宽限期: 3 天
价格: $19.99
```

#### 产品 2: 月卡
```
产品 ID: novelpop_monthly
名称: Monthly Subscription
说明: Unlimited access to all novels for 1 month
计费周期: 每 1 个月
免费试用: 7 天（可选）
宽限期: 3 天
价格: $49.99
```

#### 产品 3: 年卡
```
产品 ID: novelpop_yearly
名称: Yearly Subscription (Best Value!)
说明: Unlimited access to all novels for 1 year - Save 50%
计费周期: 每 1 年
免费试用: 7 天（可选）
宽限期: 3 天
价格: $269.99
```

### 2. 配置 Google Play Billing

详细配置请参考 [IAP_Deployment_Guide.md](./IAP_Deployment_Guide.md)

---

## 更新应用版本

### 1. 修改版本号

编辑 `App/pubspec.yaml`：

```yaml
version: 1.0.1+2  # 格式: version+buildNumber
```

或者使用命令行：

```bash
flutter build appbundle --release --build-name=1.0.1 --build-number=2
```

### 2. 重新构建和上传

```bash
cd App
flutter clean
flutter pub get
flutter build appbundle --release
```

### 3. 上传新版本

按照上述步骤上传到 Google Play Console。

---

## 常见问题

### Q1: 构建失败 - "Execution failed for task ':app:signReleaseBundle'"

**原因**: 签名配置错误或密钥文件找不到。

**解决方案**:
1. 检查 `key.properties` 文件路径是否正确
2. 确认密钥库密码和密钥密码正确
3. 检查 `upload-keystore.jks` 是否存在

### Q2: 上传后显示 "此版本已存在"

**原因**: versionCode 相同。

**解决方案**:
增加 `pubspec.yaml` 中的 buildNumber：
```yaml
version: 1.0.0+2  # +后面的数字必须递增
```

### Q3: Google Play 审核被拒 - "权限使用说明不足"

**原因**: 应用使用了敏感权限但未提供说明。

**解决方案**:
1. 在 Play Console 中，进入 **应用内容 > 应用访问权限**
2. 为每个权限提供使用说明

### Q4: AAB 文件大小太大

**原因**: 包含了不必要的资源或未启用代码压缩。

**解决方案**:
1. 确保 `build.gradle.kts` 中启用了：
   ```kotlin
   minifyEnabled = true
   shrinkResources = true
   ```
2. 使用 WebP 格式压缩图片
3. 移除未使用的依赖

### Q5: 在部分设备上无法安装

**原因**: 可能是 minSdkVersion 设置太高。

**解决方案**:
检查 `build.gradle.kts` 中的 minSdk：
```kotlin
minSdk = 21  // 支持 Android 5.0 及以上
```

### Q6: 签名密钥丢失了怎么办？

**解决方案**:
- **使用 Play App Signing**（推荐）: Google 会为你管理签名密钥
- 如果未使用 Play App Signing 且密钥丢失，将无法更新应用

**启用 Play App Signing**:
1. 在 Play Console 中，进入 **设置 > 应用完整性**
2. 选择 **Play 应用签名**
3. 按照说明上传签名密钥

---

## 自动化部署（高级）

### 使用 fastlane

安装 fastlane：
```bash
sudo gem install fastlane -NV
```

创建 `App/android/fastlane/Fastfile`：
```ruby
default_platform(:android)

platform :android do
  desc "Deploy to Google Play Internal Testing"
  lane :internal do
    gradle(task: "clean bundleRelease")
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Deploy to Google Play Production"
  lane :production do
    gradle(task: "clean bundleRelease")
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

运行：
```bash
cd App/android
fastlane internal
```

---

## 检查清单

### 构建前
- [ ] 更新版本号 (`pubspec.yaml`)
- [ ] 测试所有功能
- [ ] 检查权限声明
- [ ] 更新版本说明

### 构建时
- [ ] 运行 `flutter clean`
- [ ] 运行 `flutter pub get`
- [ ] 构建 release 版本
- [ ] 验证 AAB 文件生成

### 上传前
- [ ] 测试 AAB 安装
- [ ] 准备截图和图形资源
- [ ] 准备版本说明（多语言）
- [ ] 检查内容分级

### 上传后
- [ ] 验证内部测试轨道
- [ ] 邀请测试用户
- [ ] 收集反馈
- [ ] 修复问题后推送生产环境

---

## 相关链接

- **Google Play Console**: https://play.google.com/console/
- **Flutter 文档**: https://docs.flutter.dev/deployment/android
- **App Bundle 文档**: https://developer.android.com/guide/app-bundle
- **Bundletool**: https://github.com/google/bundletool

---

**文档版本**: 1.0
**最后更新**: 2025-12-03
**Package Name**: com.novel.pop
