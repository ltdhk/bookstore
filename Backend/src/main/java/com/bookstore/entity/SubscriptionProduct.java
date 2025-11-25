package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("subscription_products")
public class SubscriptionProduct {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * Product ID (Unique)
     */
    private String productId;

    /**
     * Product Name
     */
    private String productName;

    /**
     * Plan Type: monthly, quarterly, yearly
     */
    private String planType;

    /**
     * Duration in Days
     */
    private Integer durationDays;

    /**
     * Price
     */
    private BigDecimal price;

    /**
     * Currency
     */
    private String currency;

    /**
     * Platform: AppStore, GooglePay
     */
    private String platform;

    /**
     * Apple Product ID
     */
    private String appleProductId;

    /**
     * Google Product ID
     */
    private String googleProductId;

    /**
     * Is Active
     */
    private Boolean isActive;

    /**
     * Sort Order
     */
    private Integer sortOrder;

    /**
     * Description
     */
    private String description;

    /**
     * Features (JSON)
     */
    private String features;

    /**
     * Created At
     */
    private LocalDateTime createdAt;

    /**
     * Updated At
     */
    private LocalDateTime updatedAt;
}
