package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.SubscriptionCreateRequest;
import com.bookstore.dto.SubscriptionInfo;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.dto.SubscriptionStatusDTO;
import com.bookstore.dto.SubscriptionVerifyRequest;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionEvent;
import com.bookstore.entity.SubscriptionProduct;
import com.bookstore.entity.User;
import com.bookstore.repository.OrderRepository;
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

        user.setIsSvip(true);
        user.setSubscriptionStatus("active");
        user.setSubscriptionEndDate(order.getSubscriptionEndDate());
        user.setSubscriptionPlanType(order.getSubscriptionPeriod());
        userMapper.updateById(user);
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
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("subscription_status", "active");
        queryWrapper.lt("subscription_end_date", LocalDateTime.now());

        List<User> expiredUsers = userMapper.selectList(queryWrapper);
        for (User user : expiredUsers) {
            user.setSubscriptionStatus("expired");
            user.setIsSvip(false);
            userMapper.updateById(user);
        }
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
                subscriptionInfo = appleVerificationService.verifyReceipt(request.getReceiptData());
                log.info("Apple 收据验证成功 - 原始交易ID: {}", subscriptionInfo.getOriginalTransactionId());
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

        // 2. Check for duplicate purchase
        String originalTransactionId = subscriptionInfo.getOriginalTransactionId();
        log.info("步骤2: 检查重复购买 - 原始交易ID: {}", originalTransactionId);
        QueryWrapper<Order> duplicateQuery = new QueryWrapper<>();
        duplicateQuery.eq("original_transaction_id", originalTransactionId);
        Order existingOrder = orderRepository.selectOne(duplicateQuery);

        if (existingOrder != null) {
            log.warn("检测到重复购买 - 订单已存在: {}, 返回已有订单", existingOrder.getOrderNo());
            return existingOrder;
        }
        log.info("未检测到重复购买，继续处理");

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
        order.setSubscriptionStartDate(subscriptionInfo.getPurchaseDate());
        order.setSubscriptionEndDate(subscriptionInfo.getExpiryDate());
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
