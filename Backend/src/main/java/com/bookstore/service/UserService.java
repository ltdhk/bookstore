package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.dto.LoginRequest;
import com.bookstore.dto.RegisterRequest;
import com.bookstore.entity.User;
import com.bookstore.vo.UserVO;

public interface UserService extends IService<User> {
    UserVO login(LoginRequest request);
    UserVO register(RegisterRequest request);
    UserVO getUserProfile(Long userId);
}
