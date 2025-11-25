package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("book_categories")
public class BookCategory {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String name;
    
    private String language;
    
    private Integer sortOrder;
    
    private LocalDateTime createdAt;
}
