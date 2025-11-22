package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("books")
public class Book {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String title;
    private String author;
    private String coverUrl;
    private String description;
    private String category;
    private String status;
    private Long views;
    private Double rating;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}
