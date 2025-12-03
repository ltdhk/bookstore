package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Commission Summary DTO
 * Used for calculating commission dynamically from order data
 */
@Data
public class CommissionSummaryDTO {
    /**
     * Distributor ID
     */
    private Long distributorId;

    /**
     * Order ID
     */
    private Long orderId;

    /**
     * Order number
     */
    private String orderNo;

    /**
     * Order amount
     */
    private BigDecimal orderAmount;

    /**
     * Commission rate (%)
     */
    private BigDecimal commissionRate;

    /**
     * Commission amount (calculated: orderAmount * commissionRate / 100)
     */
    private BigDecimal commissionAmount;

    /**
     * Order status
     */
    private String orderStatus;

    /**
     * Platform
     */
    private String platform;

    /**
     * Source passcode ID
     */
    private Long sourcePasscodeId;

    /**
     * Source book ID
     */
    private Long sourceBookId;

    /**
     * Source entry
     */
    private String sourceEntry;

    /**
     * Order create time
     */
    private LocalDateTime createTime;

    /**
     * User ID
     */
    private Long userId;

    /**
     * Product ID
     */
    private String productId;

    /**
     * Subscription period
     */
    private String subscriptionPeriod;
}
