package com.bookstore.controller.admin;

import com.bookstore.common.Result;
import com.bookstore.dto.UserInfoDTO;
import com.bookstore.entity.AdminUser;
import com.bookstore.entity.Distributor;
import com.bookstore.service.AdminUserService;
import com.bookstore.service.DistributorService;
import com.bookstore.util.JwtUtils;
import com.bookstore.exception.CustomException;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminAuthController {

    private final AdminUserService adminUserService;
    private final DistributorService distributorService;
    private final JwtUtils jwtUtils;

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

    @PostMapping("/distributor-login")
    public Result<Map<String, Object>> distributorLogin(@RequestBody LoginRequest request) {
        // 根据用户名查找分销商
        Distributor distributor = distributorService.lambdaQuery()
                .eq(Distributor::getUsername, request.getUsername())
                .one();

        if (distributor == null) {
            throw new CustomException("用户名或密码错误");
        }

        // 验证密码
        if (!distributor.getPassword().equals(request.getPassword())) {
            throw new CustomException("用户名或密码错误");
        }

        // 检查状态
        if (distributor.getStatus() != 1) {
            throw new CustomException("账号已被禁用");
        }

        // 生成 token，角色为 distributor
        String token = jwtUtils.generateToken(distributor.getId(), distributor.getUsername(), "distributor");

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("role", "distributor");
        result.put("distributorId", distributor.getId());
        result.put("distributorName", distributor.getName());

        return Result.success(result);
    }

    @GetMapping("/user-info")
    public Result<UserInfoDTO> getUserInfo(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new CustomException("无效的认证信息");
        }

        String token = authHeader.substring(7);
        if (!jwtUtils.validateToken(token)) {
            throw new CustomException("Token已过期或无效");
        }

        String role = jwtUtils.getRoleFromToken(token);
        Long userId = jwtUtils.getUserIdFromToken(token);
        String username = jwtUtils.getUsernameFromToken(token);

        UserInfoDTO userInfo = new UserInfoDTO();
        userInfo.setRole(role);
        userInfo.setUsername(username);

        if ("admin".equals(role)) {
            userInfo.setDisplayName("管理员");
            userInfo.setPermissions(Arrays.asList("*"));
        } else if ("distributor".equals(role)) {
            Distributor distributor = distributorService.getById(userId);
            if (distributor != null) {
                userInfo.setDisplayName(distributor.getName());
                userInfo.setDistributorId(distributor.getId());
            }
            // 分销商权限列表
            userInfo.setPermissions(Arrays.asList(
                "dashboard:view",
                "book:view", "book:edit", "book:import", "book:cover",
                "subscription:view", "subscription:distributor-revenue"
            ));
        }

        return Result.success(userInfo);
    }

    @Data
    static class LoginRequest {
        private String username;
        private String password;
    }
}
