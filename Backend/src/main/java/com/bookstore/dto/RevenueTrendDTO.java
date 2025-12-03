package com.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RevenueTrendDTO {
    private String date;
    private BigDecimal revenue;
    private Long orderCount;
}
