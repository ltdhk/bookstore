package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.service.BookService;
import com.bookstore.service.ChapterService;
import com.bookstore.vo.BookVO;
import com.bookstore.vo.ChapterVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/books")
public class BookController {

    @Autowired
    private BookService bookService;

    @Autowired
    private ChapterService chapterService;

    @GetMapping("/home")
    public Result<Map<String, List<BookVO>>> getHomeBooks() {
        return Result.success(bookService.getHomeBooks());
    }

    @GetMapping("/{id}")
    public Result<BookVO> getBookDetails(@PathVariable Long id) {
        return Result.success(bookService.getBookDetails(id));
    }

    @GetMapping("/{id}/chapters")
    public Result<List<ChapterVO>> getBookChapters(@PathVariable Long id) {
        return Result.success(chapterService.getChaptersByBookId(id));
    }

    @GetMapping("/chapters/{id}")
    public Result<ChapterVO> getChapterDetails(@PathVariable Long id) {
        return Result.success(chapterService.getChapterDetails(id));
    }

    @GetMapping("/search")
    public Result<List<BookVO>> searchBooks(@RequestParam String keyword) {
        return Result.success(bookService.searchBooks(keyword));
    }
}
