package com.bookstore.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Order;
import com.bookstore.repository.OrderRepository;
import com.bookstore.util.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

/**
 * User Order Controller
 * For client-side transaction record viewing
 */
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderRepository orderRepository;
    private final JwtUtils jwtUtils;

    /**
     * Get current user's orders
     * @param page Page number (default 1)
     * @param size Page size (default 10)
     * @return Paginated order list
     */
    @GetMapping
    public Result<IPage<Order>> getMyOrders(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            HttpServletRequest httpRequest) {

        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            Page<Order> pageParam = new Page<>(page, size);
            QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId)
                       .orderByDesc("create_time");

            IPage<Order> result = orderRepository.selectPage(pageParam, queryWrapper);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("Failed to get orders: " + e.getMessage());
        }
    }

    /**
     * Get order detail by ID
     * @param id Order ID
     * @return Order detail
     */
    @GetMapping("/{id}")
    public Result<Order> getOrderById(@PathVariable Long id, HttpServletRequest httpRequest) {
        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            Order order = orderRepository.selectById(id);

            // Check if order belongs to current user
            if (order == null || !order.getUserId().equals(userId)) {
                return Result.error("Order not found");
            }

            return Result.success(order);
        } catch (Exception e) {
            return Result.error("Failed to get order: " + e.getMessage());
        }
    }
}
