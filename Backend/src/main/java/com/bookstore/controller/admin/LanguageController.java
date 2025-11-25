package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.Language;
import com.bookstore.repository.LanguageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/languages")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class LanguageController {

    private final LanguageRepository languageRepository;

    @GetMapping
    public Result<List<Language>> getAllLanguages() {
        QueryWrapper<Language> query = new QueryWrapper<>();
        query.orderByAsc("sort_order");
        return Result.success(languageRepository.selectList(query));
    }

    @GetMapping("/active")
    public Result<List<Language>> getActiveLanguages() {
        QueryWrapper<Language> query = new QueryWrapper<>();
        query.eq("is_active", true);
        query.orderByAsc("sort_order");
        return Result.success(languageRepository.selectList(query));
    }

    @PostMapping
    public Result<Language> createLanguage(@RequestBody Language language) {
        if (language.getIsActive() == null) {
            language.setIsActive(true);
        }
        languageRepository.insert(language);
        return Result.success(language);
    }

    @PutMapping("/{id}")
    public Result<Language> updateLanguage(@PathVariable Long id, @RequestBody Language language) {
        language.setId(id);
        languageRepository.updateById(language);
        return Result.success(language);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteLanguage(@PathVariable Long id) {
        languageRepository.deleteById(id);
        return Result.success("Deleted");
    }
}
