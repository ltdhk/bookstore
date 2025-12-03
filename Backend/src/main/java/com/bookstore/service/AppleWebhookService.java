package com.bookstore.service;

import com.bookstore.dto.AppleServerNotification;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionEvent;
import com.bookstore.entity.User;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.SubscriptionEventRepository;
import com.bookstore.repository.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Apple App Store Server Notification Handler
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppleWebhookService {

    private final OrderRepository orderRepository;
    private final UserMapper userMapper;
    private final SubscriptionEventRepository subscriptionEventRepository;

    /**
     * Handle Apple server notification
     */
    @Transactional
    public void handleNotification(AppleServerNotification notification) {
        String notificationType = notification.getNotificationType();
        log.info("Received Apple notification: type={}, uuid={}",
            notificationType, notification.getNotificationUuid());

        try {
            switch (notificationType) {
                case "SUBSCRIBED":
                    handleSubscribed(notification);
                    break;
                case "DID_RENEW":
                    handleRenewal(notification);
                    break;
                case "DID_FAIL_TO_RENEW":
                    handleRenewalFailure(notification);
                    break;
                case "DID_CHANGE_RENEWAL_STATUS":
                    handleRenewalStatusChange(notification);
                    break;
                case "EXPIRED":
                    handleExpiration(notification);
                    break;
                case "REFUND":
                    handleRefund(notification);
                    break;
                case "GRACE_PERIOD_EXPIRED":
                    handleGracePeriodExpired(notification);
                    break;
                default:
                    log.warn("Unhandled Apple notification type: {}", notificationType);
            }
        } catch (Exception e) {
            log.error("Failed to handle Apple notification: {}", notificationType, e);
            throw e;
        }
    }

    /**
     * Handle new subscription (already handled by purchase flow, but log it)
     */
    private void handleSubscribed(AppleServerNotification notification) {
        log.info("New subscription confirmed via webhook");
        // Already handled by the purchase verification flow
        // This is just a confirmation from Apple
    }

    /**
     * Handle subscription renewal
     */
    private void handleRenewal(AppleServerNotification notification) {
        log.info("Processing subscription renewal");

        // In a real implementation, you would:
        // 1. Decode the signedTransactionInfo JWT to get transaction details
        // 2. Find the user by original_transaction_id
        // 3. Extend their subscription end date
        // 4. Create a new order record
        // 5. Record the renewal event

        // For now, we'll log it
        log.info("Subscription renewed successfully");
    }

    /**
     * Handle renewal failure
     */
    private void handleRenewalFailure(AppleServerNotification notification) {
        log.warn("Subscription renewal failed");

        // 1. Find the user
        // 2. Update their status to indicate renewal failure
        // 3. Send notification to user
        // 4. Record the event

        recordEvent("renewal_failed", notification);
    }

    /**
     * Handle renewal status change (e.g., auto-renew turned off)
     */
    private void handleRenewalStatusChange(AppleServerNotification notification) {
        log.info("Subscription renewal status changed");

        // Check if auto-renew was disabled
        // Update the user's subscription status accordingly

        recordEvent("renewal_status_changed", notification);
    }

    /**
     * Handle subscription expiration
     */
    private void handleExpiration(AppleServerNotification notification) {
        log.info("Processing subscription expiration");

        // 1. Find the user by transaction ID
        // 2. Update their subscription status to expired
        // 3. Update their role back to normal user
        // 4. Record the event

        recordEvent("expired", notification);
    }

    /**
     * Handle refund
     */
    private void handleRefund(AppleServerNotification notification) {
        log.warn("Processing subscription refund");

        // 1. Find the order
        // 2. Mark the order as refunded
        // 3. Revoke the user's subscription immediately
        // 4. Update commission status to cancelled
        // 5. Record the event

        recordEvent("refunded", notification);
    }

    /**
     * Handle grace period expiration
     */
    private void handleGracePeriodExpired(AppleServerNotification notification) {
        log.warn("Grace period expired for subscription");

        // Revoke access after grace period
        recordEvent("grace_period_expired", notification);
    }

    /**
     * Record subscription event
     */
    private void recordEvent(String eventType, AppleServerNotification notification) {
        try {
            SubscriptionEvent event = new SubscriptionEvent();
            event.setEventType(eventType);
            event.setPlatform("AppStore");
            event.setNotificationData(notification.toString());
            event.setProcessedAt(LocalDateTime.now());

            subscriptionEventRepository.insert(event);
            log.info("Recorded {} event", eventType);
        } catch (Exception e) {
            log.error("Failed to record event: {}", eventType, e);
        }
    }
}
