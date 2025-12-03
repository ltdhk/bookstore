package com.bookstore.dto;

import lombok.Data;

/**
 * Subscription verify request DTO
 * Used when client sends purchase receipt for backend verification
 */
@Data
public class SubscriptionVerifyRequest {
    /**
     * Platform: AppStore or GooglePay
     */
    private String platform;

    /**
     * Product ID from client
     */
    private String productId;

    /**
     * Apple receipt data (Base64 encoded)
     * Only required for AppStore purchases
     */
    private String receiptData;

    /**
     * Google purchase token
     * Only required for GooglePay purchases
     */
    private String purchaseToken;

    /**
     * Distributor ID (optional, for commission tracking)
     */
    private Long distributorId;

    /**
     * Source passcode ID (optional, for tracking)
     */
    private Long sourcePasscodeId;

    /**
     * Source book ID (optional, for tracking)
     */
    private Long sourceBookId;

    /**
     * Source entry point (optional, e.g., "profile", "reader")
     */
    private String sourceEntry;
}
