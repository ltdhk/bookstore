package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Book;
import com.bookstore.service.BookService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/books")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookManagementController {

    private final BookService bookService;

    @GetMapping
    public Result<IPage<Book>> getBooks(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        Page<Book> pageParam = new Page<>(page, size);
        IPage<Book> result = bookService.searchBooks(keyword, pageParam);
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<Book> getBook(@PathVariable Long id) {
        Book book = bookService.getById(id);
        return Result.success(book);
    }

    @PostMapping
    public Result<Book> createBook(@RequestBody Book book) {
        bookService.save(book);
        return Result.success(book);
    }

    @PutMapping("/{id}")
    public Result<Book> updateBook(@PathVariable Long id, @RequestBody Book book) {
        book.setId(id);
        bookService.updateById(book);
        return Result.success(book);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteBook(@PathVariable Long id) {
        bookService.removeById(id);
        return Result.success("Deleted");
    }
}
