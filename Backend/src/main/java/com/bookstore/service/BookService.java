package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.entity.Book;
import com.bookstore.vo.BookVO;

import java.util.List;
import java.util.Map;

public interface BookService extends IService<Book> {
    Map<String, List<BookVO>> getHomeBooks();
    BookVO getBookDetails(Long id);
    List<BookVO> searchBooks(String keyword);
}
