package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.User;
import com.bookstore.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class UserManagementController {

    private final UserService userService;

    @GetMapping
    public Result<IPage<User>> getUsers(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String username) {
        Page<User> pageParam = new Page<>(page, size);
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        if (StringUtils.hasText(username)) {
            queryWrapper.like("username", username);
        }
        queryWrapper.orderByDesc("id");
        IPage<User> result = userService.page(pageParam, queryWrapper);
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<User> getUserById(@PathVariable Long id) {
        User user = userService.getById(id);
        if (user != null) {
            user.setPassword(null); // 不返回密码
        }
        return Result.success(user);
    }

    @PostMapping
    public Result<String> createUser(@RequestBody User user) {
        // 检查用户名是否已存在
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", user.getUsername());
        if (userService.count(queryWrapper) > 0) {
            return Result.error("该用户名已存在");
        }
        // 使用 MD5 加密密码（与客户端注册逻辑保持一致）
        if (StringUtils.hasText(user.getPassword())) {
            user.setPassword(DigestUtils.md5DigestAsHex(user.getPassword().getBytes(StandardCharsets.UTF_8)));
        }
        // 设置默认值
        if (user.getCoins() == null) {
            user.setCoins(0);
        }
        if (user.getBonus() == null) {
            user.setBonus(0);
        }
        if (user.getIsSvip() == null) {
            user.setIsSvip(false);
        }
        userService.save(user);
        return Result.success("创建成功");
    }

    @PutMapping("/{id}")
    public Result<String> updateUser(@PathVariable Long id, @RequestBody User user) {
        User existingUser = userService.getById(id);
        if (existingUser == null) {
            return Result.error("用户不存在");
        }
        user.setId(id);
        // 保持原用户名不变（不允许修改）
        user.setUsername(existingUser.getUsername());
        // 如果密码为空，保持原密码；否则使用 MD5 加密
        if (!StringUtils.hasText(user.getPassword())) {
            user.setPassword(existingUser.getPassword());
        } else {
            user.setPassword(DigestUtils.md5DigestAsHex(user.getPassword().getBytes(StandardCharsets.UTF_8)));
        }
        userService.updateById(user);
        return Result.success("更新成功");
    }

    @PutMapping("/{id}/status")
    public Result<String> updateUserStatus(@PathVariable Long id, @RequestParam Integer status) {
        User user = userService.getById(id);
        if (user != null) {
            user.setDeleted(status == 0 ? 1 : 0);
            userService.updateById(user);
        }
        return Result.success("Updated");
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteUser(@PathVariable Long id) {
        userService.removeById(id);
        return Result.success("Deleted");
    }
}
