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

    @Data
    static class LoginRequest {
        private String username;
        private String password;
    }
}
