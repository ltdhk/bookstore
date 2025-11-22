package com.bookstore.controller.admin;

import com.bookstore.common.Result;
import com.bookstore.repository.BookMapper;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.UserMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DashboardController {

    private final UserMapper userMapper;
    private final BookMapper bookMapper;
    private final OrderRepository orderRepository;

    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // User stats
        Long totalUsers = userMapper.selectCount(null);
        stats.put("totalUsers", totalUsers);
        stats.put("activeUsers", totalUsers); // Mock for now
        
        // Book stats
        Long totalBooks = bookMapper.selectCount(null);
        stats.put("totalBooks", totalBooks);
        
        // Order stats
        Long totalOrders = orderRepository.selectCount(null);
        stats.put("totalOrders", totalOrders);
        stats.put("totalRevenue", 92823.50); // Mock
        stats.put("readingTime", 1128); // Mock
        
        return Result.success(stats);
    }
}
