package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.service.UserService;
import com.bookstore.vo.UserVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/profile")
    public Result<UserVO> getProfile(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(userService.getUserProfile(userId));
    }

    @Autowired
    private com.bookstore.service.BookshelfService bookshelfService;

    @GetMapping("/bookshelf")
    public Result<java.util.List<com.bookstore.vo.BookVO>> getBookshelf(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(bookshelfService.getMyBookshelf(userId));
    }

    @org.springframework.web.bind.annotation.PostMapping("/bookshelf")
    public Result<String> addToBookshelf(HttpServletRequest request, @org.springframework.web.bind.annotation.RequestBody java.util.Map<String, Long> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long bookId = body.get("bookId");
        bookshelfService.addBookToShelf(userId, bookId);
        return Result.success("Added to bookshelf");
    }

    @org.springframework.web.bind.annotation.DeleteMapping("/bookshelf")
    public Result<String> removeFromBookshelf(HttpServletRequest request, @org.springframework.web.bind.annotation.RequestBody java.util.Map<String, Long> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long bookId = body.get("bookId");
        bookshelfService.removeBookFromShelf(userId, bookId);
        return Result.success("Removed from bookshelf");
    }

    @GetMapping("/bookshelf/check")
    public Result<Boolean> checkBookInShelf(HttpServletRequest request, @org.springframework.web.bind.annotation.RequestParam Long bookId) {
        Long userId = (Long) request.getAttribute("userId");
        boolean isInShelf = bookshelfService.isBookInShelf(userId, bookId);
        return Result.success(isInShelf);
    }

    @org.springframework.web.bind.annotation.PostMapping("/wallet/topup")
    public Result<UserVO> topUp(HttpServletRequest request, @org.springframework.web.bind.annotation.RequestBody java.util.Map<String, Integer> body) {
        Long userId = (Long) request.getAttribute("userId");
        Integer amount = body.get("amount");
        // Mock implementation: just add to user coins
        com.bookstore.entity.User user = userService.getById(userId);
        user.setCoins(user.getCoins() + amount);
        userService.updateById(user);
        return Result.success(userService.getUserProfile(userId));
    }

    @org.springframework.web.bind.annotation.PostMapping("/membership/subscribe")
    public Result<UserVO> subscribe(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        // Mock implementation: set isSvip to true
        com.bookstore.entity.User user = userService.getById(userId);
        user.setIsSvip(true);
        userService.updateById(user);
        return Result.success(userService.getUserProfile(userId));
    }


}
