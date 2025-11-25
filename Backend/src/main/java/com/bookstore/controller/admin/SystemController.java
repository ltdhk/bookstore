package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.AdminUser;
import com.bookstore.entity.SystemConfig;
import com.bookstore.service.AdminUserService;
import com.bookstore.service.SystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/system")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SystemController {

    private final SystemConfigService systemConfigService;
    private final AdminUserService adminUserService;
    private final com.bookstore.repository.OperationLogRepository logRepository;

    // --- System Configs ---

    @GetMapping("/configs")
    public Result<List<SystemConfig>> getConfigs() {
        return Result.success(systemConfigService.list());
    }

    @PostMapping("/configs")
    public Result<SystemConfig> saveConfig(@RequestBody SystemConfig config) {
        QueryWrapper<SystemConfig> query = new QueryWrapper<>();
        query.eq("config_key", config.getConfigKey());
        SystemConfig existing = systemConfigService.getOne(query);
        
        if (existing != null) {
            existing.setConfigValue(config.getConfigValue());
            existing.setDescription(config.getDescription());
            systemConfigService.updateById(existing);
            return Result.success(existing);
        } else {
            systemConfigService.save(config);
            return Result.success(config);
        }
    }

    // --- Admin Users ---

    @GetMapping("/users")
    public Result<IPage<AdminUser>> getAdminUsers(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String username) {
        Page<AdminUser> pageParam = new Page<>(page, size);
        QueryWrapper<AdminUser> queryWrapper = new QueryWrapper<>();
        if (StringUtils.hasText(username)) {
            queryWrapper.like("username", username);
        }
        IPage<AdminUser> result = adminUserService.page(pageParam, queryWrapper);
        // Hide passwords
        result.getRecords().forEach(user -> user.setPassword(null));
        return Result.success(result);
    }

    @PostMapping("/users")
    public Result<AdminUser> createAdminUser(@RequestBody AdminUser user) {
        // In a real app, password should be hashed here
        adminUserService.save(user);
        user.setPassword(null);
        return Result.success(user);
    }

    @PutMapping("/users/{id}")
    public Result<AdminUser> updateAdminUser(@PathVariable Long id, @RequestBody AdminUser user) {
        user.setId(id);
        // If password is empty, don't update it
        if (!StringUtils.hasText(user.getPassword())) {
            user.setPassword(null);
        }
        adminUserService.updateById(user);
        user.setPassword(null);
        return Result.success(user);
    }

    @DeleteMapping("/users/{id}")
    public Result<String> deleteAdminUser(@PathVariable Long id) {
        adminUserService.removeById(id);
        return Result.success("Deleted");
    }

    // --- Operation Logs ---

    @GetMapping("/logs")
    public Result<IPage<com.bookstore.entity.OperationLog>> getLogs(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<com.bookstore.entity.OperationLog> pageParam = new Page<>(page, size);
        QueryWrapper<com.bookstore.entity.OperationLog> query = new QueryWrapper<>();
        query.orderByDesc("create_time");
        return Result.success(logRepository.selectPage(pageParam, query));
    }
}
