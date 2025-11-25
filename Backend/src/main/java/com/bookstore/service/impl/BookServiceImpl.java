package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Book;
import com.bookstore.entity.Chapter;
import com.bookstore.repository.BookMapper;
import com.bookstore.repository.ChapterMapper;
import com.bookstore.service.BookService;
import com.bookstore.vo.BookVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class BookServiceImpl extends ServiceImpl<BookMapper, Book> implements BookService {

    @Autowired
    private ChapterMapper chapterMapper;

    @Override
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
    public BookVO getBookDetails(Long id) {
        Book book = getById(id);
        if (book == null) {
            throw new RuntimeException("Book not found");
        }

        // Increment views count
        incrementViews(id);

        return convertToVO(book);
    }

    @Override
    public void likeBook(Long id) {
        Book book = getById(id);
        if (book == null) {
            throw new RuntimeException("Book not found");
        }
        // Increment likes count
        book.setLikes((book.getLikes() == null ? 0 : book.getLikes()) + 1);
        updateById(book);
    }

    @Override
    public void incrementViews(Long id) {
        Book book = getById(id);
        if (book == null) {
            throw new RuntimeException("Book not found");
        }
        // Increment views count
        book.setViews((book.getViews() == null ? 0 : book.getViews()) + 1);
        updateById(book);
    }

    @Override
    public List<BookVO> searchBooks(String keyword) {
        List<Book> books = list(new LambdaQueryWrapper<Book>()
                .like(Book::getTitle, keyword)
                .or()
                .like(Book::getAuthor, keyword));
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
}
