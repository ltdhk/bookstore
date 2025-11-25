package com.bookstore.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class PasscodeStatsDTO {
    private Long passcodeId;
    private String passcode;
    private String name;
    private Integer usedCount;
    private Long viewCount;
    private Long orderCount; // Number of orders from this passcode
    private BigDecimal totalAmount; // Total amount from orders
    private Long uniqueUsers; // Number of unique users who used this passcode
}
