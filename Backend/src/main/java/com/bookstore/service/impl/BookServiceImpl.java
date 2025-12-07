package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.config.CacheConfig;
import com.bookstore.dto.ReaderDataDTO;
import com.bookstore.entity.Book;
import com.bookstore.entity.Chapter;
import com.bookstore.repository.BookMapper;
import com.bookstore.repository.ChapterMapper;
import com.bookstore.service.BookService;
import com.bookstore.service.SubscriptionService;
import com.bookstore.vo.BookVO;
import com.bookstore.vo.ChapterVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class BookServiceImpl extends ServiceImpl<BookMapper, Book> implements BookService {

    @Autowired
    private ChapterMapper chapterMapper;

    @Autowired
    private SubscriptionService subscriptionService;

    @Override
    @Cacheable(value = CacheConfig.CACHE_HOME_BOOKS, key = "'home_' + #page + '_' + #pageSize + '_' + (#language ?: 'all')")
    public Map<String, List<BookVO>> getHomeBooks(Integer page, Integer pageSize, String language) {
        Map<String, List<BookVO>> result = new HashMap<>();

        // 计算偏移量
        int offset = (page - 1) * pageSize;

        // Hot: 勾选了热门的、状态是已发布的书籍，按照时间倒序
        LambdaQueryWrapper<Book> hotQuery = new LambdaQueryWrapper<Book>()
                .eq(Book::getIsHot, true)
                .eq(Book::getStatus, "published");
        if (language != null && !language.isEmpty()) {
            hotQuery.eq(Book::getLanguage, language);
        }
        List<Book> hotBooks = list(hotQuery
                .orderByDesc(Book::getCreatedAt)
                .last("LIMIT " + pageSize + " OFFSET " + offset));

        // New: 所有已发布的书籍，按照时间倒序
        LambdaQueryWrapper<Book> newQuery = new LambdaQueryWrapper<Book>()
                .eq(Book::getStatus, "published");
        if (language != null && !language.isEmpty()) {
            newQuery.eq(Book::getLanguage, language);
        }
        List<Book> newBooks = list(newQuery
                .orderByDesc(Book::getCreatedAt)
                .last("LIMIT " + pageSize + " OFFSET " + offset));

        // Male: 男生分类的书籍
        List<Book> maleBooks = getBooksForCategory("Male", language, pageSize, offset);

        // Female: 女生分类的书籍
        List<Book> femaleBooks = getBooksForCategory("Female", language, pageSize, offset);

        result.put("hot", convertToVOList(hotBooks));
        result.put("new", convertToVOList(newBooks));
        result.put("male", convertToVOList(maleBooks));
        result.put("female", convertToVOList(femaleBooks));

        return result;
    }


    @Override
    @Cacheable(value = CacheConfig.CACHE_BOOK_DETAILS, key = "#id")
    public BookVO getBookDetails(Long id) {
        Book book = getById(id);
        if (book == null) {
            throw new RuntimeException("Book not found");
        }

        // Increment views count (不影响缓存返回值)
        incrementViews(id);

        return convertToVO(book);
    }

    @Override
    public void likeBook(Long id) {
        // Use atomic SQL update to avoid race condition
        baseMapper.incrementLikes(id);
    }

    @Override
    public void incrementViews(Long id) {
        // Use atomic SQL update to avoid race condition
        baseMapper.incrementViews(id);
    }

    @Override
    @Cacheable(value = CacheConfig.CACHE_HOME_BOOKS, key = "'search_' + #keyword", condition = "#keyword != null && #keyword.length() >= 2")
    public List<BookVO> searchBooks(String keyword) {
        // Add limit to prevent returning too many results
        List<Book> books = list(new LambdaQueryWrapper<Book>()
                .like(Book::getTitle, keyword)
                .or()
                .like(Book::getAuthor, keyword)
                .last("LIMIT 50"));
        return convertToVOList(books);
    }

    @Override
    public IPage<Book> searchBooks(String keyword, Page<Book> pageParam) {
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            queryWrapper.like(Book::getTitle, keyword)
                    .or()
                    .like(Book::getAuthor, keyword);
        }
        return page(pageParam, queryWrapper);
    }

    public IPage<Book> searchBooks(String keyword, String language, Long categoryId, Boolean isHot, Page<Book> pageParam) {
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();

        // 按书名或作者搜索
        if (keyword != null && !keyword.isEmpty()) {
            queryWrapper.and(wrapper -> wrapper
                    .like(Book::getTitle, keyword)
                    .or()
                    .like(Book::getAuthor, keyword));
        }

        // 按语言筛选
        if (language != null && !language.isEmpty()) {
            queryWrapper.eq(Book::getLanguage, language);
        }

        // 按分类筛选
        if (categoryId != null) {
            queryWrapper.eq(Book::getCategoryId, categoryId);
        }

        // 按热门筛选
        if (isHot != null) {
            queryWrapper.eq(Book::getIsHot, isHot);
        }

        // 按创建时间倒序排列
        queryWrapper.orderByDesc(Book::getCreatedAt);

        return page(pageParam, queryWrapper);
    }

    /**
     * Get books by category name using JOIN query (single database query)
     */
    private List<Book> getBooksForCategory(String categoryName, String language, int pageSize, int offset) {
        return baseMapper.selectBooksByCategory(categoryName, language, pageSize, offset);
    }

    private List<BookVO> convertToVOList(List<Book> books) {
        return books.stream().map(this::convertToVOWithoutChapters).collect(Collectors.toList());
    }

    /**
     * Convert to VO without loading chapter information (for list views)
     */
    private BookVO convertToVOWithoutChapters(Book book) {
        BookVO vo = new BookVO();
        BeanUtils.copyProperties(book, vo);
        return vo;
    }

    /**
     * Convert to VO with chapter information (for detail views)
     */
    private BookVO convertToVO(Book book) {
        BookVO vo = new BookVO();
        BeanUtils.copyProperties(book, vo);

        // Calculate chapter count only for detail view
        Long chapterCount = chapterMapper.selectCount(
                new LambdaQueryWrapper<Chapter>()
                        .eq(Chapter::getBookId, book.getId())
        );
        vo.setChapterCount(chapterCount.intValue());

        return vo;
    }

    /**
     * Optimized method to get all reader data in a single call
     * Reduces database queries from 5+ to just 3:
     * 1. Book + chapter count (single query with subquery)
     * 2. All chapters for this book
     * 3. User subscription check (only if userId provided)
     *
     * Plus one UPDATE for incrementing views
     */
    @Override
    public ReaderDataDTO getReaderData(Long bookId, Long userId) {
        ReaderDataDTO result = new ReaderDataDTO();

        // Query 1: Get book with chapter count in single query
        Map<String, Object> bookData = baseMapper.selectBookWithChapterCount(bookId);
        if (bookData == null) {
            throw new RuntimeException("Book not found");
        }

        // Convert map to BookVO
        BookVO bookVO = new BookVO();
        bookVO.setId(((Number) bookData.get("id")).longValue());
        bookVO.setTitle((String) bookData.get("title"));
        bookVO.setAuthor((String) bookData.get("author"));
        bookVO.setCoverUrl((String) bookData.get("cover_url"));
        bookVO.setDescription((String) bookData.get("description"));
        bookVO.setCategory((String) bookData.get("category"));
        bookVO.setStatus((String) bookData.get("status"));
        bookVO.setCompletionStatus((String) bookData.get("completion_status"));
        if (bookData.get("views") != null) {
            bookVO.setViews(((Number) bookData.get("views")).longValue());
        }
        if (bookData.get("likes") != null) {
            bookVO.setLikes(((Number) bookData.get("likes")).longValue());
        }
        if (bookData.get("rating") != null) {
            bookVO.setRating(((Number) bookData.get("rating")).doubleValue());
        }
        if (bookData.get("chapter_count") != null) {
            bookVO.setChapterCount(((Number) bookData.get("chapter_count")).intValue());
        }
        result.setBook(bookVO);

        // Update: Increment views (atomic operation, doesn't fetch data)
        baseMapper.incrementViews(bookId);

        // Query 2: Check subscription status (only once for all chapters)
        boolean hasValidSubscription = userId != null && subscriptionService.isSubscriptionValid(userId);
        result.setHasValidSubscription(hasValidSubscription);

        // Query 3: Get all chapters for this book
        List<Chapter> chapters = chapterMapper.selectList(
                new LambdaQueryWrapper<Chapter>()
                        .eq(Chapter::getBookId, bookId)
                        .orderByAsc(Chapter::getOrderNum)
        );

        // Convert chapters to VOs with access control
        List<ChapterVO> chapterVOs = new ArrayList<>();
        boolean isFirst = true;
        for (Chapter chapter : chapters) {
            ChapterVO vo = new ChapterVO();
            vo.setId(chapter.getId());
            vo.setBookId(chapter.getBookId());
            vo.setTitle(chapter.getTitle());
            vo.setOrderNum(chapter.getOrderNum());
            vo.setIsFree(chapter.getIsFree());

            // Set access based on free status or subscription
            boolean canAccess = Boolean.TRUE.equals(chapter.getIsFree()) || hasValidSubscription;
            vo.setCanAccess(canAccess);

            // Include content only for the first chapter to reduce payload
            if (isFirst && canAccess) {
                vo.setContent(chapter.getContent());
                isFirst = false;
            }

            chapterVOs.add(vo);
        }
        result.setChapters(chapterVOs);

        return result;
    }
}
