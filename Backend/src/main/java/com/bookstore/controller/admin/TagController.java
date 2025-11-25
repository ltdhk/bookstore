package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.Tag;
import com.bookstore.repository.TagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/tags")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TagController {

    private final TagRepository tagRepository;

    @GetMapping
    public Result<List<Tag>> getAllTags(@RequestParam(required = false) String language) {
        QueryWrapper<Tag> query = new QueryWrapper<>();
        if (language != null && !language.isEmpty()) {
            query.eq("language", language);
        }
        query.orderByAsc("sort_order");
        return Result.success(tagRepository.selectList(query));
    }

    @GetMapping("/active")
    public Result<List<Tag>> getActiveTags(@RequestParam(required = false) String language) {
        QueryWrapper<Tag> query = new QueryWrapper<>();
        query.eq("is_active", true);
        if (language != null && !language.isEmpty()) {
            query.eq("language", language);
        }
        query.orderByAsc("sort_order");
        return Result.success(tagRepository.selectList(query));
    }

    @PostMapping
    public Result<Tag> createTag(@RequestBody Tag tag) {
        tagRepository.insert(tag);
        return Result.success(tag);
    }

    @PutMapping("/{id}")
    public Result<Tag> updateTag(@PathVariable Long id, @RequestBody Tag tag) {
        tag.setId(id);
        tagRepository.updateById(tag);
        return Result.success(tag);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteTag(@PathVariable Long id) {
        tagRepository.deleteById(id);
        return Result.success("删除成功");
    }
}
