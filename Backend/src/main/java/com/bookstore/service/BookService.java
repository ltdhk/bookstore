package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.dto.ReaderDataDTO;
import com.bookstore.entity.Book;
import com.bookstore.vo.BookVO;

import java.util.List;
import java.util.Map;

public interface BookService extends IService<Book> {
    Map<String, List<BookVO>> getHomeBooks(Integer page, Integer pageSize, String language);
    BookVO getBookDetails(Long id);
    List<BookVO> searchBooks(String keyword);
    void likeBook(Long id);
    void incrementViews(Long id);

    com.baomidou.mybatisplus.core.metadata.IPage<Book> searchBooks(String keyword, com.baomidou.mybatisplus.extension.plugins.pagination.Page<Book> pageParam);

    /**
     * Get all reader data in a single call - optimized for reader page
     * Combines: book details + chapter list + first chapter content + subscription status
     * Reduces multiple API/DB calls to minimum
     */
    ReaderDataDTO getReaderData(Long bookId, Long userId);
}
