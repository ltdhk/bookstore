package com.bookstore.config;

import com.bookstore.service.AdminUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

    private final AdminUserService adminUserService;

    @Override
    public void run(ApplicationArguments args) {
        adminUserService.createDefaultAdminIfNotExist();
        System.out.println("=== 默认管理员账号已初始化 ===");
        System.out.println("用户名: admin");
        System.out.println("密码: admin123");
        System.out.println("============================");
    }
}
