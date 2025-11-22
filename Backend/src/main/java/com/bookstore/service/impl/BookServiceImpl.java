package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Book;
import com.bookstore.repository.BookMapper;
import com.bookstore.service.BookService;
import com.bookstore.vo.BookVO;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class BookServiceImpl extends ServiceImpl<BookMapper, Book> implements BookService {

    @Override
    public Map<String, List<BookVO>> getHomeBooks() {
        Map<String, List<BookVO>> result = new HashMap<>();
        
        // Mocking Hot, New, Free logic with simple queries
        List<Book> hotBooks = list(new LambdaQueryWrapper<Book>()
                .orderByDesc(Book::getViews)
                .last("LIMIT 5"));
        
        List<Book> newBooks = list(new LambdaQueryWrapper<Book>()
                .orderByDesc(Book::getCreatedAt)
                .last("LIMIT 5"));
        
        List<Book> freeBooks = list(new LambdaQueryWrapper<Book>()
                .last("LIMIT 5")); // Assuming all are free for now or add a price column later

        result.put("hot", convertToVOList(hotBooks));
        result.put("new", convertToVOList(newBooks));
        result.put("free", convertToVOList(freeBooks));
        
        return result;
    }

    @Override
    public BookVO getBookDetails(Long id) {
        Book book = getById(id);
        if (book == null) {
            throw new RuntimeException("Book not found");
        }
        return convertToVO(book);
    }

    @Override
    public List<BookVO> searchBooks(String keyword) {
        List<Book> books = list(new LambdaQueryWrapper<Book>()
                .like(Book::getTitle, keyword)
                .or()
                .like(Book::getAuthor, keyword));
        return convertToVOList(books);
    }

    private List<BookVO> convertToVOList(List<Book> books) {
        return books.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    private BookVO convertToVO(Book book) {
        BookVO vo = new BookVO();
        BeanUtils.copyProperties(book, vo);
        return vo;
    }
}
