package com.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DistributorRevenueRankingDTO {
    private Long distributorId;
    private String distributorName;
    private Long orderCount;
    private BigDecimal totalRevenue;
    private BigDecimal commissionRate;
    private BigDecimal distributorCommission;
}
