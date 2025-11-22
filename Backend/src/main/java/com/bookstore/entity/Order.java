package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("orders")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String orderNo;

    private BigDecimal amount;

    private String status; // Pending, Paid, Refunded

    private String platform; // AppStore, GooglePay

    private String productId;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
