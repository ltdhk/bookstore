package com.bookstore.vo;

import lombok.Data;

@Data
public class BookVO {
    private Long id;
    private String title;
    private String author;
    private String coverUrl;
    private String description;
    private String category;
    private String status;
    private Long views;
    private Long likes;
    private Double rating;
    private String completionStatus; // 完本状态: ongoing, completed
    private Integer chapterCount; // 章节数
}
