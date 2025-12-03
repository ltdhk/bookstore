# IAP 系统优化总结

## 优化日期
2025-01-03

## 优化内容

### 1. 移除独立的佣金表，改为动态计算

#### 优化原因
- 佣金数据本质上是从订单数据派生的，不需要单独存储
- 减少数据冗余和维护成本
- 简化数据结构，更易于维护
- 查询时动态计算，确保数据一致性

#### 修改内容

**数据库层面**:
- ✅ 移除 `distributor_commissions` 表的创建
- ✅ `orders` 表字段说明（大部分已在 schema.sql 中存在）:
  - `distributor_id` - 分销商ID（已存在）
  - `source_passcode_id` - 来源口令ID（已存在）
  - `source_book_id` - 来源书籍ID（已存在）
  - `source_entry` - 来源入口（已存在）
  - `receipt_data` - 收据数据（已存在）
  - `original_transaction_id` - 原始交易ID（已存在）
  - `platform_transaction_id` - 平台交易ID（已存在）
  - `purchase_token` - Google 购买令牌（已存在）
  - `verified_at` - 验证时间（**新增**）

**代码层面**:
- ✅ 移除 `DistributorCommission` 实体类的依赖
- ✅ 移除 `DistributorCommissionRepository` 的依赖
- ✅ 在 `SubscriptionServiceImpl` 中:
  - 移除 `calculateCommission()` 方法（旧的插入佣金记录）
  - 添加 `calculateCommissionAmount()` 工具方法（纯计算）
  - 在订单创建时记录佣金信息到日志

**新增服务**:
- ✅ 创建 `CommissionQueryService` - 佣金查询服务
  - `getDistributorCommissions()` - 查询分销商佣金
  - `getTotalCommissionAmount()` - 计算总佣金
  - `getPasscodeCommissions()` - 查询口令佣金
  - `getBookCommissions()` - 查询书籍佣金
  - `calculateCommission()` - 静态工具方法

---

### 2. 增强支付流程日志记录

#### 优化原因
- 便于追踪支付问题
- 方便调试和排查错误
- 提供详细的审计日志
- 帮助理解支付流程

#### 修改内容

**后端日志增强** (`SubscriptionServiceImpl.java`):

```java
@Slf4j  // 添加 Lombok 日志注解
public class SubscriptionServiceImpl {

    public Order verifyAndActivateSubscription(...) {
        // 开始标记
        log.info("========== 开始处理订阅购买 ==========");
        log.info("用户ID: {}, 平台: {}, 产品ID: {}", ...);
        log.info("来源信息 - 分销商ID: {}, 口令ID: {}, 书籍ID: {}, 入口: {}", ...);

        // 步骤1: 收据验证
        log.info("步骤1: 开始验证收据 - 平台: {}", ...);
        log.debug("调用 Apple/Google 收据验证服务");
        log.info("收据验证成功 - 原始交易ID: {}", ...);

        // 步骤2: 重复购买检查
        log.info("步骤2: 检查重复购买 - 原始交易ID: {}", ...);
        log.warn("检测到重复购买 - 订单已存在: {}, 返回已有订单", ...);

        // 步骤3: 产品信息
        log.info("步骤3: 获取产品信息 - 产品ID: {}", ...);
        log.info("产品信息 - 名称: {}, 类型: {}, 价格: {}, 天数: {}", ...);

        // 步骤4: 创建订单
        log.info("步骤4: 创建订单");
        log.debug("保存 Apple 收据数据（长度: {} 字节）", ...);
        log.info("订单创建成功 - 订单号: {}, 订单ID: {}, 金额: {}", ...);

        // 步骤5: 更新用户状态
        log.info("步骤5: 更新用户订阅状态");
        log.info("用户订阅状态更新成功 - 订阅有效期至: {}", ...);

        // 步骤6: 佣金信息
        log.info("步骤6: 佣金信息 - 分销商ID: {}, 订单金额: {}, 佣金比例: {}%, 佣金金额: {}", ...);
        log.info("佣金将在结算时根据订单数据动态计算");

        // 步骤7: 记录事件
        log.info("步骤7: 记录订阅事件");
        log.info("订阅事件记录成功");

        // 完成标记
        log.info("========== 订阅购买处理完成 ==========");
        log.info("订单摘要 - 订单号: {}, 用户ID: {}, 产品: {}, 金额: {}, 有效期: {} 至 {}", ...);
    }
}
```

**App 端日志增强** (`in_app_purchase_service.dart`):

```dart
Future<void> _verifyWithBackend(PurchaseDetails purchase) async {
  debugPrint('========== 开始后端验证购买 ==========');
  debugPrint('购买详情 - 产品ID: ${purchase.productID}, 平台: $platform');
  debugPrint('来源信息 - 分销商ID: ${context['distributorId']}, 口令ID: ${context['sourcePasscodeId']}');
  debugPrint('来源信息 - 书籍ID: ${context['sourceBookId']}, 入口: ${context['sourceEntry']}');

  debugPrint('调用后端验证接口...');
  final result = await _apiService.verifyPurchase(...);

  debugPrint('后端验证成功! 订单信息: $result');
  debugPrint('========== 购买验证完成 ==========');
}
```

---

## 佣金计算说明

### 计算公式
```
佣金金额 = 订单金额 × 30%
```

### 查询方式

**按分销商查询**:
```java
List<CommissionSummaryDTO> commissions = commissionQueryService
    .getDistributorCommissions(distributorId, startDate, endDate);

BigDecimal total = commissionQueryService
    .getTotalCommissionAmount(distributorId, startDate, endDate);
```

**按口令查询**:
```java
List<CommissionSummaryDTO> commissions = commissionQueryService
    .getPasscodeCommissions(passcodeId);
```

**按书籍查询**:
```java
List<CommissionSummaryDTO> commissions = commissionQueryService
    .getBookCommissions(bookId);
```

**直接计算**:
```java
BigDecimal commission = CommissionQueryService.calculateCommission(orderAmount);
```

---

## 数据库迁移

### 执行顺序

**重要说明**: 如果你的数据库是从 `schema.sql` 创建的，那么 `orders` 表已经包含了所有必要的字段（`distributor_id`, `source_passcode_id`, `receipt_data` 等），你只需要：

1. **运行基础 IAP 迁移** (创建 subscription_events 表和更新产品):
```sql
mysql -u root -p bookstore < Backend/src/main/resources/db/migration_add_iap_tables.sql
```

2. **可选：运行订单表优化** (只添加 `verified_at` 字段和额外索引):
```sql
mysql -u root -p bookstore < Backend/src/main/resources/db/migration_optimize_orders_for_commission.sql
```

**如果是新数据库**: 直接运行 `schema.sql` 即可，它已经包含了所有字段。

### 表结构变化

**移除的表**:
- ❌ `distributor_commissions` - 不再需要单独的佣金表

**新增字段** (仅在旧数据库上运行迁移时):
- ✅ `orders.verified_at` - 收据验证时间（新增）

**已有字段** (schema.sql 中已包含):
- ✅ `orders.distributor_id` - 分销商ID
- ✅ `orders.source_passcode_id` - 来源口令ID
- ✅ `orders.source_book_id` - 来源书籍ID
- ✅ `orders.source_entry` - 来源入口
- ✅ `orders.original_transaction_id` - 原始交易ID
- ✅ `orders.receipt_data` - 收据数据
- ✅ `orders.purchase_token` - Google 购买令牌

**新增表**:
- ✅ `subscription_events` - 订阅事件日志

**保留的表**:
- ✅ `subscription_products` - 订阅产品
- ✅ `users` - 用户表（含订阅状态）
- ✅ `orders` - 订单表（包含所有必要字段）

---

## 日志示例

### 成功购买的日志输出

```
2025-01-03 14:23:45 [INFO ] ========== 开始处理订阅购买 ==========
2025-01-03 14:23:45 [INFO ] 用户ID: 12345, 平台: AppStore, 产品ID: weekly_subscription
2025-01-03 14:23:45 [INFO ] 来源信息 - 分销商ID: 789, 口令ID: 456, 书籍ID: 123, 入口: reader
2025-01-03 14:23:45 [INFO ] 步骤1: 开始验证收据 - 平台: AppStore
2025-01-03 14:23:45 [DEBUG] 调用 Apple 收据验证服务
2025-01-03 14:23:46 [INFO ] Apple 收据验证成功 - 原始交易ID: 1000000123456789
2025-01-03 14:23:46 [INFO ] 步骤2: 检查重复购买 - 原始交易ID: 1000000123456789
2025-01-03 14:23:46 [INFO ] 未检测到重复购买，继续处理
2025-01-03 14:23:46 [INFO ] 步骤3: 获取产品信息 - 产品ID: weekly_subscription
2025-01-03 14:23:46 [INFO ] 产品信息 - 名称: Weekly SVIP, 类型: weekly, 价格: 19.90, 天数: 7
2025-01-03 14:23:46 [INFO ] 步骤4: 创建订单
2025-01-03 14:23:46 [DEBUG] 保存 Apple 收据数据（长度: 2048 字节）
2025-01-03 14:23:46 [INFO ] 订单创建成功 - 订单号: SUB202501031423450001, 订单ID: 67890, 金额: 19.90
2025-01-03 14:23:46 [INFO ] 步骤5: 更新用户订阅状态
2025-01-03 14:23:46 [INFO ] 用户订阅状态更新成功 - 订阅有效期至: 2025-01-10 14:23:46
2025-01-03 14:23:46 [INFO ] 步骤6: 佣金信息 - 分销商ID: 789, 订单金额: 19.90, 佣金比例: 30.00%, 佣金金额: 5.97
2025-01-03 14:23:46 [INFO ] 佣金将在结算时根据订单数据动态计算
2025-01-03 14:23:46 [INFO ] 步骤7: 记录订阅事件
2025-01-03 14:23:46 [INFO ] 订阅事件记录成功
2025-01-03 14:23:46 [INFO ] ========== 订阅购买处理完成 ==========
2025-01-03 14:23:46 [INFO ] 订单摘要 - 订单号: SUB202501031423450001, 用户ID: 12345, 产品: Weekly SVIP, 金额: 19.90, 有效期: 2025-01-03 14:23:46 至 2025-01-10 14:23:46
```

---

## 优势总结

### 1. 数据一致性
- ✅ 单一数据源（orders 表）
- ✅ 避免数据同步问题
- ✅ 实时计算确保准确性

### 2. 简化维护
- ✅ 减少一张表的维护成本
- ✅ 更少的数据库写操作
- ✅ 更简洁的代码逻辑

### 3. 灵活性
- ✅ 佣金比例可以随时调整
- ✅ 可以按多个维度查询（分销商、口令、书籍）
- ✅ 支持自定义查询条件

### 4. 可追溯性
- ✅ 详细的日志记录每一步操作
- ✅ 便于问题排查和审计
- ✅ 清晰的步骤标记

### 5. 性能
- ✅ 减少一张表的查询和维护
- ✅ orders 表已有适当索引
- ✅ 按需计算，不占用存储空间

---

## 注意事项

1. **佣金比例变更**
   - 如果未来佣金比例需要变更，需要记录变更历史
   - 建议在订单表添加 `commission_rate` 字段存储当时的比例
   - 或者在订单创建时记录到订单备注中

2. **历史数据**
   - 现有订单如果缺少必要字段，需要补充默认值
   - 迁移脚本已处理 `source_entry` 的默认值

3. **性能考虑**
   - 大量订单查询时考虑分页
   - 必要时可以创建物化视图或缓存
   - 定期统计可以生成报表缓存

4. **日志级别**
   - 生产环境建议使用 INFO 级别
   - DEBUG 级别用于开发和调试
   - 敏感信息（收据内容）只在 DEBUG 显示长度

---

## 文件清单

### 新增文件
- ✅ `Backend/src/main/resources/db/migration_optimize_orders_for_commission.sql`
- ✅ `Backend/src/main/java/com/bookstore/dto/CommissionSummaryDTO.java`
- ✅ `Backend/src/main/java/com/bookstore/service/CommissionQueryService.java`
- ✅ `Docs/IAP_Optimization_Summary.md` (本文档)

### 修改文件
- ✅ `Backend/src/main/resources/db/migration_add_iap_tables.sql` - 移除佣金表创建
- ✅ `Backend/src/main/java/com/bookstore/service/impl/SubscriptionServiceImpl.java` - 增强日志，移除佣金表操作
- ✅ `App/lib/src/services/iap/in_app_purchase_service.dart` - 增强日志

### 删除/移除
- ❌ `DistributorCommission` 实体类引用
- ❌ `DistributorCommissionRepository` 引用
- ❌ `distributor_commissions` 表创建语句

---

**版本**: 1.0
**最后更新**: 2025-01-03
