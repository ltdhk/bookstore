package com.bookstore.service;

import com.bookstore.dto.GooglePlayNotification;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionEvent;
import com.bookstore.entity.User;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.SubscriptionEventRepository;
import com.bookstore.repository.UserMapper;
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.model.SubscriptionPurchaseV2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

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
     */
    private void handleRenewal(String purchaseToken, String subscriptionId) {
        log.info("Processing subscription renewal: {}", subscriptionId);

        try {
            // Query Google Play for subscription details
            SubscriptionPurchaseV2 purchase = androidPublisher
                .purchases()
                .subscriptionsv2()
                .get(packageName, purchaseToken)
                .execute();

            // In a real implementation:
            // 1. Find the user by purchase token or original transaction ID
            // 2. Extend their subscription end date
            // 3. Create a new order record
            // 4. Calculate and record commission for renewal

            recordEvent("renewed", purchaseToken, subscriptionId);
            log.info("Subscription renewed successfully: {}", subscriptionId);
        } catch (Exception e) {
            log.error("Failed to process renewal for: {}", subscriptionId, e);
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
     */
    private void handleRevoked(String purchaseToken, String subscriptionId) {
        log.warn("Subscription revoked (refunded): {}", subscriptionId);

        // Google issued a refund, revoke access immediately
        // Update order status to refunded
        // Cancel commission

        recordEvent("revoked", purchaseToken, subscriptionId);
    }

    /**
     * Handle subscription expired
     */
    private void handleExpired(String purchaseToken, String subscriptionId) {
        log.info("Subscription expired: {}", subscriptionId);

        // Subscription has ended and was not renewed
        // Revoke user's SVIP access

        recordEvent("expired", purchaseToken, subscriptionId);
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

            subscriptionEventRepository.insert(event);
            log.info("Recorded {} event for {}", eventType, subscriptionId);
        } catch (Exception e) {
            log.error("Failed to record event: {}", eventType, e);
        }
    }
}
