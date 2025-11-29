package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.config.BookImportConfig;
import com.bookstore.dto.*;
import com.bookstore.entity.*;
import com.bookstore.repository.BookCategoryRepository;
import com.bookstore.repository.BookTagRepository;
import com.bookstore.repository.TagRepository;
import com.bookstore.service.BookImportService;
import com.bookstore.service.BookService;
import com.bookstore.service.ChapterService;
import com.bookstore.util.ExcelParser;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BookImportServiceImpl implements BookImportService {

    private final BookService bookService;
    private final ChapterService chapterService;
    private final BookTagRepository bookTagRepository;
    private final BookCategoryRepository categoryRepository;
    private final TagRepository tagRepository;
    private final BookImportConfig config;

    @Override
    public ImportDataDTO previewImport(MultipartFile file) throws Exception {
        // Stage 1: File validation
        List<ValidationError> errors = ExcelParser.validateFileFormat(file);
        if (!errors.isEmpty()) {
            throw new IllegalArgumentException("文件格式验证失败: " + errors.get(0).getMessage());
        }

        // Parse Excel
        ImportDataDTO data = ExcelParser.parseExcel(file);

        // Stage 2-4: Validate data
        errors = validateData(data);
        if (!errors.isEmpty()) {
            log.warn("Validation errors found: {}", errors.size());
        }

        return data;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ImportResultDTO executeImport(MultipartFile file, Boolean skipDuplicates) throws Exception {
        // Parse and validate
        ImportDataDTO data = previewImport(file);

        // Validate again
        List<ValidationError> errors = validateData(data);
        if (!errors.isEmpty()) {
            return ImportResultDTO.error(errors);
        }

        // Execute batch save
        return batchSave(data, skipDuplicates);
    }

    private List<ValidationError> validateData(ImportDataDTO data) {
        List<ValidationError> errors = new ArrayList<>();

        // Stage 2: Row-level validation
        errors.addAll(validateBooks(data.getBooks()));
        errors.addAll(validateChapters(data.getChapters()));

        // Stage 3: Association validation
        errors.addAll(validateAssociations(data));

        // Stage 4: Business rules
        errors.addAll(validateBusinessRules(data));

        return errors;
    }

    private List<ValidationError> validateBooks(List<BookImportDTO> books) {
        List<ValidationError> errors = new ArrayList<>();

        for (int i = 0; i < books.size(); i++) {
            BookImportDTO book = books.get(i);
            int rowNum = i + 2; // Excel row (skip header)

            // Required fields
            if (!StringUtils.hasText(book.getTitle())) {
                errors.add(new ValidationError("title", "书名不能为空", rowNum, "Sheet1"));
            }
            if (!StringUtils.hasText(book.getLanguage())) {
                errors.add(new ValidationError("language", "语言不能为空", rowNum, "Sheet1"));
            } else if (!book.getLanguage().equals("zh") && !book.getLanguage().equals("en")) {
                errors.add(new ValidationError("language", "语言必须为 zh 或 en", rowNum, "Sheet1"));
            }

            // Status validation
            if (StringUtils.hasText(book.getStatus())) {
                if (!Arrays.asList("published", "draft", "archived").contains(book.getStatus())) {
                    errors.add(new ValidationError("status", "状态必须为 published, draft 或 archived", rowNum, "Sheet1"));
                }
            }

            // Completion status validation
            if (StringUtils.hasText(book.getCompletionStatus())) {
                if (!Arrays.asList("completed", "ongoing").contains(book.getCompletionStatus())) {
                    errors.add(new ValidationError("completionStatus", "完结状态必须为 completed 或 ongoing", rowNum, "Sheet1"));
                }
            }
        }

        return errors;
    }

    private List<ValidationError> validateChapters(List<ChapterImportDTO> chapters) {
        List<ValidationError> errors = new ArrayList<>();

        for (int i = 0; i < chapters.size(); i++) {
            ChapterImportDTO chapter = chapters.get(i);
            int rowNum = i + 2;

            if (!StringUtils.hasText(chapter.getBookTitle())) {
                errors.add(new ValidationError("bookTitle", "书名不能为空", rowNum, "Sheet2"));
            }
            if (!StringUtils.hasText(chapter.getChapterTitle())) {
                errors.add(new ValidationError("chapterTitle", "章节标题不能为空", rowNum, "Sheet2"));
            }
            if (!StringUtils.hasText(chapter.getContent())) {
                errors.add(new ValidationError("content", "章节内容不能为空", rowNum, "Sheet2"));
            }
        }

        return errors;
    }

    private List<ValidationError> validateAssociations(ImportDataDTO data) {
        List<ValidationError> errors = new ArrayList<>();

        // Collect all book titles
        Set<String> bookTitles = data.getBooks().stream()
                .map(BookImportDTO::getTitle)
                .filter(StringUtils::hasText)
                .collect(Collectors.toSet());

        // Validate chapter book associations
        for (int i = 0; i < data.getChapters().size(); i++) {
            ChapterImportDTO chapter = data.getChapters().get(i);
            int rowNum = i + 2;

            if (StringUtils.hasText(chapter.getBookTitle()) && !bookTitles.contains(chapter.getBookTitle())) {
                errors.add(new ValidationError("bookTitle",
                        "书名 '" + chapter.getBookTitle() + "' 在Sheet1中不存在", rowNum, "Sheet2"));
            }
        }

        // Validate category IDs
        for (int i = 0; i < data.getBooks().size(); i++) {
            BookImportDTO book = data.getBooks().get(i);
            int rowNum = i + 2;

            if (book.getCategoryId() != null) {
                BookCategory category = categoryRepository.selectById(book.getCategoryId());
                if (category == null) {
                    errors.add(new ValidationError("categoryId",
                            "分类ID " + book.getCategoryId() + " 不存在", rowNum, "Sheet1"));
                } else if (!category.getLanguage().equals(book.getLanguage())) {
                    errors.add(new ValidationError("categoryId",
                            "分类语言与书籍语言不匹配", rowNum, "Sheet1"));
                }
            }
        }

        // Validate tag IDs
        for (int i = 0; i < data.getBooks().size(); i++) {
            BookImportDTO book = data.getBooks().get(i);
            int rowNum = i + 2;

            if (StringUtils.hasText(book.getTagIds())) {
                String[] tagIdStrings = book.getTagIds().split(",");
                for (String tagIdStr : tagIdStrings) {
                    try {
                        Long tagId = Long.parseLong(tagIdStr.trim());
                        Tag tag = tagRepository.selectById(tagId);
                        if (tag == null) {
                            errors.add(new ValidationError("tagIds",
                                    "标签ID " + tagId + " 不存在", rowNum, "Sheet1"));
                        } else if (!tag.getLanguage().equals(book.getLanguage())) {
                            errors.add(new ValidationError("tagIds",
                                    "标签语言与书籍语言不匹配", rowNum, "Sheet1"));
                        }
                    } catch (NumberFormatException e) {
                        errors.add(new ValidationError("tagIds",
                                "标签ID格式错误: " + tagIdStr, rowNum, "Sheet1"));
                    }
                }
            }
        }

        return errors;
    }

    private List<ValidationError> validateBusinessRules(ImportDataDTO data) {
        List<ValidationError> errors = new ArrayList<>();

        // Rule 1: Max books per batch
        if (data.getBooks().size() > config.getMaxBooksPerBatch()) {
            errors.add(new ValidationError("books",
                    "单次最多导入 " + config.getMaxBooksPerBatch() + " 本书"));
        }

        // Rule 2: No duplicate titles in batch
        Set<String> titles = new HashSet<>();
        for (int i = 0; i < data.getBooks().size(); i++) {
            String title = data.getBooks().get(i).getTitle();
            if (StringUtils.hasText(title)) {
                if (titles.contains(title)) {
                    errors.add(new ValidationError("title",
                            "书名重复: " + title, i + 2, "Sheet1"));
                }
                titles.add(title);
            }
        }

        // Rule 3: Max chapters per book
        Map<String, Long> chapterCounts = data.getChapters().stream()
                .filter(c -> StringUtils.hasText(c.getBookTitle()))
                .collect(Collectors.groupingBy(ChapterImportDTO::getBookTitle, Collectors.counting()));

        for (Map.Entry<String, Long> entry : chapterCounts.entrySet()) {
            if (entry.getValue() > config.getMaxChaptersPerBook()) {
                errors.add(new ValidationError("chapters",
                        "书籍 '" + entry.getKey() + "' 的章节数超过上限 " + config.getMaxChaptersPerBook()));
            }
        }

        return errors;
    }

    @Transactional(rollbackFor = Exception.class)
    private ImportResultDTO batchSave(ImportDataDTO data, Boolean skipDuplicates) {
        List<Book> booksToSave = new ArrayList<>();
        int skippedCount = 0;

        // Convert DTOs to entities
        for (BookImportDTO dto : data.getBooks()) {
            // Skip duplicates if requested
            if (skipDuplicates) {
                QueryWrapper<Book> queryWrapper = new QueryWrapper<>();
                queryWrapper.eq("title", dto.getTitle());
                if (bookService.count(queryWrapper) > 0) {
                    skippedCount++;
                    continue;
                }
            }

            Book book = convertToBook(dto);
            booksToSave.add(book);
        }

        // Batch save books
        if (!booksToSave.isEmpty()) {
            bookService.saveBatch(booksToSave, 1000);
        }

        // Build book title to ID mapping
        Map<String, Long> bookIdMap = booksToSave.stream()
                .collect(Collectors.toMap(Book::getTitle, Book::getId));

        // Batch save chapters
        List<Chapter> chaptersToSave = new ArrayList<>();
        Map<String, Integer> chapterOrderMap = new HashMap<>();

        for (ChapterImportDTO dto : data.getChapters()) {
            Long bookId = bookIdMap.get(dto.getBookTitle());
            if (bookId == null) {
                continue; // Skip if book was skipped
            }

            Chapter chapter = convertToChapter(dto, bookId);

            // Auto-generate orderNum if not provided
            if (chapter.getOrderNum() == null) {
                String key = dto.getBookTitle();
                int currentOrder = chapterOrderMap.getOrDefault(key, 0) + 1;
                chapter.setOrderNum(currentOrder);
                chapterOrderMap.put(key, currentOrder);
            }

            chaptersToSave.add(chapter);
        }

        if (!chaptersToSave.isEmpty()) {
            chapterService.saveBatch(chaptersToSave, 1000);
        }

        // Batch save book-tag associations
        List<BookTag> bookTags = new ArrayList<>();
        for (BookImportDTO dto : data.getBooks()) {
            Long bookId = bookIdMap.get(dto.getTitle());
            if (bookId == null || !StringUtils.hasText(dto.getTagIds())) {
                continue;
            }

            String[] tagIdStrings = dto.getTagIds().split(",");
            for (String tagIdStr : tagIdStrings) {
                try {
                    Long tagId = Long.parseLong(tagIdStr.trim());
                    BookTag bookTag = new BookTag();
                    bookTag.setBookId(bookId);
                    bookTag.setTagId(tagId);
                    bookTags.add(bookTag);
                } catch (NumberFormatException e) {
                    log.warn("Invalid tag ID: {}", tagIdStr);
                }
            }
        }

        if (!bookTags.isEmpty()) {
            for (BookTag bookTag : bookTags) {
                bookTagRepository.insert(bookTag);
            }
        }

        // Build result
        if (skippedCount > 0) {
            return ImportResultDTO.partialSuccess(
                    booksToSave.size(),
                    skippedCount,
                    chaptersToSave.size(),
                    new ArrayList<>()
            );
        } else {
            return ImportResultDTO.success(booksToSave.size(), chaptersToSave.size());
        }
    }

    private Book convertToBook(BookImportDTO dto) {
        Book book = new Book();
        book.setTitle(dto.getTitle());
        book.setAuthor(dto.getAuthor());
        book.setCoverUrl(StringUtils.hasText(dto.getCoverUrl()) ? dto.getCoverUrl() : null);
        book.setDescription(dto.getDescription());
        book.setCategoryId(dto.getCategoryId());
        book.setLanguage(dto.getLanguage());
        book.setStatus(StringUtils.hasText(dto.getStatus()) ? dto.getStatus() : "draft");
        book.setCompletionStatus(dto.getCompletionStatus());
        book.setRequiresMembership(parseBoolean(dto.getRequiresMembership(), false));
        book.setIsRecommended(parseBoolean(dto.getIsRecommended(), false));
        book.setIsHot(parseBoolean(dto.getIsHot(), false));
        book.setViews(0L);
        book.setLikes(0L);
        return book;
    }

    private Chapter convertToChapter(ChapterImportDTO dto, Long bookId) {
        Chapter chapter = new Chapter();
        chapter.setBookId(bookId);
        chapter.setTitle(dto.getChapterTitle());
        chapter.setContent(dto.getContent());
        chapter.setIsFree(parseBoolean(dto.getIsFree(), false));
        chapter.setOrderNum(dto.getOrderNum());
        return chapter;
    }

    private Boolean parseBoolean(String value, boolean defaultValue) {
        if (!StringUtils.hasText(value)) {
            return defaultValue;
        }
        value = value.trim().toLowerCase();
        return value.equals("true") || value.equals("1") || value.equals("yes");
    }
}
