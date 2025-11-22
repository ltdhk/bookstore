package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.entity.Bookshelf;
import com.bookstore.vo.BookVO;

import java.util.List;

public interface BookshelfService extends IService<Bookshelf> {
    List<BookVO> getMyBookshelf(Long userId);
    void addBookToShelf(Long userId, Long bookId);
    void removeBookFromShelf(Long userId, Long bookId);
    void updateReadingProgress(Long userId, Long bookId, Long chapterId);
}
