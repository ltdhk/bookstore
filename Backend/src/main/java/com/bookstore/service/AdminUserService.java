package com.bookstore.service;

import com.bookstore.entity.AdminUser;
import com.baomidou.mybatisplus.extension.service.IService;

public interface AdminUserService extends IService<AdminUser> {
    String login(String username, String password);
    void createDefaultAdminIfNotExist();
}
