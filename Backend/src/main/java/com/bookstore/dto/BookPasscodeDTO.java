package com.bookstore.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BookPasscodeDTO {
    private Long id;
    private Long bookId;
    private String bookTitle;
    private Long distributorId;
    private String distributorName;
    private String passcode;
    private String name;
    private Integer maxUsage;
    private Integer usedCount;
    private Long viewCount;
    private Integer status;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Statistics fields
    private Long orderCount;
    private java.math.BigDecimal totalAmount;
}
