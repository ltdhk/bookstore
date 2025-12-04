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

        // Check auto-renewing from line item
        Boolean autoRenewingFlag = firstLineItem.getAutoRenewingPlan() != null;
        boolean autoRenewing = autoRenewingFlag != null && autoRenewingFlag;

        // Use latestOrderId as transaction ID
        String transactionId = purchase.getLatestOrderId();
        String originalTransactionId = transactionId; // Use same ID

        return SubscriptionInfo.builder()
            .originalTransactionId(originalTransactionId)
            .transactionId(transactionId)
            .productId(productId)
            .purchaseDate(purchaseDate != null ? purchaseDate : LocalDateTime.now())
            .expiryDate(expiryDate != null ? expiryDate : LocalDateTime.now().plusDays(7))
            .autoRenewing(autoRenewing)
            .valid(valid)
            .build();
    }

    /**
     * Parse RFC 3339 timestamp to LocalDateTime
     */
    private LocalDateTime parseRFC3339ToLocalDateTime(String timestamp) {
        if (timestamp == null || timestamp.isEmpty()) {
            return null;
        }
        try {
            // Parse ISO 8601 / RFC 3339 format
            return LocalDateTime.parse(timestamp.replace("Z", ""),
                java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME);
        } catch (Exception e) {
            log.warn("Failed to parse timestamp: {}", timestamp, e);
            return null;
        }
    }
}
