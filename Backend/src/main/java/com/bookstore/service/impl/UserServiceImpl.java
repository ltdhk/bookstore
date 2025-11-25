package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.dto.LoginRequest;
import com.bookstore.dto.RegisterRequest;
import com.bookstore.entity.User;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.UserService;
import com.bookstore.util.JwtUtils;
import com.bookstore.vo.UserVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public UserVO login(LoginRequest request) {
        User user = getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, request.getUsername()));

        // Password is MD5 encrypted on client side before being sent
        if (user == null || !user.getPassword().equals(request.getPassword())) {
            throw new RuntimeException("Invalid username or password");
        }

        return convertToVO(user);
    }

    @Override
    public UserVO register(RegisterRequest request) {
        User existingUser = getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, request.getUsername()));
        if (existingUser != null) {
            throw new RuntimeException("Username already exists");
        }

        User user = new User();
        BeanUtils.copyProperties(request, user);
        // Password is already MD5 encrypted on client side, stored as-is
        user.setEmail(request.getUsername()); // Set email same as username
        user.setNickname(request.getNickname() != null ? request.getNickname() : "User_" + System.currentTimeMillis());
        user.setAvatar("https://api.dicebear.com/7.x/avataaars/svg?seed=" + request.getUsername());
        user.setCoins(0);
        user.setBonus(0);
        user.setIsSvip(false);

        save(user);

        return convertToVO(user);
    }

    @Override
    public UserVO getUserProfile(Long userId) {
        User user = getById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return convertToVO(user);
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setToken(jwtUtils.generateToken(user.getId(), user.getUsername()));
        return vo;
    }
}
