package com.bookstore.service;

import com.bookstore.dto.SubscriptionInfo;
import com.bookstore.exception.ReceiptVerificationException;
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.model.SubscriptionPurchaseV2;
import com.google.api.services.androidpublisher.model.SubscriptionPurchasesAcknowledgeRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

/**
 * Google Play receipt verification service
 * Verifies Google Play purchase tokens with Google Play Developer API
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleReceiptVerificationService {

    private final AndroidPublisher androidPublisher;

    @Value("${iap.google.package-name}")
    private String packageName;

    /**
     * Verify Google Play purchase
     * @param productId Product ID (subscription ID, used for V1 acknowledge API)
     * @param purchaseToken Purchase token from client
     * @return Subscription information
     */
    public SubscriptionInfo verifyPurchase(String productId, String purchaseToken) {
        try {
            log.info("Verifying Google Play purchase for token: {}", purchaseToken);

            // Get subscription purchase details from Google Play API (V2)
            SubscriptionPurchaseV2 purchase = androidPublisher
                .purchases()
                .subscriptionsv2()
                .get(packageName, purchaseToken)
                .execute();

            // Note: V2 API doesn't support acknowledge, must use V1 API if needed
            // Check if purchase needs acknowledgement
            String acknowledgementState = purchase.getAcknowledgementState();
            if (acknowledgementState == null || !acknowledgementState.equals("ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED")) {
                log.info("Acknowledging purchase token: {} with productId: {}", purchaseToken, productId);
                acknowledgePurchaseV1(productId, purchaseToken);
            }

            return parseGoogleSubscription(purchase, productId);

        } catch (Exception e) {
            log.error("Failed to verify Google Play purchase", e);
            throw new ReceiptVerificationException("Failed to verify Google Play purchase: " + e.getMessage(), e);
        }
    }

    /**
     * Acknowledge Google Play purchase using V1 API
     * (V2 API doesn't support acknowledge operation)
     */
    private void acknowledgePurchaseV1(String subscriptionId, String purchaseToken) {
        try {
            SubscriptionPurchasesAcknowledgeRequest acknowledgeRequest =
                new SubscriptionPurchasesAcknowledgeRequest();

            androidPublisher
                .purchases()
                .subscriptions()
                .acknowledge(packageName, subscriptionId, purchaseToken, acknowledgeRequest)
                .execute();

            log.info("Purchase acknowledged successfully using V1 API");

        } catch (Exception e) {
            log.error("Failed to acknowledge purchase", e);
            // Don't throw exception, acknowledgement failure shouldn't block verification
        }
    }

    /**
     * Parse Google subscription V2 to SubscriptionInfo
     *
     * Google Play 订阅类型：
     * - Auto-renewing (自动续期): getAutoRenewingPlan() != null，如 weekly
     * - Prepaid (预付费): getPrepaidPlan() != null，如 monthly/yearly
     *
     * 预付费订阅不会自动续费，到期后用户需要手动重新购买
     */
    private SubscriptionInfo parseGoogleSubscription(SubscriptionPurchaseV2 purchase, String productId) {
        // Get subscription state (SUBSCRIPTION_STATE_ACTIVE = valid)
        String subscriptionState = purchase.getSubscriptionState();
        boolean valid = "SUBSCRIPTION_STATE_ACTIVE".equals(subscriptionState);

        // Get line items (subscription details)
        if (purchase.getLineItems() == null || purchase.getLineItems().isEmpty()) {
            throw new ReceiptVerificationException("No line items found in Google purchase");
        }

        // Get first line item
        var lineItems = purchase.getLineItems();
        var firstLineItem = lineItems.get(0);

        // Parse timestamps from startTime (RFC 3339 format: "2024-01-01T00:00:00Z")
        String startTime = purchase.getStartTime();
        LocalDateTime purchaseDate = parseRFC3339ToLocalDateTime(startTime);

        // Parse expiry time from line item
        String expiryTime = firstLineItem.getExpiryTime();
        LocalDateTime expiryDate = parseRFC3339ToLocalDateTime(expiryTime);

        // 检测订阅类型：自动续期 vs 预付费
        // - Auto-renewing: getAutoRenewingPlan() != null (weekly)
        // - Prepaid: getPrepaidPlan() != null (monthly, yearly)
        boolean isPrepaid = firstLineItem.getPrepaidPlan() != null;
        boolean isAutoRenewing = firstLineItem.getAutoRenewingPlan() != null;

        // 只有自动续期订阅才设置 autoRenewing = true
        // 预付费订阅不会自动续费，到期后需要用户手动购买
        boolean autoRenewing = isAutoRenewing && !isPrepaid;

        log.info("Google 订阅类型检测 - productId: {}, isPrepaid: {}, isAutoRenewing: {}, 最终autoRenewing: {}",
            productId, isPrepaid, isAutoRenewing, autoRenewing);
        log.info("Google 时间信息 - startTime: {}, expiryTime: {}, purchaseDate: {}, expiryDate: {}",
            startTime, expiryTime, purchaseDate, expiryDate);

        // Use latestOrderId as transaction ID
        String transactionId = purchase.getLatestOrderId();
        String originalTransactionId = transactionId; // Use same ID

        // 重要：不要在这里设置默认的到期时间！
        // 如果 expiryDate 为 null，应该让 SubscriptionServiceImpl 根据产品的 durationDays 计算
        // 之前的 LocalDateTime.now().plusDays(7) 会导致预付费订阅（monthly/yearly）获得错误的到期时间
        return SubscriptionInfo.builder()
            .originalTransactionId(originalTransactionId)
            .transactionId(transactionId)
            .productId(productId)
            .purchaseDate(purchaseDate != null ? purchaseDate : LocalDateTime.now())
            .expiryDate(expiryDate)  // 不设置默认值，让调用方根据产品类型处理
            .autoRenewing(autoRenewing)
            .valid(valid)
            .build();
    }

    /**
     * Parse RFC 3339 timestamp to LocalDateTime
     * 支持以下格式：
     * - 2024-01-01T00:00:00Z
     * - 2024-01-01T00:00:00.000Z
     * - 2024-01-01T00:00:00+08:00
     */
    private LocalDateTime parseRFC3339ToLocalDateTime(String timestamp) {
        if (timestamp == null || timestamp.isEmpty()) {
            return null;
        }
        try {
            // 使用 Instant.parse 来处理各种 RFC 3339 格式（包括时区）
            Instant instant = Instant.parse(timestamp);
            return instant.atZone(ZoneId.systemDefault()).toLocalDateTime();
        } catch (Exception e) {
            log.warn("Failed to parse timestamp with Instant.parse: {}, trying alternative method", timestamp);
            try {
                // 备用方法：去掉 Z 后解析
                return LocalDateTime.parse(timestamp.replace("Z", ""),
                    java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            } catch (Exception e2) {
                log.error("Failed to parse timestamp: {}", timestamp, e2);
                return null;
            }
        }
    }
}
