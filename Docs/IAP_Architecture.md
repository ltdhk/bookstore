# IAP 技术架构文档

## 系统架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                          Flutter App                             │
│                                                                   │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │ subscription_    │───▶│ InAppPurchase    │                   │
│  │ dialog.dart      │    │ Service          │                   │
│  └──────────────────┘    └──────────────────┘                   │
│           │                       │                              │
│           │                       │ queryProducts()              │
│           │                       │ purchaseProduct()            │
│           │                       ▼                              │
│           │              ┌──────────────────┐                   │
│           │              │ in_app_purchase  │                   │
│           │              │ (Flutter Plugin) │                   │
│           │              └──────────────────┘                   │
└───────────┼──────────────────────┼───────────────────────────────┘
            │                      │
            │                      ▼
            │         ┌─────────────────────┐
            │         │  iOS StoreKit /     │
            │         │  Google Play Billing│
            │         └─────────────────────┘
            │                      │
            │                      │ Receipt/Token
            │                      │
            │ verifyPurchase()     │
            ▼                      │
    ┌──────────────────────────────┼────────────────────────┐
    │         Spring Boot Backend  │                        │
    │                              │                        │
    │  ┌──────────────────────┐   │                        │
    │  │ SubscriptionController│◀──┘                        │
    │  └──────────────────────┘                             │
    │            │                                           │
    │            ▼                                           │
    │  ┌──────────────────────┐      ┌──────────────────┐  │
    │  │ SubscriptionService  │─────▶│ Receipt          │  │
    │  │ Impl                 │      │ Verification     │  │
    │  └──────────────────────┘      │ Services         │  │
    │            │                    └──────────────────┘  │
    │            │                            │              │
    │            ▼                            │              │
    │  ┌──────────────────────┐             │              │
    │  │ Database             │             │              │
    │  │ - orders             │             │              │
    │  │ - users              │             │              │
    │  │ - subscription_events│             │              │
    │  │ - distributor_       │             │              │
    │  │   commissions        │             │              │
    │  └──────────────────────┘             │              │
    │                                        │              │
    │                                        ▼              │
    │  ┌──────────────────────────────────────────────┐   │
    │  │ Apple Receipt API / Google Play API          │   │
    │  │ - Verify receipt authenticity                │   │
    │  │ - Get subscription details                   │   │
    │  └──────────────────────────────────────────────┘   │
    │                                                      │
    │  ┌──────────────────────────────────────────────┐   │
    │  │ WebhookController                            │   │
    │  │ - /api/webhook/apple                         │   │
    │  │ - /api/webhook/google                        │   │
    │  └──────────────────────────────────────────────┘   │
    │            ▲                                         │
    └────────────┼─────────────────────────────────────────┘
                 │
                 │ Server Notifications
                 │
    ┌────────────┴─────────────────────────────────────────┐
    │  Apple App Store / Google Play Store                 │
    │  - Subscription renewals                             │
    │  - Cancellations                                     │
    │  - Refunds                                           │
    └──────────────────────────────────────────────────────┘
```

## 核心流程

### 1. 购买流程

```
User → Tap Subscribe
  ↓
App → Query products from store (iOS/Android)
  ↓
App → Display products with prices
  ↓
User → Select plan & confirm
  ↓
App → Initiate platform purchase
  ↓
Platform → Show native payment UI
  ↓
User → Complete payment
  ↓
Platform → Return receipt/token to app
  ↓
App → Send receipt to backend for verification
  ↓
Backend → Verify with Apple/Google API
  ↓
Backend → Create order, update user status, calculate commission
  ↓
Backend → Return success
  ↓
App → Show success message & update UI
```

### 2. Webhook 处理流程

```
Apple/Google → Subscription event (renew/cancel/refund)
  ↓
Platform → Send webhook notification to backend
  ↓
Backend → Receive notification at /api/webhook/apple or /api/webhook/google
  ↓
Backend → Parse notification
  ↓
Backend → Update order/user status based on event type
  ↓
Backend → Record event in subscription_events table
  ↓
Backend → Return 200 OK to platform
```

## 关键组件

### Frontend (Flutter)

| 文件 | 职责 |
|------|------|
| `subscription_dialog.dart` | 订阅 UI，选择套餐，触发购买 |
| `in_app_purchase_service.dart` | IAP 核心逻辑，处理购买流程 |
| `platform_product_config.dart` | 平台产品 ID 映射 |
| `subscription_provider.dart` | Riverpod 状态管理 |
| `subscription_api_service.dart` | 后端 API 调用 |

### Backend (Spring Boot)

| 文件 | 职责 |
|------|------|
| `SubscriptionController.java` | 订阅 API 端点 |
| `SubscriptionServiceImpl.java` | 订阅业务逻辑 |
| `AppleReceiptVerificationService.java` | Apple 收据验证 |
| `GoogleReceiptVerificationService.java` | Google 收据验证 |
| `WebhookController.java` | Webhook 接收端点 |
| `AppleWebhookService.java` | Apple webhook 处理 |
| `GoogleWebhookService.java` | Google webhook 处理 |

### 数据库表

| 表名 | 用途 |
|------|------|
| `orders` | 订单记录 |
| `users` | 用户信息（含订阅状态） |
| `subscription_products` | 订阅产品定义 |
| `subscription_events` | 订阅事件日志 |
| `distributor_commissions` | 分销商佣金记录 |

## 产品配置

### iOS Product IDs
- `com.novel.pop.weekly` - 周卡
- `com.novel.pop.monthly` - 月卡
- `com.novel.pop.yearly` - 年卡

### Android Product IDs
- `novelpop_weekly` - 周卡
- `novelpop_monthly` - 月卡
- `novelpop_yearly` - 年卡

## 价格策略

| 套餐 | 价格 | 周期 | 节省 |
|------|------|------|------|
| 周卡 | $19.90 | 1周 | - |
| 月卡 | $49.99 | 1个月 | ~37% (vs 周卡×4) |
| 年卡 | $269.99 | 1年 | ~74% (vs 周卡×52) |

## 佣金系统

- **佣金率**: 30%
- **计算时机**: 购买时、续订时
- **结算方式**: 线下结算
- **状态**: pending → settled / cancelled

## 事件类型

### Apple Events
- `SUBSCRIBED` - 新订阅
- `DID_RENEW` - 续订成功
- `DID_FAIL_TO_RENEW` - 续订失败
- `DID_CHANGE_RENEWAL_STATUS` - 续订状态变更
- `EXPIRED` - 过期
- `REFUND` - 退款
- `GRACE_PERIOD_EXPIRED` - 宽限期结束

### Google Events
- `SUBSCRIPTION_PURCHASED` (4) - 新购买
- `SUBSCRIPTION_RENEWED` (2) - 续订
- `SUBSCRIPTION_CANCELED` (3) - 取消
- `SUBSCRIPTION_EXPIRED` (13) - 过期
- `SUBSCRIPTION_REVOKED` (12) - 撤销（退款）
- `SUBSCRIPTION_ON_HOLD` (5) - 暂停（支付问题）
- `SUBSCRIPTION_IN_GRACE_PERIOD` (6) - 宽限期

## 安全考虑

1. **收据验证**: 所有购买必须通过后端验证，不信任客户端
2. **重放攻击防护**: 使用 `original_transaction_id` 检测重复购买
3. **Webhook 验证**:
   - Apple: 验证 JWT 签名（待实现）
   - Google: 使用 Pub/Sub 认证
4. **HTTPS**: 所有通信必须使用 HTTPS
5. **敏感信息**: Apple Shared Secret 和 Google 服务账号密钥不能提交到代码库

## 性能优化

1. **异步处理**: Webhook 应该快速返回 200，后台异步处理
2. **缓存**: 缓存订阅产品信息
3. **数据库索引**: 在 `original_transaction_id` 和 `user_id` 上建立索引
4. **限流**: 对 Webhook 端点实施限流保护

## 监控和告警

建议监控的指标：
- 收据验证成功率
- 购买转化率
- Webhook 处理延迟
- 订阅续订率
- 退款率
- API 错误率

---

**版本**: 1.0
**最后更新**: 2025-12-03
