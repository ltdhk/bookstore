package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.Chapter;
import com.bookstore.repository.ChapterMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/books/{bookId}/chapters")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChapterController {

    private final ChapterMapper chapterMapper;

    @GetMapping
    public Result<List<Chapter>> getChapters(@PathVariable Long bookId) {
        QueryWrapper<Chapter> query = new QueryWrapper<>();
        query.eq("book_id", bookId);
        query.orderByAsc("order_num");
        return Result.success(chapterMapper.selectList(query));
    }

    @GetMapping("/{id}")
    public Result<Chapter> getChapter(@PathVariable Long bookId, @PathVariable Long id) {
        Chapter chapter = chapterMapper.selectById(id);
        if (chapter == null || !chapter.getBookId().equals(bookId)) {
            return Result.error("Chapter not found");
        }
        return Result.success(chapter);
    }

    @PostMapping
    public Result<Chapter> createChapter(@PathVariable Long bookId, @RequestBody Chapter chapter) {
        chapter.setBookId(bookId);

        // 如果没有指定排序,自动设置为最后
        if (chapter.getOrderNum() == null) {
            QueryWrapper<Chapter> query = new QueryWrapper<>();
            query.eq("book_id", bookId);
            query.orderByDesc("order_num");
            query.last("LIMIT 1");
            Chapter lastChapter = chapterMapper.selectOne(query);
            chapter.setOrderNum(lastChapter != null ? lastChapter.getOrderNum() + 1 : 1);
        }

        // 如果没有指定是否免费,默认为false
        if (chapter.getIsFree() == null) {
            chapter.setIsFree(false);
        }

        chapterMapper.insert(chapter);
        return Result.success(chapter);
    }

    @PutMapping("/{id}")
    public Result<Chapter> updateChapter(@PathVariable Long bookId, @PathVariable Long id, @RequestBody Chapter chapter) {
        Chapter existing = chapterMapper.selectById(id);
        if (existing == null || !existing.getBookId().equals(bookId)) {
            return Result.error("Chapter not found");
        }

        chapter.setId(id);
        chapter.setBookId(bookId);
        chapterMapper.updateById(chapter);
        return Result.success(chapter);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteChapter(@PathVariable Long bookId, @PathVariable Long id) {
        Chapter existing = chapterMapper.selectById(id);
        if (existing == null || !existing.getBookId().equals(bookId)) {
            return Result.error("Chapter not found");
        }

        chapterMapper.deleteById(id);
        return Result.success("Deleted");
    }
}
