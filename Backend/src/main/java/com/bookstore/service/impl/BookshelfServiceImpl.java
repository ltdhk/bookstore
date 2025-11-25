package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Book;
import com.bookstore.entity.Bookshelf;
import com.bookstore.repository.BookshelfMapper;
import com.bookstore.service.BookService;
import com.bookstore.service.BookshelfService;
import com.bookstore.vo.BookVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class BookshelfServiceImpl extends ServiceImpl<BookshelfMapper, Bookshelf> implements BookshelfService {

    @Autowired
    private BookService bookService;

    @Override
    public List<BookVO> getMyBookshelf(Long userId) {
        List<Bookshelf> shelfItems = list(new LambdaQueryWrapper<Bookshelf>()
                .eq(Bookshelf::getUserId, userId)
                .orderByDesc(Bookshelf::getUpdatedAt));

        if (shelfItems.isEmpty()) {
            return new ArrayList<>();
        }

        List<Long> bookIds = shelfItems.stream().map(Bookshelf::getBookId).collect(Collectors.toList());
        List<Book> books = bookService.listByIds(bookIds);
        Map<Long, Book> bookMap = books.stream().collect(Collectors.toMap(Book::getId, Function.identity()));

        return shelfItems.stream().map(item -> {
            Book book = bookMap.get(item.getBookId());
            if (book == null) return null;
            BookVO vo = new BookVO();
            BeanUtils.copyProperties(book, vo);
            // Here we could add lastReadChapterId to BookVO if we extended it or created a BookshelfVO
            // For now, returning BookVO as per requirement, assuming frontend fetches progress separately or we just list books
            return vo;
        }).filter(java.util.Objects::nonNull).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void addBookToShelf(Long userId, Long bookId) {
        long count = count(new LambdaQueryWrapper<Bookshelf>()
                .eq(Bookshelf::getUserId, userId)
                .eq(Bookshelf::getBookId, bookId));
        
        if (count > 0) {
            return; // Already in shelf
        }

        Bookshelf bookshelf = new Bookshelf();
        bookshelf.setUserId(userId);
        bookshelf.setBookId(bookId);
        save(bookshelf);
    }

    @Override
    @Transactional
    public void removeBookFromShelf(Long userId, Long bookId) {
        remove(new LambdaQueryWrapper<Bookshelf>()
                .eq(Bookshelf::getUserId, userId)
                .eq(Bookshelf::getBookId, bookId));
    }

    @Override
    @Transactional
    public void updateReadingProgress(Long userId, Long bookId, Long chapterId) {
        Bookshelf bookshelf = getOne(new LambdaQueryWrapper<Bookshelf>()
                .eq(Bookshelf::getUserId, userId)
                .eq(Bookshelf::getBookId, bookId));

        if (bookshelf == null) {
            // Auto add to shelf if reading? Optional. For now, just return or error.
            // Let's auto-add.
            addBookToShelf(userId, bookId);
            bookshelf = getOne(new LambdaQueryWrapper<Bookshelf>()
                    .eq(Bookshelf::getUserId, userId)
                    .eq(Bookshelf::getBookId, bookId));
        }

        bookshelf.setLastReadChapterId(chapterId);
        updateById(bookshelf);
    }

    @Override
    public boolean isBookInShelf(Long userId, Long bookId) {
        long count = count(new LambdaQueryWrapper<Bookshelf>()
                .eq(Bookshelf::getUserId, userId)
                .eq(Bookshelf::getBookId, bookId));
        return count > 0;
    }
}
