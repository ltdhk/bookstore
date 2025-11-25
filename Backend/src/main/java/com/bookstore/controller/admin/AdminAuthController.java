package com.bookstore.controller.admin;

import com.bookstore.common.Result;
import com.bookstore.entity.AdminUser;
import com.bookstore.service.AdminUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminAuthController {

    private final AdminUserService adminUserService;

    @PostMapping("/login")
    public Result<Map<String, String>> login(@RequestBody LoginRequest request) {
        String token = adminUserService.login(request.getUsername(), request.getPassword());
        Map<String, String> map = new HashMap<>();
        map.put("token", token);
        return Result.success(map);
    }

    @PostMapping("/init")
    public Result<String> init() {
        adminUserService.createDefaultAdminIfNotExist();
        return Result.success("Initialized");
    }

    @PostMapping("/logout")
    public Result<String> logout() {
        // 如果使用JWT，无需后端处理，前端删除token即可
        // 如果使用session，可以在这里清除session
        return Result.success("Logout successful");
    }

    @GetMapping("/verify")
    public Result<String> verify() {
        // 验证token有效性
        return Result.success("Token is valid");
    }

    @Data
    static class LoginRequest {
        private String username;
        private String password;
    }
}
