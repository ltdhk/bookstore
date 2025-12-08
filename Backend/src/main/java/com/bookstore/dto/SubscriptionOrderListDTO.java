package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订阅订单列表 DTO（包含用户名和分销商名称）
 */
@Data
public class SubscriptionOrderListDTO {
    private Long id;
    private String orderNo;
    private Long userId;
    private String username;
    private String platform;
    private String subscriptionPeriod;
    private BigDecimal amount;
    private String status;
    private LocalDateTime subscriptionStartDate;
    private LocalDateTime subscriptionEndDate;
    private Boolean isAutoRenew;
    private String sourceEntry;
    private Long distributorId;
    private String distributorName;
    private LocalDateTime createTime;
}
