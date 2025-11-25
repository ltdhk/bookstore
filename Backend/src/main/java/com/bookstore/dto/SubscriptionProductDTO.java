package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SubscriptionProductDTO {
    private Long id;
    private String productId;
    private String productName;
    private String planType;
    private Integer durationDays;
    private BigDecimal price;
    private String currency;
    private String platform;
    private String appleProductId;
    private String googleProductId;
    private Boolean isActive;
    private Integer sortOrder;
    private String description;
    private String features;
}
