package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.dto.AppleSignInRequest;
import com.bookstore.dto.GoogleSignInRequest;
import com.bookstore.dto.LoginRequest;
import com.bookstore.dto.RegisterRequest;
import com.bookstore.service.AppleSignInService;
import com.bookstore.service.GoogleSignInService;
import com.bookstore.service.UserService;
import com.bookstore.vo.UserVO;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private AppleSignInService appleSignInService;

    @Autowired
    private GoogleSignInService googleSignInService;

    @PostMapping("/login")
    public Result<UserVO> login(@Valid @RequestBody LoginRequest request) {
        return Result.success(userService.login(request));
    }

    @PostMapping("/register")
    public Result<UserVO> register(@Valid @RequestBody RegisterRequest request) {
        return Result.success(userService.register(request));
    }

    @PostMapping("/apple")
    public Result<UserVO> appleLogin(@Valid @RequestBody AppleSignInRequest request) {
        return Result.success(appleSignInService.signInWithApple(request));
    }

    @PostMapping("/google")
    public Result<UserVO> googleLogin(@Valid @RequestBody GoogleSignInRequest request) {
        return Result.success(googleSignInService.signInWithGoogle(request));
    }
}
