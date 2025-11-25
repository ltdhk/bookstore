package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.BookCategory;
import com.bookstore.repository.BookCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/categories")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookCategoryController {

    private final BookCategoryRepository categoryRepository;

    @GetMapping
    public Result<List<BookCategory>> getAllCategories(@RequestParam(required = false) String language) {
        QueryWrapper<BookCategory> query = new QueryWrapper<>();
        if (language != null && !language.isEmpty()) {
            query.eq("language", language);
        }
        query.orderByAsc("sort_order");
        return Result.success(categoryRepository.selectList(query));
    }

    @PostMapping
    public Result<BookCategory> createCategory(@RequestBody BookCategory category) {
        categoryRepository.insert(category);
        return Result.success(category);
    }

    @PutMapping("/{id}")
    public Result<BookCategory> updateCategory(@PathVariable Long id, @RequestBody BookCategory category) {
        category.setId(id);
        categoryRepository.updateById(category);
        return Result.success(category);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteCategory(@PathVariable Long id) {
        categoryRepository.deleteById(id);
        return Result.success("Deleted");
    }
}
