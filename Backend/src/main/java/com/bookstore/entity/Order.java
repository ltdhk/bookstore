package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("orders")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long distributorId; // Distributor ID (from passcode)

    private Long sourcePasscodeId; // Source Passcode ID

    private String orderNo;

    private BigDecimal amount;

    private String status; // Pending, Paid, Refunded

    private String platform; // AppStore, GooglePay

    private String productId;

    // Subscription fields
    private String orderType; // onetime, subscription

    private String subscriptionPeriod; // monthly, quarterly, yearly

    private LocalDateTime subscriptionStartDate;

    private LocalDateTime subscriptionEndDate;

    private Boolean isAutoRenew;

    private LocalDateTime cancelDate;

    private String cancelReason;

    // Platform transaction fields
    private String originalTransactionId; // Apple/Google original transaction ID

    private String platformTransactionId;

    private String purchaseToken; // Google purchase token

    private String receiptData; // Apple receipt data

    private LocalDateTime verifiedAt; // When receipt was verified

    // Source tracking fields
    private Long sourceBookId; // From which book

    private String sourceEntry; // profile, reader

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
