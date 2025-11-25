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
    private Long categoryId;
    private String status;
    private String completionStatus;
    private Long views;
    private Long likes;
    private Double rating;

    // New fields
    private String language;
    private Boolean requiresMembership;
    private Boolean isRecommended;
    private Boolean isHot;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}
