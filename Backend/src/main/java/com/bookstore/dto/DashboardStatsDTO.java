package com.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DashboardStatsDTO {
    private Long totalUsers;
    private Long activeUsers;
    private Long totalBooks;
    private Long totalOrders;
    private BigDecimal totalRevenue;
}
