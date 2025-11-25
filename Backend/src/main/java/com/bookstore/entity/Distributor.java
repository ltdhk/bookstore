package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("distributors")
public class Distributor {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String contact;

    private String code;

    private String username;

    private String password;

    private BigDecimal income;

    private Integer status; // 1: active, 0: disabled

    // Commission rate fields
    private BigDecimal commissionRate; // 订阅分成比例 (0-100，例如：30表示30%)

    private BigDecimal coinsCommissionRate; // 充币分成比例 (0-100)

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
