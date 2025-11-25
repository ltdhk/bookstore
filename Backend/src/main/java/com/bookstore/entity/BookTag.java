package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("book_tags")
public class BookTag {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long bookId;
    private Long tagId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
