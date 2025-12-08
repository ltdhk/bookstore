package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订阅订单详情 DTO（包含关联的分销商、通行证、书籍名称）
 */
@Data
public class SubscriptionOrderDetailDTO {
    // 订单基本信息
    private Long id;
    private Long userId;
    private String orderNo;
    private BigDecimal amount;
    private String status;
    private String platform;
    private String productId;
    private String orderType;
    private String subscriptionPeriod;
    private LocalDateTime subscriptionStartDate;
    private LocalDateTime subscriptionEndDate;
    private Boolean isAutoRenew;
    private LocalDateTime cancelDate;
    private String cancelReason;
    private String originalTransactionId;
    private String platformTransactionId;
    private String sourceEntry;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    // 关联 ID
    private Long distributorId;
    private Long sourcePasscodeId;
    private Long sourceBookId;

    // 关联名称（通过 JOIN 查询获取）
    private String distributorName;
    private String passcodeName;
    private String passcodeCode;
    private String bookTitle;

    // 用户信息
    private String username;

    // 产品信息
    private String productName;
}
