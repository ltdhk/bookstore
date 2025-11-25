package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class SubscriptionStatusDTO {
    /**
     * Subscription status: none, active, expired, cancelled
     */
    private String subscriptionStatus;

    /**
     * Subscription end date
     */
    private LocalDateTime subscriptionEndDate;

    /**
     * Plan type: monthly, quarterly, yearly
     */
    private String subscriptionPlanType;

    /**
     * Is SVIP
     */
    private Boolean isSvip;

    /**
     * Current order info (if active)
     */
    private Long orderId;

    private String orderNo;

    private BigDecimal amount;

    private String platform;

    private LocalDateTime subscriptionStartDate;

    private Boolean isAutoRenew;
}
