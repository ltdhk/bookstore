package com.bookstore.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PasscodeRankingDTO {
    private Long passcodeId;
    private String passcode;
    private String distributorName;
    private String bookTitle;
    private Long orderCount;
    private BigDecimal totalRevenue;
}
