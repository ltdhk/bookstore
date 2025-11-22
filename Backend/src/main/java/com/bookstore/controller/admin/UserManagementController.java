package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.User;
import com.bookstore.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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
            @RequestParam(required = false) String keyword) {
        Page<User> pageParam = new Page<>(page, size);
        IPage<User> result = userService.page(pageParam);
        return Result.success(result);
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
