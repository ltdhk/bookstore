package com.bookstore.dto;

import lombok.Data;

@Data
public class TopBookDTO {
    private Long bookId;
    private String title;
    private String author;
    private Long views;
    private Long likes;
}
