package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("advertisements")
public class Advertisement {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String title;

    private String imageUrl;

    private String targetType; // book, url, none

    private Long targetId; // Book ID if targetType is 'book'

    private String targetUrl; // URL if targetType is 'url'

    private String position; // home_banner, home_popup, etc.

    private Integer sortOrder;

    private Boolean isActive;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}
