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

    private BigDecimal income;

    private Integer status; // 1: active, 0: disabled

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
