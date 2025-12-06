package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Tracks processed platform transaction IDs to prevent duplicate processing
 * without creating duplicate order records that would affect revenue statistics.
 */
@Data
@TableName("processed_transactions")
public class ProcessedTransaction {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * Unique transaction ID from the platform (Apple/Google)
     * For Apple: transactionId from JWSTransaction
     * For Google: orderId from Purchase
     */
    private String platformTransactionId;

    /**
     * Original transaction ID that identifies the subscription lifecycle
     * For Apple: originalTransactionId from JWSTransaction
     * For Google: same as platformTransactionId for subscriptions
     */
    private String originalTransactionId;

    /**
     * Reference to the actual order that was created for this transaction
     * May be NULL if this is a duplicate transaction attempt
     */
    private Long orderId;

    /**
     * Platform identifier: "apple" or "google"
     */
    private String platform;

    /**
     * Product ID that was purchased
     */
    private String productId;

    /**
     * Timestamp when this transaction was processed
     */
    private LocalDateTime processedAt;
}
