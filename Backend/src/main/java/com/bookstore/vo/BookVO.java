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
    private Double rating;
}
