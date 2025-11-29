package com.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ImportResultDTO {
    private Boolean success;
    private String message;
    private Integer importedBooks;
    private Integer importedChapters;
    private Integer skippedBooks;
    private List<ValidationError> errors;
    private List<ValidationError> warnings;

    public static ImportResultDTO success(int bookCount, int chapterCount) {
        return ImportResultDTO.builder()
                .success(true)
                .message("导入成功")
                .importedBooks(bookCount)
                .importedChapters(chapterCount)
                .skippedBooks(0)
                .errors(new ArrayList<>())
                .warnings(new ArrayList<>())
                .build();
    }

    public static ImportResultDTO error(List<ValidationError> errors) {
        return ImportResultDTO.builder()
                .success(false)
                .message("导入失败：存在验证错误")
                .importedBooks(0)
                .importedChapters(0)
                .skippedBooks(0)
                .errors(errors)
                .warnings(new ArrayList<>())
                .build();
    }

    public static ImportResultDTO partialSuccess(int importedBooks, int skippedBooks,
                                                   int chapterCount, List<ValidationError> warnings) {
        return ImportResultDTO.builder()
                .success(true)
                .message("部分导入成功")
                .importedBooks(importedBooks)
                .importedChapters(chapterCount)
                .skippedBooks(skippedBooks)
                .errors(new ArrayList<>())
                .warnings(warnings)
                .build();
    }
}
