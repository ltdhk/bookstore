package com.bookstore.service;

import com.bookstore.dto.SubscriptionInfo;
import com.bookstore.exception.ReceiptVerificationException;
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.model.SubscriptionPurchaseV2;
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
     * @param productId Product ID
     * @param purchaseToken Purchase token from client
     * @return Subscription information
     */
    public SubscriptionInfo verifyPurchase(String productId, String purchaseToken) {
        try {
            log.info("Verifying Google Play purchase for product: {}", productId);

            // Get subscription purchase details from Google Play API
            SubscriptionPurchaseV2 purchase = androidPublisher
                .purchases()
                .subscriptionsv2()
                .get(packageName, purchaseToken)
                .execute();

            // Check if purchase needs acknowledgement
            if (purchase.getAcknowledgementState() == null ||
                purchase.getAcknowledgementState() != 1) {
                log.info("Acknowledging purchase token: {}", purchaseToken);
                acknowledgePurchase(purchaseToken);
            }

            return parseGoogleSubscription(purchase, productId);

        } catch (Exception e) {
            log.error("Failed to verify Google Play purchase", e);
            throw new ReceiptVerificationException("Failed to verify Google Play purchase: " + e.getMessage(), e);
        }
    }

    /**
     * Acknowledge Google Play purchase
     */
    private void acknowledgePurchase(String purchaseToken) {
        try {
            androidPublisher
                .purchases()
                .subscriptionsv2()
                .acknowledge(packageName, purchaseToken)
                .execute();

            log.info("Purchase acknowledged successfully");

        } catch (Exception e) {
            log.error("Failed to acknowledge purchase", e);
            // Don't throw exception, acknowledgement failure shouldn't block verification
        }
    }

    /**
     * Parse Google subscription to SubscriptionInfo
     */
    private SubscriptionInfo parseGoogleSubscription(SubscriptionPurchaseV2 purchase, String productId) {
        // Get subscription state
        Integer subscriptionState = purchase.getSubscriptionState();
        boolean valid = subscriptionState != null && subscriptionState == 1; // SUBSCRIPTION_STATE_ACTIVE

        // Get line items (subscription details)
        if (purchase.getLineItems() == null || purchase.getLineItems().isEmpty()) {
            throw new ReceiptVerificationException("No line items found in Google purchase");
        }

        SubscriptionPurchaseV2.LineItem lineItem = purchase.getLineItems().get(0);

        // Parse timestamps
        String startTimeMillis = lineItem.getExpiryTime();
        LocalDateTime purchaseDate = LocalDateTime.now(); // Google doesn't provide exact purchase date in V2

        LocalDateTime expiryDate = null;
        if (startTimeMillis != null) {
            try {
                long expiryMs = Long.parseLong(startTimeMillis.replaceAll("[^0-9]", ""));
                expiryDate = LocalDateTime.ofInstant(
                    Instant.ofEpochMilli(expiryMs),
                    ZoneId.systemDefault()
                );
            } catch (Exception e) {
                log.warn("Failed to parse expiry time: {}", startTimeMillis, e);
            }
        }

        // Check auto-renewing
        boolean autoRenewing = purchase.getAutoRenewing() != null && purchase.getAutoRenewing();

        // Use obfuscatedExternalAccountId as original transaction ID
        String originalTransactionId = purchase.getObfuscatedExternalAccountId();
        if (originalTransactionId == null || originalTransactionId.isEmpty()) {
            originalTransactionId = purchase.getLatestOrderId();
        }

        return SubscriptionInfo.builder()
            .originalTransactionId(originalTransactionId)
            .transactionId(purchase.getLatestOrderId())
            .productId(productId)
            .purchaseDate(purchaseDate)
            .expiryDate(expiryDate != null ? expiryDate : LocalDateTime.now().plusDays(7)) // Default to 7 days if parsing fails
            .autoRenewing(autoRenewing)
            .valid(valid)
            .build();
    }
}
