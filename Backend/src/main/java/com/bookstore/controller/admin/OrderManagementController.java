package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Order;
import com.bookstore.repository.OrderRepository;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class OrderManagementController {

    private final OrderRepository orderRepository;

    @GetMapping
    public Result<IPage<Order>> getOrders(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Page<Order> pageParam = new Page<>(page, size);
        IPage<Order> result = orderRepository.selectPage(pageParam, null);
        return Result.success(result);
    }

    @PutMapping("/{id}/refund")
    public Result<String> refundOrder(@PathVariable Long id) {
        Order order = orderRepository.selectById(id);
        if (order != null) {
            order.setStatus("Refunded");
            orderRepository.updateById(order);
        }
        return Result.success("Refunded");
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteOrder(@PathVariable Long id) {
        orderRepository.deleteById(id);
        return Result.success("Deleted");
    }
}
