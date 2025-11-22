package com.bookstore.vo;

import lombok.Data;

@Data
public class ChapterVO {
    private Long id;
    private Long bookId;
    private String title;
    private String content;
    private Integer orderNum;
}
