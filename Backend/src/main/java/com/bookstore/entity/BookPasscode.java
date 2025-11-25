package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("book_passcodes")
public class BookPasscode {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long bookId;

    private Long distributorId;

    private String passcode;

    private String name;

    private Integer maxUsage;

    private Integer usedCount;

    private Long viewCount;

    private Integer status; // 1: active, 0: disabled

    private LocalDateTime validFrom;

    private LocalDateTime validTo;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @TableLogic
    private Boolean deleted; // Soft delete flag
}
