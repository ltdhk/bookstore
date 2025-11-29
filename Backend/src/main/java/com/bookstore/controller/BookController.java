package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.dto.ReaderDataDTO;
import com.bookstore.service.BookService;
import com.bookstore.service.ChapterService;
import com.bookstore.vo.BookVO;
import com.bookstore.vo.ChapterVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
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
    public Result<Map<String, List<BookVO>>> getHomeBooks(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer pageSize,
            @RequestParam(required = false) String language) {
        return Result.success(bookService.getHomeBooks(page, pageSize, language));
    }

    @GetMapping("/{id}")
    public Result<BookVO> getBookDetails(@PathVariable Long id) {
        return Result.success(bookService.getBookDetails(id));
    }

    @GetMapping("/{id}/chapters")
    public Result<List<ChapterVO>> getBookChapters(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "false") Boolean includeFirstChapter,
            HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(chapterService.getChaptersByBookId(id, includeFirstChapter, userId));
    }

    @GetMapping("/chapters/{id}")
    public Result<ChapterVO> getChapterDetails(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(chapterService.getChapterDetails(id, userId));
    }

    @GetMapping("/search")
    public Result<List<BookVO>> searchBooks(@RequestParam String keyword) {
        return Result.success(bookService.searchBooks(keyword));
    }

    @PostMapping("/{id}/like")
    public Result<Void> likeBook(@PathVariable Long id) {
        bookService.likeBook(id);
        return Result.success(null);
    }

    /**
     * Optimized endpoint for reader page - returns all data in a single call
     * Combines: book details + chapter list + first chapter content + subscription status
     * Reduces API calls from 2-3 to 1, and DB queries from 5+ to 3
     */
    @GetMapping("/{id}/reader-data")
    public Result<ReaderDataDTO> getReaderData(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(bookService.getReaderData(id, userId));
    }
}
