package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("chapters")
public class Chapter {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long bookId;
    private String title;
    private String content;
    private Boolean isFree;
    private Integer orderNum;


    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;



}
