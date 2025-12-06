package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.SubscriptionCreateRequest;
import com.bookstore.dto.SubscriptionInfo;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.dto.SubscriptionStatusDTO;
import com.bookstore.dto.SubscriptionVerifyRequest;
import com.bookstore.entity.Order;
import com.bookstore.entity.ProcessedTransaction;
import com.bookstore.entity.SubscriptionEvent;
import com.bookstore.entity.SubscriptionProduct;
import com.bookstore.entity.User;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.ProcessedTransactionRepository;
import com.bookstore.repository.SubscriptionEventRepository;
import com.bookstore.repository.SubscriptionProductRepository;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.AppleReceiptVerificationService;
import com.bookstore.service.GoogleReceiptVerificationService;
import com.bookstore.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SubscriptionServiceImpl implements SubscriptionService {

    private final SubscriptionProductRepository subscriptionProductRepository;
    private final OrderRepository orderRepository;
    private final ProcessedTransactionRepository processedTransactionRepository;
    private final UserMapper userMapper;
    private final SubscriptionEventRepository subscriptionEventRepository;
    private final AppleReceiptVerificationService appleVerificationService;
    private final GoogleReceiptVerificationService googleVerificationService;

    // Commission rate constant (30%)
    private static final BigDecimal COMMISSION_RATE = new BigDecimal("30.00");

    @Override
    public List<SubscriptionProductDTO> getSubscriptionProducts(String platform) {
        QueryWrapper<SubscriptionProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_active", true);
        if (platform != null && !platform.isEmpty()) {
            queryWrapper.eq("platform", platform);
        }
        queryWrapper.orderByAsc("sort_order");

        List<SubscriptionProduct> products = subscriptionProductRepository.selectList(queryWrapper);
        return products.stream().map(product -> {
            SubscriptionProductDTO dto = new SubscriptionProductDTO();
            BeanUtils.copyProperties(product, dto);
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Order createSubscription(Long userId, SubscriptionCreateRequest request) {
        // Get product info
        SubscriptionProduct product = getProductByProductId(request.getProductId());
        if (product == null || !product.getIsActive()) {
            throw new RuntimeException("Product not found or inactive");
        }

        // Create order
        Order order = new Order();
        order.setUserId(userId);
        order.setOrderNo(generateOrderNo());
        order.setAmount(product.getPrice());
        order.setStatus("Paid"); // Mock payment - directly set to Paid
        order.setPlatform(request.getPlatform());
        order.setProductId(request.getProductId());

        // Subscription fields
        order.setOrderType("subscription");
        order.setSubscriptionPeriod(product.getPlanType());

        LocalDateTime startDate = LocalDateTime.now();
        LocalDateTime endDate = startDate.plusDays(product.getDurationDays());
        order.setSubscriptionStartDate(startDate);
        order.setSubscriptionEndDate(endDate);
        order.setIsAutoRenew(true);

        // Mock transaction IDs
        order.setOriginalTransactionId(generateMockTransactionId(request.getPlatform()));
        order.setPlatformTransactionId("TXN_" + UUID.randomUUID().toString());

        // Mock receipt/token data
        if ("AppStore".equals(request.getPlatform())) {
            order.setReceiptData(generateMockReceipt(order));
        } else if ("GooglePay".equals(request.getPlatform())) {
            order.setPurchaseToken(generateMockPurchaseToken(order));
        }

        // Source tracking
        order.setDistributorId(request.getDistributorId());
        order.setSourcePasscodeId(request.getSourcePasscodeId());
        order.setSourceBookId(request.getSourceBookId());
        order.setSourceEntry(request.getSourceEntry());

        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());

        // Save order
        orderRepository.insert(order);

        // Update user subscription status
        updateUserSubscriptionStatus(userId, order);

        return order;
    }

    @Override
    public SubscriptionStatusDTO getSubscriptionStatus(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        SubscriptionStatusDTO dto = new SubscriptionStatusDTO();
        dto.setSubscriptionStatus(user.getSubscriptionStatus());
        dto.setSubscriptionEndDate(user.getSubscriptionEndDate());
        dto.setSubscriptionPlanType(user.getSubscriptionPlanType());
        dto.setIsSvip(user.getIsSvip());

        // Get current active subscription order
        if ("active".equals(user.getSubscriptionStatus())) {
            QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId);
            queryWrapper.eq("order_type", "subscription");
            queryWrapper.eq("status", "Paid");
            queryWrapper.ge("subscription_end_date", LocalDateTime.now());
            queryWrapper.orderByDesc("create_time");
            queryWrapper.last("LIMIT 1");

            Order order = orderRepository.selectOne(queryWrapper);
            if (order != null) {
                dto.setOrderId(order.getId());
                dto.setOrderNo(order.getOrderNo());
                dto.setAmount(order.getAmount());
                dto.setPlatform(order.getPlatform());
                dto.setSubscriptionStartDate(order.getSubscriptionStartDate());
                dto.setIsAutoRenew(order.getIsAutoRenew());
            }
        }

        return dto;
    }

    @Override
    @Transactional
    public void cancelSubscription(Long userId, String reason) {
        User user = userMapper.selectById(userId);
        if (user == null || !"active".equals(user.getSubscriptionStatus())) {
            throw new RuntimeException("No active subscription to cancel");
        }

        // Update user status
        user.setSubscriptionStatus("cancelled");
        userMapper.updateById(user);

        // Update current active order
        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.eq("order_type", "subscription");
        queryWrapper.eq("status", "Paid");
        queryWrapper.ge("subscription_end_date", LocalDateTime.now());
        queryWrapper.orderByDesc("create_time");
        queryWrapper.last("LIMIT 1");

        Order order = orderRepository.selectOne(queryWrapper);
        if (order != null) {
            order.setIsAutoRenew(false);
            order.setCancelDate(LocalDateTime.now());
            order.setCancelReason(reason);
            order.setUpdateTime(LocalDateTime.now());
            orderRepository.updateById(order);
        }
    }

    @Override
    @Transactional
    public void updateUserSubscriptionStatus(Long userId, Order order) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        LocalDateTime currentEndDate = user.getSubscriptionEndDate();
        LocalDateTime newEndDate = order.getSubscriptionEndDate();
        LocalDateTime finalEndDate;

        // 取两者中较晚的时间，避免用户损失已付费时长
        if (currentEndDate != null && currentEndDate.isAfter(newEndDate)) {
            finalEndDate = currentEndDate;
            log.warn("用户 {} 已有更晚的订阅到期时间 {} (新订阅: {})，保持原时间不变",
                     userId, currentEndDate, newEndDate);
        } else if (currentEndDate != null && currentEndDate.isAfter(LocalDateTime.now())) {
            // 新订阅时间更晚，但旧订阅还没过期
            finalEndDate = newEndDate;
            long remainingDays = java.time.temporal.ChronoUnit.DAYS.between(LocalDateTime.now(), currentEndDate);
            log.info("用户 {} 原订阅剩余 {} 天 (到期: {})，更新为新到期时间: {}",
                     userId, remainingDays, currentEndDate, newEndDate);
        } else {
            // 无旧订阅或旧订阅已过期
            finalEndDate = newEndDate;
            log.info("用户 {} 订阅更新为: {}", userId, newEndDate);
        }

        user.setIsSvip(true);
        user.setSubscriptionStatus("active");
        user.setSubscriptionEndDate(finalEndDate);
        user.setSubscriptionPlanType(order.getSubscriptionPeriod());
        userMapper.updateById(user);

        log.info("用户 {} 订阅状态已更新 - 最终到期时间: {}", userId, finalEndDate);
    }

    @Override
    public boolean isSubscriptionValid(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return false;
        }

        // Check if user is SVIP (manual assignment or active subscription)
        if (Boolean.TRUE.equals(user.getIsSvip())) {
            // If user has subscriptionEndDate, check if it's still valid
            if (user.getSubscriptionEndDate() != null) {
                return LocalDateTime.now().isBefore(user.getSubscriptionEndDate());
            }
            // If no end date set, SVIP is permanent (manually assigned)
            return true;
        }

        // Check subscription status for non-SVIP users
        if (!"active".equals(user.getSubscriptionStatus())) {
            return false;
        }

        if (user.getSubscriptionEndDate() == null) {
            return false;
        }

        return LocalDateTime.now().isBefore(user.getSubscriptionEndDate());
    }

    @Override
    @Transactional
    public void processExpiredSubscriptions() {
        log.info("开始批量处理过期订阅...");

        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("subscription_status", "active");
        queryWrapper.lt("subscription_end_date", LocalDateTime.now());

        List<User> expiredUsers = userMapper.selectList(queryWrapper);

        if (expiredUsers.isEmpty()) {
            log.info("没有发现过期的订阅用户");
            return;
        }

        log.info("发现 {} 个过期订阅用户，开始更新状态...", expiredUsers.size());

        int successCount = 0;
        int failCount = 0;

        for (User user : expiredUsers) {
            try {
                log.debug("处理用户 ID: {}, 订阅结束时间: {}", user.getId(), user.getSubscriptionEndDate());

                user.setSubscriptionStatus("expired");
                user.setIsSvip(false);
                userMapper.updateById(user);

                successCount++;
            } catch (Exception e) {
                failCount++;
                log.error("更新用户 {} 订阅状态失败", user.getId(), e);
            }
        }

        log.info("过期订阅处理完成 - 成功: {}, 失败: {}, 总计: {}",
            successCount, failCount, expiredUsers.size());
    }

    @Override
    public SubscriptionProduct getProductByProductId(String productId) {
        QueryWrapper<SubscriptionProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("product_id", productId);
        return subscriptionProductRepository.selectOne(queryWrapper);
    }

    /**
     * Generate order number: SUB + timestamp + random 4 digits
     */
    private String generateOrderNo() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        Random random = new Random();
        int randomNum = random.nextInt(9000) + 1000; // 1000-9999
        return "SUB" + timestamp + randomNum;
    }

    /**
     * Generate mock transaction ID
     */
    private String generateMockTransactionId(String platform) {
        long timestamp = System.currentTimeMillis();
        return "MOCK_" + platform.toUpperCase() + "_" + timestamp;
    }

    /**
     * Generate mock Apple receipt (Base64 encoded JSON)
     */
    private String generateMockReceipt(Order order) {
        String receiptJson = String.format(
            "{\"transaction_id\":\"%s\",\"original_transaction_id\":\"%s\",\"product_id\":\"%s\",\"purchase_date_ms\":%d,\"expires_date_ms\":%d}",
            order.getPlatformTransactionId(),
            order.getOriginalTransactionId(),
            order.getProductId(),
            System.currentTimeMillis(),
            System.currentTimeMillis() + (order.getSubscriptionEndDate().getNano() - order.getSubscriptionStartDate().getNano())
        );
        return Base64.getEncoder().encodeToString(receiptJson.getBytes());
    }

    /**
     * Generate mock Google purchase token
     */
    private String generateMockPurchaseToken(Order order) {
        String tokenData = String.format(
            "{\"orderId\":\"%s\",\"productId\":\"%s\",\"purchaseTime\":%d,\"purchaseToken\":\"%s\"}",
            order.getOrderNo(),
            order.getProductId(),
            System.currentTimeMillis(),
            UUID.randomUUID().toString()
        );
        return Base64.getEncoder().encodeToString(tokenData.getBytes());
    }

    /**
     * Verify purchase receipt and activate subscription
     */
    @Override
    @Transactional
    public Order verifyAndActivateSubscription(Long userId, SubscriptionVerifyRequest request) {
        log.info("========== 开始处理订阅购买 ==========");
        log.info("用户ID: {}, 平台: {}, 产品ID: {}", userId, request.getPlatform(), request.getProductId());
        log.info("来源信息 - 分销商ID: {}, 口令ID: {}, 书籍ID: {}, 入口: {}",
            request.getDistributorId(), request.getSourcePasscodeId(),
            request.getSourceBookId(), request.getSourceEntry());

        // 1. Verify receipt with platform
        log.info("步骤1: 开始验证收据 - 平台: {}", request.getPlatform());
        SubscriptionInfo subscriptionInfo;
        try {
            if ("AppStore".equals(request.getPlatform())) {
                log.debug("调用 Apple 收据验证服务");
                // 传递 productId 以便找到正确的交易（避免匹配到其他订阅产品的交易）
                subscriptionInfo = appleVerificationService.verifyReceipt(request.getReceiptData(), request.getProductId());
                log.info("Apple 收据验证成功 - 原始交易ID: {}, 产品ID: {}",
                    subscriptionInfo.getOriginalTransactionId(), subscriptionInfo.getProductId());
            } else if ("GooglePay".equals(request.getPlatform())) {
                log.debug("调用 Google Play 收据验证服务");
                subscriptionInfo = googleVerificationService.verifyPurchase(
                    request.getProductId(),
                    request.getPurchaseToken()
                );
                log.info("Google 收据验证成功 - 原始交易ID: {}", subscriptionInfo.getOriginalTransactionId());
            } else {
                log.error("不支持的平台: {}", request.getPlatform());
                throw new IllegalArgumentException("Unsupported platform: " + request.getPlatform());
            }
        } catch (Exception e) {
            log.error("收据验证失败: {}", e.getMessage(), e);
            throw new RuntimeException("Receipt verification failed: " + e.getMessage(), e);
        }

        // 2. Check for duplicate purchase using platform transaction ID
        // Use platformTransactionId (unique per transaction) instead of originalTransactionId
        // because originalTransactionId stays the same for:
        // - Auto-renewable subscriptions in the same group (upgrades/downgrades)
        // - Sometimes for related purchases
        String originalTransactionId = subscriptionInfo.getOriginalTransactionId();
        String platformTransactionId = subscriptionInfo.getTransactionId();
        String productId = request.getProductId();

        log.info("步骤2: 检查重复交易 - 原始交易ID: {}, 平台交易ID: {}, 产品ID: {}",
            originalTransactionId, platformTransactionId, productId);

        // Check if this exact transaction has been processed before
        QueryWrapper<ProcessedTransaction> processedQuery = new QueryWrapper<>();
        processedQuery.eq("platform_transaction_id", platformTransactionId);
        ProcessedTransaction processedTxn = processedTransactionRepository.selectOne(processedQuery);

        if (processedTxn != null) {
            // This transaction was already processed
            log.warn("检测到重复交易 - 平台交易ID: {} 已在 {} 处理过",
                platformTransactionId, processedTxn.getProcessedAt());

            // Find the original order for logging
            String orderNo = "unknown";
            if (processedTxn.getOrderId() != null) {
                Order existingOrder = orderRepository.selectById(processedTxn.getOrderId());
                if (existingOrder != null) {
                    orderNo = existingOrder.getOrderNo();
                }
            }

            log.info("重复交易已确认 - 原订单: {}", orderNo);

            // Throw exception with specific message that frontend can recognize
            // This tells frontend: "Purchase was already successful, just complete the transaction"
            throw new RuntimeException("DUPLICATE_TRANSACTION:订单已存在,交易已成功处理,订单号:" + orderNo);
        }

        log.info("未检测到重复交易，继续处理");

        // 3. Get product information
        log.info("步骤3: 获取产品信息 - 产品ID: {}", request.getProductId());
        SubscriptionProduct product = getProductByProductId(request.getProductId());
        if (product == null || !product.getIsActive()) {
            log.error("产品不存在或未激活: {}", request.getProductId());
            throw new RuntimeException("Product not found or inactive: " + request.getProductId());
        }
        log.info("产品信息 - 名称: {}, 类型: {}, 价格: {}, 天数: {}",
            product.getProductName(), product.getPlanType(), product.getPrice(), product.getDurationDays());

        // 4. Create order
        log.info("步骤4: 创建订单");
        Order order = new Order();
        order.setUserId(userId);
        String orderNo = generateOrderNo();
        order.setOrderNo(orderNo);
        order.setAmount(product.getPrice());
        order.setStatus("Paid");
        order.setPlatform(request.getPlatform());
        order.setProductId(request.getProductId());
        order.setOrderType("subscription");
        order.setSubscriptionPeriod(product.getPlanType());

        // 设置订阅开始时间
        LocalDateTime startDate = subscriptionInfo.getPurchaseDate();
        order.setSubscriptionStartDate(startDate);

        // 设置订阅结束时间
        // 对于 Non-Renewing Subscription，Apple 不返回 expires_date_ms，需要根据产品天数计算
        LocalDateTime endDate = subscriptionInfo.getExpiryDate();
        if (endDate == null && startDate != null && product.getDurationDays() != null) {
            endDate = startDate.plusDays(product.getDurationDays());
            log.info("Non-Renewing Subscription: 根据产品天数({})计算过期时间: {}",
                product.getDurationDays(), endDate);
        }
        order.setSubscriptionEndDate(endDate);
        order.setIsAutoRenew(subscriptionInfo.isAutoRenewing());
        order.setOriginalTransactionId(originalTransactionId);
        order.setPlatformTransactionId(subscriptionInfo.getTransactionId());

        // Store receipt/token
        if ("AppStore".equals(request.getPlatform())) {
            order.setReceiptData(request.getReceiptData());
            log.debug("保存 Apple 收据数据（长度: {} 字节）", request.getReceiptData().length());
        } else {
            order.setPurchaseToken(request.getPurchaseToken());
            log.debug("保存 Google 购买令牌");
        }

        // Source tracking
        order.setDistributorId(request.getDistributorId());
        order.setSourcePasscodeId(request.getSourcePasscodeId());
        order.setSourceBookId(request.getSourceBookId());
        order.setSourceEntry(request.getSourceEntry());

        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());
        order.setVerifiedAt(LocalDateTime.now());

        // Save order
        orderRepository.insert(order);
        log.info("订单创建成功 - 订单号: {}, 订单ID: {}, 金额: {}", orderNo, order.getId(), order.getAmount());

        // Record this transaction as processed to prevent duplicate processing
        ProcessedTransaction processedTransaction = new ProcessedTransaction();
        processedTransaction.setPlatformTransactionId(platformTransactionId);
        processedTransaction.setOriginalTransactionId(originalTransactionId);
        processedTransaction.setOrderId(order.getId());
        processedTransaction.setPlatform(request.getPlatform());
        processedTransaction.setProductId(productId);
        processedTransaction.setProcessedAt(LocalDateTime.now());
        processedTransactionRepository.insert(processedTransaction);
        log.info("已记录处理的交易 - 平台交易ID: {}, 订单ID: {}", platformTransactionId, order.getId());

        // 5. Update user subscription status
        log.info("步骤5: 更新用户订阅状态");
        try {
            updateUserSubscriptionStatus(userId, order);
            log.info("用户订阅状态更新成功 - 订阅有效期至: {}", order.getSubscriptionEndDate());
        } catch (Exception e) {
            log.error("更新用户订阅状态失败: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to update user subscription status", e);
        }

        // 6. Log commission info if distributor exists (no longer saving to separate table)
        if (order.getDistributorId() != null) {
            BigDecimal commissionAmount = calculateCommissionAmount(order.getAmount());
            log.info("步骤6: 佣金信息 - 分销商ID: {}, 订单金额: {}, 佣金比例: {}%, 佣金金额: {}",
                order.getDistributorId(), order.getAmount(), COMMISSION_RATE, commissionAmount);
            log.info("佣金将在结算时根据订单数据动态计算");
        } else {
            log.info("步骤6: 无分销商，跳过佣金记录");
        }

        // 7. Record subscription event
        log.info("步骤7: 记录订阅事件");
        try {
            recordSubscriptionEvent(userId, order, "purchased");
            log.info("订阅事件记录成功");
        } catch (Exception e) {
            log.error("记录订阅事件失败: {}", e.getMessage(), e);
            // 不抛出异常，记录失败不影响主流程
        }

        log.info("========== 订阅购买处理完成 ==========");
        log.info("订单摘要 - 订单号: {}, 用户ID: {}, 产品: {}, 金额: {}, 有效期: {} 至 {}",
            orderNo, userId, product.getProductName(), order.getAmount(),
            order.getSubscriptionStartDate(), order.getSubscriptionEndDate());

        return order;
    }

    /**
     * Calculate commission amount (utility method for dynamic calculation)
     * Commission is calculated as: order amount * 30%
     */
    private BigDecimal calculateCommissionAmount(BigDecimal orderAmount) {
        return orderAmount
            .multiply(COMMISSION_RATE)
            .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
    }

    /**
     * Record subscription event
     */
    private void recordSubscriptionEvent(Long userId, Order order, String eventType) {
        SubscriptionEvent event = new SubscriptionEvent();
        event.setUserId(userId);
        event.setOrderId(order.getId());
        event.setEventType(eventType);
        event.setPlatform(order.getPlatform());
        event.setOriginalTransactionId(order.getOriginalTransactionId());
        event.setEventDate(LocalDateTime.now());
        event.setProcessed(true);
        event.setCreatedAt(LocalDateTime.now());

        subscriptionEventRepository.insert(event);
    }
}
