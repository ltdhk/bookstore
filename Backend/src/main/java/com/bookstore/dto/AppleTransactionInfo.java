package com.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * Decoded Apple Transaction Info (from signedTransactionInfo JWT)
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AppleTransactionInfo {

    /**
     * Unique transaction identifier
     */
    @JsonProperty("transactionId")
    private String transactionId;

    /**
     * Original transaction identifier (stays the same for renewals)
     */
    @JsonProperty("originalTransactionId")
    private String originalTransactionId;

    /**
     * Product identifier
     */
    @JsonProperty("productId")
    private String productId;

    /**
     * Subscription group identifier (optional)
     */
    @JsonProperty("subscriptionGroupIdentifier")
    private String subscriptionGroupIdentifier;

    /**
     * Purchase date in milliseconds since epoch
     */
    @JsonProperty("purchaseDate")
    private Long purchaseDate;

    /**
     * Original purchase date in milliseconds since epoch
     */
    @JsonProperty("originalPurchaseDate")
    private Long originalPurchaseDate;

    /**
     * Expiration date in milliseconds since epoch (for subscriptions)
     */
    @JsonProperty("expiresDate")
    private Long expiresDate;

    /**
     * Quantity purchased
     */
    @JsonProperty("quantity")
    private Integer quantity;

    /**
     * Transaction type: "Auto-Renewable Subscription" or "Non-Renewing Subscription"
     */
    @JsonProperty("type")
    private String type;

    /**
     * App account token (optional, set by app)
     */
    @JsonProperty("appAccountToken")
    private String appAccountToken;

    /**
     * In-app ownership type: PURCHASED, FAMILY_SHARED
     */
    @JsonProperty("inAppOwnershipType")
    private String inAppOwnershipType;

    /**
     * Signed date in milliseconds since epoch
     */
    @JsonProperty("signedDate")
    private Long signedDate;

    /**
     * Environment: Sandbox or Production
     */
    @JsonProperty("environment")
    private String environment;

    /**
     * Storefront (country code)
     */
    @JsonProperty("storefront")
    private String storefront;

    /**
     * Storefront ID
     */
    @JsonProperty("storefrontId")
    private String storefrontId;

    /**
     * Transaction reason: PURCHASE or RENEWAL
     */
    @JsonProperty("transactionReason")
    private String transactionReason;

    /**
     * Price in milliunits (e.g., 4990 for $4.99)
     */
    @JsonProperty("price")
    private Long price;

    /**
     * Currency code (e.g., USD)
     */
    @JsonProperty("currency")
    private String currency;
}
