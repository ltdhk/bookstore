package com.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PlatformDistributionDTO {
    private String platform;
    private Long orderCount;
    private BigDecimal revenue;
    private Double percentage;
}
