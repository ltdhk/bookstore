package com.bookstore.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.AppleNotificationV2Payload;
import com.bookstore.dto.AppleServerNotification;
import com.bookstore.dto.AppleTransactionInfo;
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
import com.bookstore.util.AppleJwtDecoder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

/**
 * Apple App Store Server Notification Handler
 * Supports both V1 and V2 notification formats
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppleWebhookService {

    private final OrderRepository orderRepository;
    private final ProcessedTransactionRepository processedTransactionRepository;
    private final UserMapper userMapper;
    private final SubscriptionEventRepository subscriptionEventRepository;
    private final SubscriptionProductRepository subscriptionProductRepository;
    private final AppleJwtDecoder jwtDecoder;

    /**
     * Handle Apple server notification V2 (JWT signed payload)
     */
    @Transactional
    public void handleV2Notification(String signedPayload) {
        log.info("处理 Apple V2 通知 - 解码 JWT payload");

        try {
            // Decode the outer JWT
            AppleNotificationV2Payload payload = jwtDecoder.decodeNotificationPayload(signedPayload);

            String notificationType = payload.getNotificationType();
            String notificationUuid = payload.getNotificationUUID();

            log.info("V2 通知类型: {}, UUID: {}, 环境: {}",
                notificationType, notificationUuid, payload.getData().getEnvironment());

            // Decode the transaction info
            AppleTransactionInfo transactionInfo = null;
            if (payload.getData().getSignedTransactionInfo() != null) {
                transactionInfo = jwtDecoder.decodeTransactionInfo(
                    payload.getData().getSignedTransactionInfo()
                );
                log.info("交易信息 - 产品: {}, 交易ID: {}, 原始交易ID: {}",
                    transactionInfo.getProductId(),
                    transactionInfo.getTransactionId(),
                    transactionInfo.getOriginalTransactionId());
            }

            // Route to appropriate handler
            handleNotificationType(notificationType, transactionInfo, notificationUuid);

        } catch (Exception e) {
            log.error("处理 V2 通知失败", e);
            throw new RuntimeException("Failed to handle V2 notification", e);
        }
    }

    /**
     * Handle Apple server notification V1 (legacy format)
     */
    @Transactional
    public void handleNotification(AppleServerNotification notification) {
        String notificationType = notification.getNotificationType();
        String notificationUuid = notification.getNotificationUuid();

        log.info("Received Apple V1 notification: type={}, uuid={}", notificationType, notificationUuid);

        // Check for null notification type
        if (notificationType == null) {
            log.warn("Received Apple notification with null type, skipping. UUID: {}, Data: {}",
                notificationUuid, notification.getData());
            return;
        }

        // V1 format doesn't have easily accessible transaction info
        // Log and skip for now
        log.warn("V1 通知暂不完整支持，建议升级到 V2 格式。类型: {}", notificationType);
        recordEvent("v1_" + notificationType.toLowerCase(), notificationUuid, null, null);
    }

    /**
     * Route notification to appropriate handler based on type
     */
    private void handleNotificationType(String notificationType, AppleTransactionInfo transactionInfo, String notificationUuid) {
        try {
            switch (notificationType) {
                case "ONE_TIME_CHARGE":
                    handleOneTimeCharge(transactionInfo, notificationUuid);
                    break;
                case "SUBSCRIBED":
                    handleSubscribed(transactionInfo, notificationUuid);
                    break;
                case "DID_RENEW":
                    handleRenewal(transactionInfo, notificationUuid);
                    break;
                case "DID_FAIL_TO_RENEW":
                    handleRenewalFailure(transactionInfo, notificationUuid);
                    break;
                case "DID_CHANGE_RENEWAL_STATUS":
                    handleRenewalStatusChange(transactionInfo, notificationUuid);
                    break;
                case "EXPIRED":
                    handleExpiration(transactionInfo, notificationUuid);
                    break;
                case "REFUND":
                    handleRefund(transactionInfo, notificationUuid);
                    break;
                case "GRACE_PERIOD_EXPIRED":
                    handleGracePeriodExpired(transactionInfo, notificationUuid);
                    break;
                case "REVOKE":
                    handleRevoke(transactionInfo, notificationUuid);
                    break;
                default:
                    log.warn("未处理的通知类型: {}", notificationType);
                    recordEvent("unhandled_" + notificationType.toLowerCase(), notificationUuid,
                               transactionInfo != null ? transactionInfo.getOriginalTransactionId() : null,
                               transactionInfo != null ? transactionInfo.getProductId() : null);
            }
        } catch (Exception e) {
            log.error("处理通知类型 {} 失败", notificationType, e);
            throw e;
        }
    }

    /**
     * Handle ONE_TIME_CHARGE notification (non-auto-renewable subscription purchase)
     */
    private void handleOneTimeCharge(AppleTransactionInfo txn, String notificationUuid) {
        log.info("处理一次性购买通知 - 产品: {}, 交易ID: {}", txn.getProductId(), txn.getTransactionId());

        // Check if already processed
        if (isTransactionProcessed(txn.getTransactionId())) {
            log.info("交易 {} 已处理过，跳过", txn.getTransactionId());
            return;
        }

        // This confirms the purchase, but the order should already be created by the purchase flow
        // We'll just record the event for tracking
        recordEvent("one_time_charge", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());

        log.info("一次性购买通知处理完成 - 购买已在购买流程中确认");
    }

    /**
     * Handle SUBSCRIBED notification (new subscription or resubscribe)
     */
    private void handleSubscribed(AppleTransactionInfo txn, String notificationUuid) {
        log.info("处理新订阅通知 - 产品: {}, 交易ID: {}", txn.getProductId(), txn.getTransactionId());

        // Find the order by originalTransactionId to get userId and orderId
        QueryWrapper<Order> orderQuery = new QueryWrapper<>();
        orderQuery.eq("original_transaction_id", txn.getOriginalTransactionId())
                  .orderByDesc("create_time")
                  .last("LIMIT 1");
        Order order = orderRepository.selectOne(orderQuery);

        if (order != null) {
            // Record the subscription event with userId and orderId
            recordEventWithOrder(order.getUserId(), order.getId(), "subscribed",
                               notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
        } else {
            log.warn("无法找到原始订单来记录SUBSCRIBED事件 - originalTransactionId: {}",
                    txn.getOriginalTransactionId());
            // Still record the event without userId/orderId
            recordEvent("subscribed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
        }
    }

    /**
     * Handle DID_RENEW notification (subscription renewed)
     * This is CRITICAL - creates renewal order and extends subscription
     */
    private void handleRenewal(AppleTransactionInfo txn, String notificationUuid) {
        log.info("========== 处理订阅续费通知 ==========");
        log.info("产品: {}, 新交易ID: {}, 原始交易ID: {}",
                 txn.getProductId(), txn.getTransactionId(), txn.getOriginalTransactionId());

        try {
            // Check if this renewal transaction was already processed
            if (isTransactionProcessed(txn.getTransactionId())) {
                log.info("续费交易 {} 已处理过，跳过", txn.getTransactionId());
                return;
            }

            // Find the user by original transaction ID
            QueryWrapper<Order> originalOrderQuery = new QueryWrapper<>();
            originalOrderQuery.eq("original_transaction_id", txn.getOriginalTransactionId())
                              .orderByDesc("create_time")
                              .last("LIMIT 1");
            Order originalOrder = orderRepository.selectOne(originalOrderQuery);

            if (originalOrder == null) {
                log.error("找不到原始订单，原始交易ID: {}", txn.getOriginalTransactionId());
                recordEvent("renewal_failed_no_order", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
                return;
            }

            Long userId = originalOrder.getUserId();
            log.info("找到用户 ID: {}", userId);

            // Get product info
            SubscriptionProduct product = getProductByProductId(txn.getProductId());
            if (product == null) {
                log.error("产品不存在: {}", txn.getProductId());
                return;
            }

            // Create renewal order
            Order renewalOrder = new Order();
            renewalOrder.setUserId(userId);
            renewalOrder.setOrderNo(generateOrderNo());
            renewalOrder.setAmount(product.getPrice());
            renewalOrder.setStatus("Paid");
            renewalOrder.setPlatform("AppStore");
            renewalOrder.setProductId(txn.getProductId());
            renewalOrder.setOrderType("subscription");
            renewalOrder.setSubscriptionPeriod(product.getPlanType());

            // Set dates from transaction info
            LocalDateTime purchaseDate = convertToLocalDateTime(txn.getPurchaseDate());
            LocalDateTime expiresDate = convertToLocalDateTime(txn.getExpiresDate());
            renewalOrder.setSubscriptionStartDate(purchaseDate);
            renewalOrder.setSubscriptionEndDate(expiresDate);
            renewalOrder.setIsAutoRenew(true);

            renewalOrder.setOriginalTransactionId(txn.getOriginalTransactionId());
            renewalOrder.setPlatformTransactionId(txn.getTransactionId());
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
            recordProcessedTransaction(txn.getTransactionId(), txn.getOriginalTransactionId(),
                                      renewalOrder.getId(), "AppStore", txn.getProductId());

            // Update user subscription status
            updateUserSubscription(userId, expiresDate, product.getPlanType());

            // Record event
            recordEventWithOrder(userId, renewalOrder.getId(), "renewal_success", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());

            log.info("订阅续费处理完成 - 新到期时间: {}", expiresDate);

        } catch (Exception e) {
            log.error("处理续费通知失败", e);
            recordEventWithOrder(null, null, "renewal_failed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
            throw e;
        }
    }

    /**
     * Handle REFUND notification
     * This is CRITICAL - must immediately revoke user access
     */
    private void handleRefund(AppleTransactionInfo txn, String notificationUuid) {
        log.warn("========== 处理退款通知 ==========");
        log.info("产品: {}, 交易ID: {}", txn.getProductId(), txn.getTransactionId());

        try {
            // Find the order
            QueryWrapper<Order> orderQuery = new QueryWrapper<>();
            orderQuery.eq("platform_transaction_id", txn.getTransactionId());
            Order order = orderRepository.selectOne(orderQuery);

            if (order == null) {
                log.error("找不到对应订单，交易ID: {}", txn.getTransactionId());
                recordEvent("refund_no_order", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
                return;
            }

            // Mark order as refunded
            order.setStatus("Refunded");
            order.setCancelDate(LocalDateTime.now());
            order.setCancelReason("Apple App Store Refund");
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

            recordEvent("refund_processed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());

            log.warn("退款处理完成 - 用户权限已撤销");

        } catch (Exception e) {
            log.error("处理退款通知失败", e);
            recordEvent("refund_failed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
            throw e;
        }
    }

    /**
     * Handle DID_FAIL_TO_RENEW notification
     */
    private void handleRenewalFailure(AppleTransactionInfo txn, String notificationUuid) {
        log.warn("订阅续费失败 - 产品: {}, 原始交易ID: {}", txn.getProductId(), txn.getOriginalTransactionId());

        // TODO: Send notification to user to update payment method
        recordEvent("renewal_failed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
    }

    /**
     * Handle DID_CHANGE_RENEWAL_STATUS notification
     */
    private void handleRenewalStatusChange(AppleTransactionInfo txn, String notificationUuid) {
        log.info("订阅续费状态变更 - 产品: {}", txn.getProductId());

        // TODO: Update auto-renew status in order
        recordEvent("renewal_status_changed", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
    }

    /**
     * Handle EXPIRED notification
     */
    private void handleExpiration(AppleTransactionInfo txn, String notificationUuid) {
        log.info("订阅过期通知 - 产品: {}", txn.getProductId());

        // Handled by scheduled task, just record
        recordEvent("expired", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
    }

    /**
     * Handle GRACE_PERIOD_EXPIRED notification
     */
    private void handleGracePeriodExpired(AppleTransactionInfo txn, String notificationUuid) {
        log.warn("宽限期已过期 - 产品: {}", txn.getProductId());

        // TODO: Revoke access after grace period
        recordEvent("grace_period_expired", notificationUuid, txn.getOriginalTransactionId(), txn.getProductId());
    }

    /**
     * Handle REVOKE notification
     */
    private void handleRevoke(AppleTransactionInfo txn, String notificationUuid) {
        log.warn("订阅被撤销 - 产品: {}", txn.getProductId());

        // Similar to refund - revoke access immediately
        handleRefund(txn, notificationUuid);
    }

    /**
     * Check if transaction was already processed
     */
    private boolean isTransactionProcessed(String platformTransactionId) {
        QueryWrapper<ProcessedTransaction> query = new QueryWrapper<>();
        query.eq("platform_transaction_id", platformTransactionId);
        return processedTransactionRepository.selectCount(query) > 0;
    }

    /**
     * Record processed transaction
     */
    private void recordProcessedTransaction(String platformTransactionId, String originalTransactionId,
                                           Long orderId, String platform, String productId) {
        ProcessedTransaction processed = new ProcessedTransaction();
        processed.setPlatformTransactionId(platformTransactionId);
        processed.setOriginalTransactionId(originalTransactionId);
        processed.setOrderId(orderId);
        processed.setPlatform(platform);
        processed.setProductId(productId);
        processed.setProcessedAt(LocalDateTime.now());
        processedTransactionRepository.insert(processed);
    }

    /**
     * Update user subscription status
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
     * Get product by product ID
     */
    private SubscriptionProduct getProductByProductId(String productId) {
        QueryWrapper<SubscriptionProduct> query = new QueryWrapper<>();
        query.eq("product_id", productId);
        return subscriptionProductRepository.selectOne(query);
    }

    /**
     * Generate order number
     */
    private String generateOrderNo() {
        return "ORD" + System.currentTimeMillis() + (int)(Math.random() * 1000);
    }

    /**
     * Convert milliseconds to LocalDateTime
     */
    private LocalDateTime convertToLocalDateTime(Long milliseconds) {
        if (milliseconds == null) {
            return null;
        }
        return Instant.ofEpochMilli(milliseconds)
                      .atZone(ZoneId.systemDefault())
                      .toLocalDateTime();
    }

    /**
     * Record subscription event
     */
    private void recordEvent(String eventType, String notificationUuid, String originalTransactionId, String productId) {
        try {
            SubscriptionEvent event = new SubscriptionEvent();
            event.setEventType(eventType);
            event.setPlatform("AppStore");
            event.setOriginalTransactionId(originalTransactionId);
            event.setNotificationData(notificationUuid);
            event.setEventDate(LocalDateTime.now());
            event.setProcessed(true);
            event.setProcessedAt(LocalDateTime.now());
            event.setCreatedAt(LocalDateTime.now());

            subscriptionEventRepository.insert(event);
            log.debug("记录事件: {}", eventType);
        } catch (Exception e) {
            log.error("记录事件失败: {}", eventType, e);
        }
    }

    /**
     * Record event with userId and orderId
     */
    private void recordEventWithOrder(Long userId, Long orderId, String eventType,
                                     String notificationUuid, String originalTransactionId, String productId) {
        try {
            SubscriptionEvent event = new SubscriptionEvent();
            event.setUserId(userId);
            event.setOrderId(orderId);
            event.setEventType(eventType);
            event.setPlatform("AppStore");
            event.setOriginalTransactionId(originalTransactionId);
            event.setNotificationData(notificationUuid);
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
}
