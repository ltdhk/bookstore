package com.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Unified subscription information DTO
 * Compatible with both Apple and Google receipt verification responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionInfo {
    /**
     * Original transaction ID (used to prevent duplicate purchases)
     */
    private String originalTransactionId;

    /**
     * Platform transaction ID
     */
    private String transactionId;

    /**
     * Product ID
     */
    private String productId;

    /**
     * Purchase date
     */
    private LocalDateTime purchaseDate;

    /**
     * Expiry date
     */
    private LocalDateTime expiryDate;

    /**
     * Is auto-renewing
     */
    private boolean autoRenewing;

    /**
     * Is valid (not expired, not cancelled)
     */
    private boolean valid;
}
