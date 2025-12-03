package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Distributor commission entity
 * Tracks commission calculations for distributors
 */
@Data
@TableName("distributor_commissions")
public class DistributorCommission {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * Distributor ID
     */
    @TableField("distributor_id")
    private Long distributorId;

    /**
     * Order ID
     */
    @TableField("order_id")
    private Long orderId;

    /**
     * Order amount
     */
    @TableField("order_amount")
    private BigDecimal orderAmount;

    /**
     * Commission rate (e.g., 30.00 for 30%)
     */
    @TableField("commission_rate")
    private BigDecimal commissionRate;

    /**
     * Commission amount
     */
    @TableField("commission_amount")
    private BigDecimal commissionAmount;

    /**
     * Status: pending, settled, cancelled
     */
    @TableField("status")
    private String status;

    /**
     * Settled timestamp
     */
    @TableField("settled_at")
    private LocalDateTime settledAt;

    /**
     * Created timestamp
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
