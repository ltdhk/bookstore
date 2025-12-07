package com.bookstore.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.GooglePlayNotification;
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
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.model.SubscriptionPurchaseLineItem;
import com.google.api.services.androidpublisher.model.SubscriptionPurchaseV2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;

/**
 * Google Play Real-time Developer Notification Handler
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleWebhookService {

    private final OrderRepository orderRepository;
    private final UserMapper userMapper;
    private final SubscriptionEventRepository subscriptionEventRepository;
    private final ProcessedTransactionRepository processedTransactionRepository;
    private final SubscriptionProductRepository subscriptionProductRepository;
    private final AndroidPublisher androidPublisher;

    @Value("${iap.google.package-name}")
    private String packageName;

    /**
     * Handle Google Play notification
     */
    @Transactional
    public void handleNotification(GooglePlayNotification notification) {
        log.info("Received Google Play notification: package={}", notification.getPackageName());

        // Handle test notification
        if (notification.getTestNotification() != null) {
            log.info("Received test notification from Google Play");
            return;
        }

        GooglePlayNotification.SubscriptionNotification subNotification =
            notification.getSubscriptionNotification();

        if (subNotification == null) {
            log.warn("No subscription notification data");
            return;
        }

        Integer notificationType = subNotification.getNotificationType();
        String purchaseToken = subNotification.getPurchaseToken();
        String subscriptionId = subNotification.getSubscriptionId();

        log.info("Processing Google notification: type={}, subscriptionId={}, token={}",
            notificationType, subscriptionId, purchaseToken);

        try {
            switch (notificationType) {
                case 1: // SUBSCRIPTION_RECOVERED
                    handleRecovered(purchaseToken, subscriptionId);
                    break;
                case 2: // SUBSCRIPTION_RENEWED
                    handleRenewal(purchaseToken, subscriptionId);
                    break;
                case 3: // SUBSCRIPTION_CANCELED
                    handleCancellation(purchaseToken, subscriptionId);
                    break;
                case 4: // SUBSCRIPTION_PURCHASED
                    handlePurchased(purchaseToken, subscriptionId);
                    break;
                case 5: // SUBSCRIPTION_ON_HOLD
                    handleOnHold(purchaseToken, subscriptionId);
                    break;
                case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
                    handleGracePeriod(purchaseToken, subscriptionId);
                    break;
                case 7: // SUBSCRIPTION_RESTARTED
                    handleRestarted(purchaseToken, subscriptionId);
                    break;
                case 12: // SUBSCRIPTION_REVOKED
                    handleRevoked(purchaseToken, subscriptionId);
                    break;
                case 13: // SUBSCRIPTION_EXPIRED
                    handleExpired(purchaseToken, subscriptionId);
                    break;
                default:
                    log.warn("Unhandled Google notification type: {}", notificationType);
            }
        } catch (Exception e) {
            log.error("Failed to handle Google notification: type={}", notificationType, e);
            throw new RuntimeException("Failed to process Google notification", e);
        }
    }

    /**
     * Handle subscription recovery (payment issue resolved)
     */
    private void handleRecovered(String purchaseToken, String subscriptionId) {
        log.info("Subscription recovered: {}", subscriptionId);
        recordEvent("recovered", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription renewal
     * This is CRITICAL - creates renewal order and extends subscription
     *
     * 注意：此 webhook 只适用于自动续期订阅 (如 weekly)
     * 预付费订阅 (如 monthly/yearly) 不会收到续费通知，用户需要手动重新购买
     */
    private void handleRenewal(String purchaseToken, String subscriptionId) {
        log.info("========== 处理 Google Play 订阅续费通知 ==========");
        log.info("订阅ID: {}, purchaseToken: {}", subscriptionId, purchaseToken);

        try {
            // Check if this renewal was already processed
            if (isTransactionProcessed(purchaseToken, subscriptionId)) {
                log.info("续费交易已处理过，跳过 - purchaseToken: {}", purchaseToken);
                return;
            }

            // Query Google Play for subscription details
            SubscriptionPurchaseV2 purchase = androidPublisher
                .purchases()
                .subscriptionsv2()
                .get(packageName, purchaseToken)
                .execute();

            if (purchase == null) {
                log.error("无法从 Google Play 获取订阅信息 - purchaseToken: {}", purchaseToken);
                recordEvent("renewal_failed_no_purchase", purchaseToken, subscriptionId);
                return;
            }

            log.info("Google 订阅状态: {}, acknowledgementState: {}",
                     purchase.getSubscriptionState(), purchase.getAcknowledgementState());

            // Get expiry time from line items
            LocalDateTime expiresDate = null;
            String productId = subscriptionId;
            boolean isPrepaid = false;
            List<SubscriptionPurchaseLineItem> lineItems = purchase.getLineItems();
            if (lineItems != null && !lineItems.isEmpty()) {
                SubscriptionPurchaseLineItem item = lineItems.get(0);
                if (item.getExpiryTime() != null) {
                    expiresDate = parseRfc3339(item.getExpiryTime());
                }
                if (item.getProductId() != null) {
                    productId = item.getProductId();
                }
                // 检测是否为预付费订阅
                isPrepaid = item.getPrepaidPlan() != null;
            }

            // 预付费订阅不应该收到续费通知，记录警告并跳过
            if (isPrepaid) {
                log.warn("收到预付费订阅的续费通知，这是异常情况 - productId: {}", productId);
                recordEvent("renewal_prepaid_unexpected", purchaseToken, subscriptionId);
                return;
            }

            if (expiresDate == null) {
                log.error("无法获取订阅到期时间");
                recordEvent("renewal_failed_no_expiry", purchaseToken, subscriptionId);
                return;
            }

            log.info("产品ID: {}, 到期时间: {}", productId, expiresDate);

            // Find the original order by purchase token
            QueryWrapper<Order> originalOrderQuery = new QueryWrapper<>();
            originalOrderQuery.eq("purchase_token", purchaseToken)
                              .orderByDesc("create_time")
                              .last("LIMIT 1");
            Order originalOrder = orderRepository.selectOne(originalOrderQuery);

            if (originalOrder == null) {
                log.error("找不到原始订单，purchaseToken: {}", purchaseToken);
                recordEvent("renewal_failed_no_order", purchaseToken, subscriptionId);
                return;
            }

            Long userId = originalOrder.getUserId();
            log.info("找到用户 ID: {}", userId);

            // Get product info
            SubscriptionProduct product = getProductByGoogleProductId(productId);
            BigDecimal price = product != null ? product.getPrice() : originalOrder.getAmount();
            String planType = product != null ? product.getPlanType() : originalOrder.getSubscriptionPeriod();

            // Create renewal order
            Order renewalOrder = new Order();
            renewalOrder.setUserId(userId);
            renewalOrder.setOrderNo(generateOrderNo());
            renewalOrder.setAmount(price);
            renewalOrder.setStatus("Paid");
            renewalOrder.setPlatform("GooglePay");
            renewalOrder.setProductId(productId);
            renewalOrder.setOrderType("subscription");
            renewalOrder.setSubscriptionPeriod(planType);

            // Set dates
            renewalOrder.setSubscriptionStartDate(LocalDateTime.now());
            renewalOrder.setSubscriptionEndDate(expiresDate);
            renewalOrder.setIsAutoRenew(true);

            renewalOrder.setPurchaseToken(purchaseToken);
            renewalOrder.setPlatformTransactionId(purchaseToken + "_" + System.currentTimeMillis());
            renewalOrder.setVerifiedAt(LocalDateTime.now());
            renewalOrder.setCreateTime(LocalDateTime.now());
            renewalOrder.setUpdateTime(LocalDateTime.now());

            // Copy distributor info from original order
            renewalOrder.setDistributorId(originalOrder.getDistributorId());
            renewalOrder.setSourcePasscodeId(originalOrder.getSourcePasscodeId());
            renewalOrder.setSourceBookId(originalOrder.getSourceBookId());
            renewalOrder.setSourceEntry(originalOrder.getSourceEntry());

            orderRepository.insert(renewalOrder);
            log.info("创建续费订单成功 - 订单号: {}, 订单ID: {}", renewalOrder.getOrderNo(), renewalOrder.getId());

            // Record processed transaction
            recordProcessedTransaction(purchaseToken, subscriptionId, renewalOrder.getId(), productId);

            // Update user subscription status with max-date logic
            updateUserSubscription(userId, expiresDate, planType);

            // Record event
            recordEventWithOrder(userId, renewalOrder.getId(), "renewal_success", purchaseToken, subscriptionId);

            log.info("========== Google Play 订阅续费处理完成 - 新到期时间: {} ==========", expiresDate);

        } catch (Exception e) {
            log.error("处理续费通知失败", e);
            recordEvent("renewal_failed", purchaseToken, subscriptionId);
            throw new RuntimeException("Failed to process renewal", e);
        }
    }

    /**
     * Handle subscription cancellation (user canceled, but still has access until expiry)
     */
    private void handleCancellation(String purchaseToken, String subscriptionId) {
        log.info("Subscription canceled: {}", subscriptionId);

        // User canceled auto-renewal, but subscription is still active until expiry date
        // Update the order/user record to indicate no auto-renewal

        recordEvent("canceled", purchaseToken, subscriptionId);
    }

    /**
     * Handle new subscription purchase
     */
    private void handlePurchased(String purchaseToken, String subscriptionId) {
        log.info("New subscription purchased: {}", subscriptionId);
        // Already handled by the purchase verification flow
        recordEvent("purchased", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription on hold (payment issue)
     */
    private void handleOnHold(String purchaseToken, String subscriptionId) {
        log.warn("Subscription on hold: {}", subscriptionId);

        // Payment failed, subscription is on hold
        // User might still have access during grace period

        recordEvent("on_hold", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription in grace period
     */
    private void handleGracePeriod(String purchaseToken, String subscriptionId) {
        log.warn("Subscription in grace period: {}", subscriptionId);

        // Payment failed but user still has access
        // Send notification to user to update payment method

        recordEvent("grace_period", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription restarted
     */
    private void handleRestarted(String purchaseToken, String subscriptionId) {
        log.info("Subscription restarted: {}", subscriptionId);

        // User reactivated a previously canceled subscription
        recordEvent("restarted", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription revoked (refunded)
     * This is CRITICAL - must immediately revoke user access
     */
    private void handleRevoked(String purchaseToken, String subscriptionId) {
        log.warn("========== 处理 Google Play 退款/撤销通知 ==========");
        log.info("订阅ID: {}, purchaseToken: {}", subscriptionId, purchaseToken);

        try {
            // Find the order by purchase token
            QueryWrapper<Order> orderQuery = new QueryWrapper<>();
            orderQuery.eq("purchase_token", purchaseToken)
                      .orderByDesc("create_time")
                      .last("LIMIT 1");
            Order order = orderRepository.selectOne(orderQuery);

            if (order == null) {
                log.error("找不到对应订单，purchaseToken: {}", purchaseToken);
                recordEvent("revoked_no_order", purchaseToken, subscriptionId);
                return;
            }

            // Mark order as refunded
            order.setStatus("Refunded");
            order.setCancelDate(LocalDateTime.now());
            order.setCancelReason("Google Play Refund/Revoke");
            order.setUpdateTime(LocalDateTime.now());
            orderRepository.updateById(order);
            log.info("订单 {} 已标记为已退款", order.getOrderNo());

            // Revoke user's subscription immediately
            Long userId = order.getUserId();
            User user = userMapper.selectById(userId);
            if (user != null) {
                user.setSubscriptionStatus("refunded");
                user.setIsSvip(false);
                user.setSubscriptionEndDate(LocalDateTime.now()); // Expire immediately
                userMapper.updateById(user);
                log.warn("用户 {} 的订阅已因退款被撤销", userId);
            }

            recordEventWithOrder(userId, order.getId(), "revoked_processed", purchaseToken, subscriptionId);
            log.warn("========== Google Play 退款处理完成 - 用户权限已撤销 ==========");

        } catch (Exception e) {
            log.error("处理退款通知失败", e);
            recordEvent("revoked_failed", purchaseToken, subscriptionId);
            throw new RuntimeException("Failed to process revoke", e);
        }
    }

    /**
     * Handle subscription expired
     *
     * 订阅过期的两种情况：
     * 1. 自动续期订阅 (weekly): 用户取消了自动续期，到期后过期
     * 2. 预付费订阅 (monthly/yearly): 购买的时间用完，到期后过期
     *
     * 预付费订阅过期后，用户需要手动重新购买才能继续使用
     */
    private void handleExpired(String purchaseToken, String subscriptionId) {
        log.info("========== 处理 Google Play 订阅过期通知 ==========");
        log.info("订阅ID: {}, purchaseToken: {}", subscriptionId, purchaseToken);

        try {
            // 查询 Google Play 获取订阅详情，以判断是自动续期还是预付费
            boolean isPrepaid = false;
            try {
                SubscriptionPurchaseV2 purchase = androidPublisher
                    .purchases()
                    .subscriptionsv2()
                    .get(packageName, purchaseToken)
                    .execute();

                if (purchase != null && purchase.getLineItems() != null && !purchase.getLineItems().isEmpty()) {
                    isPrepaid = purchase.getLineItems().get(0).getPrepaidPlan() != null;
                }
            } catch (Exception e) {
                log.warn("查询 Google Play 订阅详情失败，将按普通过期处理: {}", e.getMessage());
            }

            if (isPrepaid) {
                log.info("预付费订阅过期 - 用户需要手动重新购买");
            } else {
                log.info("自动续期订阅过期 - 用户已取消续期或支付失败");
            }

            // Find the order by purchase token
            QueryWrapper<Order> orderQuery = new QueryWrapper<>();
            orderQuery.eq("purchase_token", purchaseToken)
                      .orderByDesc("create_time")
                      .last("LIMIT 1");
            Order order = orderRepository.selectOne(orderQuery);

            if (order != null) {
                Long userId = order.getUserId();
                User user = userMapper.selectById(userId);

                if (user != null) {
                    // Only revoke if subscription actually expired (check end date)
                    LocalDateTime endDate = user.getSubscriptionEndDate();
                    if (endDate == null || endDate.isBefore(LocalDateTime.now())) {
                        user.setSubscriptionStatus("expired");
                        user.setIsSvip(false);
                        userMapper.updateById(user);
                        log.info("用户 {} 订阅已过期 ({}), SVIP 权限已撤销",
                            userId, isPrepaid ? "预付费" : "自动续期");
                    } else {
                        log.info("用户 {} 订阅到期时间 {} 尚未过期，跳过撤销", userId, endDate);
                    }
                }

                String eventType = isPrepaid ? "expired_prepaid" : "expired_autorenew";
                recordEventWithOrder(userId, order.getId(), eventType, purchaseToken, subscriptionId);
            } else {
                recordEvent("expired", purchaseToken, subscriptionId);
            }

            log.info("========== Google Play 订阅过期处理完成 ==========");

        } catch (Exception e) {
            log.error("处理过期通知失败", e);
            recordEvent("expired_failed", purchaseToken, subscriptionId);
        }
    }

    /**
     * Record subscription event
     */
    private void recordEvent(String eventType, String purchaseToken, String subscriptionId) {
        try {
            SubscriptionEvent event = new SubscriptionEvent();
            event.setEventType(eventType);
            event.setPlatform("GooglePay");
            event.setNotificationData(String.format(
                "subscriptionId=%s, purchaseToken=%s", subscriptionId, purchaseToken));
            event.setProcessedAt(LocalDateTime.now());
            event.setEventDate(LocalDateTime.now());
            event.setProcessed(true);
            event.setCreatedAt(LocalDateTime.now());

            subscriptionEventRepository.insert(event);
            log.info("Recorded {} event for {}", eventType, subscriptionId);
        } catch (Exception e) {
            log.error("Failed to record event: {}", eventType, e);
        }
    }

    /**
     * Record event with userId and orderId
     */
    private void recordEventWithOrder(Long userId, Long orderId, String eventType,
                                      String purchaseToken, String subscriptionId) {
        try {
            SubscriptionEvent event = new SubscriptionEvent();
            event.setUserId(userId);
            event.setOrderId(orderId);
            event.setEventType(eventType);
            event.setPlatform("GooglePay");
            event.setNotificationData(String.format(
                "subscriptionId=%s, purchaseToken=%s", subscriptionId, purchaseToken));
            event.setEventDate(LocalDateTime.now());
            event.setProcessed(true);
            event.setProcessedAt(LocalDateTime.now());
            event.setCreatedAt(LocalDateTime.now());

            subscriptionEventRepository.insert(event);
            log.debug("记录事件: {} (用户: {}, 订单: {})", eventType, userId, orderId);
        } catch (Exception e) {
            log.error("记录事件失败: {} (用户: {}, 订单: {})", eventType, userId, orderId, e);
        }
    }

    /**
     * Check if transaction was already processed
     */
    private boolean isTransactionProcessed(String purchaseToken, String subscriptionId) {
        QueryWrapper<ProcessedTransaction> query = new QueryWrapper<>();
        // Use purchaseToken + subscriptionId as unique identifier for Google
        query.eq("platform_transaction_id", purchaseToken)
             .eq("product_id", subscriptionId)
             .eq("platform", "GooglePay");
        return processedTransactionRepository.selectCount(query) > 0;
    }

    /**
     * Record processed transaction
     */
    private void recordProcessedTransaction(String purchaseToken, String subscriptionId,
                                           Long orderId, String productId) {
        ProcessedTransaction processed = new ProcessedTransaction();
        processed.setPlatformTransactionId(purchaseToken);
        processed.setOriginalTransactionId(purchaseToken); // Google uses same token
        processed.setOrderId(orderId);
        processed.setPlatform("GooglePay");
        processed.setProductId(productId);
        processed.setProcessedAt(LocalDateTime.now());
        processedTransactionRepository.insert(processed);
    }

    /**
     * Update user subscription status with max-date logic
     * Takes the later of current end date and new end date to avoid losing paid time
     */
    private void updateUserSubscription(Long userId, LocalDateTime endDate, String planType) {
        User user = userMapper.selectById(userId);
        if (user != null) {
            LocalDateTime currentEndDate = user.getSubscriptionEndDate();
            LocalDateTime finalEndDate;

            // 取两者中较晚的时间，避免用户损失已付费时长
            if (currentEndDate != null && currentEndDate.isAfter(endDate)) {
                finalEndDate = currentEndDate;
                log.warn("用户 {} 已有更晚的订阅到期时间 {} (webhook新时间: {})，保持原时间不变",
                         userId, currentEndDate, endDate);
            } else if (currentEndDate != null && currentEndDate.isAfter(LocalDateTime.now())) {
                // 新订阅时间更晚，但旧订阅还没过期
                finalEndDate = endDate;
                long remainingDays = java.time.temporal.ChronoUnit.DAYS.between(LocalDateTime.now(), currentEndDate);
                log.info("用户 {} 原订阅剩余 {} 天 (到期: {})，通过webhook更新为新到期时间: {}",
                         userId, remainingDays, currentEndDate, endDate);
            } else {
                // 无旧订阅或旧订阅已过期
                finalEndDate = endDate;
                log.info("用户 {} 通过webhook订阅更新为: {}", userId, endDate);
            }

            user.setIsSvip(true);
            user.setSubscriptionStatus("active");
            user.setSubscriptionEndDate(finalEndDate);
            user.setSubscriptionPlanType(planType);
            userMapper.updateById(user);

            log.info("用户 {} 订阅状态已更新 - 最终到期时间: {}", userId, finalEndDate);
        }
    }

    /**
     * Get product by Google product ID
     */
    private SubscriptionProduct getProductByGoogleProductId(String productId) {
        QueryWrapper<SubscriptionProduct> query = new QueryWrapper<>();
        query.eq("google_product_id", productId);
        SubscriptionProduct product = subscriptionProductRepository.selectOne(query);
        if (product == null) {
            // Fallback: try product_id field
            query = new QueryWrapper<>();
            query.eq("product_id", productId);
            product = subscriptionProductRepository.selectOne(query);
        }
        return product;
    }

    /**
     * Generate order number
     */
    private String generateOrderNo() {
        return "ORD" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }

    /**
     * Parse RFC 3339 timestamp to LocalDateTime
     */
    private LocalDateTime parseRfc3339(String timestamp) {
        if (timestamp == null) {
            return null;
        }
        try {
            Instant instant = Instant.parse(timestamp);
            return instant.atZone(ZoneId.systemDefault()).toLocalDateTime();
        } catch (Exception e) {
            log.error("无法解析时间戳: {}", timestamp, e);
            return null;
        }
    }
}
