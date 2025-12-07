package com.bookstore.controller.admin;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.style.column.LongestMatchColumnWidthStyleStrategy;
import com.bookstore.dto.BookImportDTO;
import com.bookstore.dto.ChapterImportDTO;
import com.bookstore.dto.ImportDataDTO;
import com.bookstore.dto.ImportResultDTO;
import com.bookstore.entity.BookCategory;
import com.bookstore.entity.Tag;
import com.bookstore.repository.BookCategoryRepository;
import com.bookstore.repository.TagRepository;
import com.bookstore.service.BookImportService;
import com.bookstore.service.CacheService;
import com.bookstore.common.Result;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/admin/books/import")
@RequiredArgsConstructor
public class BookImportController {

    private final BookImportService importService;
    private final BookCategoryRepository categoryRepository;
    private final TagRepository tagRepository;
    private final CacheService cacheService;

    @GetMapping("/template")
    public void downloadTemplate(HttpServletResponse response) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");

        String fileName = URLEncoder.encode("书籍导入模板", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        // Create sample data for template
        List<BookImportDTO> bookSamples = new ArrayList<>();
        BookImportDTO sample1 = new BookImportDTO();
        sample1.setTitle("示例书籍1");
        sample1.setAuthor("作者1");
        sample1.setCoverUrl("https://example.com/cover1.jpg");
        sample1.setDescription("这是一本示例书籍");
        sample1.setCategoryId(1L);
        sample1.setLanguage("zh");
        sample1.setStatus("published");
        sample1.setCompletionStatus("ongoing");
        sample1.setRequiresMembership("false");
        sample1.setIsRecommended("true");
        sample1.setIsHot("false");
        sample1.setTagIds("1,2,3");
        bookSamples.add(sample1);

        List<ChapterImportDTO> chapterSamples = new ArrayList<>();
        ChapterImportDTO chapter1 = new ChapterImportDTO();
        chapter1.setBookTitle("示例书籍1");
        chapter1.setChapterTitle("第一章");
        chapter1.setContent("<p>这是第一章的内容</p>");
        chapter1.setIsFree("true");
        chapter1.setOrderNum(1);
        chapterSamples.add(chapter1);

        // Get all categories for reference
        List<BookCategory> categories = categoryRepository.selectList(null);

        // Get all tags for reference
        List<Tag> tags = tagRepository.selectList(null);

        // Write Excel with multiple sheets
        EasyExcel.write(response.getOutputStream())
                .autoCloseStream(Boolean.FALSE)
                .registerWriteHandler(new LongestMatchColumnWidthStyleStrategy())
                .build()
                .write(bookSamples, EasyExcel.writerSheet(0, "书籍信息").head(BookImportDTO.class).build())
                .write(chapterSamples, EasyExcel.writerSheet(1, "章节信息").head(ChapterImportDTO.class).build())
                .write(categories, EasyExcel.writerSheet(2, "分类列表(参考)").head(BookCategory.class).build())
                .write(tags, EasyExcel.writerSheet(3, "标签列表(参考)").head(Tag.class).build())
                .finish();
    }

    @PostMapping("/preview")
    public Result<ImportDataDTO> previewImport(@RequestParam("file") MultipartFile file) {
        try {
            ImportDataDTO data = importService.previewImport(file);
            return Result.success(data);
        } catch (Exception e) {
            log.error("Preview import failed", e);
            return Result.error("预览失败: " + e.getMessage());
        }
    }

    @PostMapping("/execute")
    public Result<ImportResultDTO> executeImport(
            @RequestParam("file") MultipartFile file,
            @RequestParam(defaultValue = "false") Boolean skipDuplicates) {
        try {
            ImportResultDTO result = importService.executeImport(file, skipDuplicates);
            if (result.getSuccess()) {
                // 导入成功后清除所有书籍相关缓存
                cacheService.evictAllBookCaches();
                return Result.success(result);
            } else {
                // Return error with result data included
                Result<ImportResultDTO> errorResult = Result.error(result.getMessage());
                errorResult.setData(result);
                return errorResult;
            }
        } catch (Exception e) {
            log.error("Execute import failed", e);
            return Result.error("导入失败: " + e.getMessage());
        }
    }
}
