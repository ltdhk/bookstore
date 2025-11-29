package com.bookstore.dto;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class ImportDataDTO {
    private List<BookImportDTO> books = new ArrayList<>();
    private List<ChapterImportDTO> chapters = new ArrayList<>();

    public void addBook(BookImportDTO book) {
        this.books.add(book);
    }

    public void addChapter(ChapterImportDTO chapter) {
        this.chapters.add(chapter);
    }
}
