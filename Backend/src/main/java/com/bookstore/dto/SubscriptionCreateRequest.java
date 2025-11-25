package com.bookstore.dto;

import lombok.Data;

@Data
public class SubscriptionCreateRequest {
    /**
     * Product ID
     */
    private String productId;

    /**
     * Platform: AppStore, GooglePay
     */
    private String platform;

    /**
     * Source tracking fields
     */
    private Long distributorId; // From passcode

    private Long sourcePasscodeId;

    private Long sourceBookId; // From which book

    private String sourceEntry; // profile, reader

    /**
     * Platform transaction data (for mock payment)
     */
    private String receiptData; // Apple receipt (will be mocked)

    private String purchaseToken; // Google purchase token (will be mocked)
}
