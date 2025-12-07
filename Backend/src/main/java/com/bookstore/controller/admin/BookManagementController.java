package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Book;
import com.bookstore.entity.BookTag;
import com.bookstore.entity.Tag;
import com.bookstore.repository.BookTagRepository;
import com.bookstore.repository.TagRepository;
import com.bookstore.service.BookService;
import com.bookstore.service.CacheService;
import com.bookstore.service.impl.BookServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/books")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookManagementController {

    private final BookServiceImpl bookService;
    private final BookTagRepository bookTagRepository;
    private final TagRepository tagRepository;
    private final CacheService cacheService;

    @GetMapping
    public Result<IPage<Book>> getBooks(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String language,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Boolean isHot) {
        Page<Book> pageParam = new Page<>(page, size);
        IPage<Book> result = bookService.searchBooks(keyword, language, categoryId, isHot, pageParam);
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
        // 新增书籍后清除首页缓存
        cacheService.evictHomeBooksCache();
        return Result.success(book);
    }

    @PutMapping("/{id}")
    public Result<Book> updateBook(@PathVariable Long id, @RequestBody Book book) {
        book.setId(id);
        bookService.updateById(book);
        // 更新书籍后清除相关缓存
        cacheService.evictBookCache(id);
        return Result.success(book);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteBook(@PathVariable Long id) {
        bookService.removeById(id);
        // 删除书籍标签关联
        QueryWrapper<BookTag> deleteQuery = new QueryWrapper<>();
        deleteQuery.eq("book_id", id);
        bookTagRepository.delete(deleteQuery);
        // 删除书籍后清除相关缓存
        cacheService.evictBookCache(id);
        return Result.success("Deleted");
    }

    @GetMapping("/{id}/tags")
    public Result<List<Long>> getBookTags(@PathVariable Long id) {
        QueryWrapper<BookTag> query = new QueryWrapper<>();
        query.eq("book_id", id);
        List<BookTag> bookTags = bookTagRepository.selectList(query);
        List<Long> tagIds = bookTags.stream()
                .map(BookTag::getTagId)
                .collect(Collectors.toList());
        return Result.success(tagIds);
    }

    @PostMapping("/{id}/tags")
    public Result<String> updateBookTags(@PathVariable Long id, @RequestBody List<Long> tagIds) {
        // 删除旧的标签关联
        QueryWrapper<BookTag> deleteQuery = new QueryWrapper<>();
        deleteQuery.eq("book_id", id);
        bookTagRepository.delete(deleteQuery);

        // 添加新的标签关联
        if (tagIds != null && !tagIds.isEmpty()) {
            for (Long tagId : tagIds) {
                BookTag bookTag = new BookTag();
                bookTag.setBookId(id);
                bookTag.setTagId(tagId);
                bookTagRepository.insert(bookTag);
            }
        }
        return Result.success("标签更新成功");
    }

}
