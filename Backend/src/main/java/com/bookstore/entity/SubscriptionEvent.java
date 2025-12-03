package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Subscription event entity
 * Tracks all subscription-related events (purchase, renewal, cancellation, refund, etc.)
 */
@Data
@TableName("subscription_events")
public class SubscriptionEvent {
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * User ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * Order ID
     */
    @TableField("order_id")
    private Long orderId;

    /**
     * Event type: purchased, renewed, cancelled, expired, refunded
     */
    @TableField("event_type")
    private String eventType;

    /**
     * Platform: AppStore or GooglePay
     */
    @TableField("platform")
    private String platform;

    /**
     * Original transaction ID
     */
    @TableField("original_transaction_id")
    private String originalTransactionId;

    /**
     * Event date
     */
    @TableField("event_date")
    private LocalDateTime eventDate;

    /**
     * Original notification data (JSON)
     */
    @TableField("notification_data")
    private String notificationData;

    /**
     * Is processed
     */
    @TableField("processed")
    private Boolean processed;

    /**
     * Created timestamp
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
