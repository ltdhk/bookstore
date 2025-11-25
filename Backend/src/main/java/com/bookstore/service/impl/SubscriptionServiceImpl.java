package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.SubscriptionCreateRequest;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.dto.SubscriptionStatusDTO;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionProduct;
import com.bookstore.entity.User;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.SubscriptionProductRepository;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubscriptionServiceImpl implements SubscriptionService {

    private final SubscriptionProductRepository subscriptionProductRepository;
    private final OrderRepository orderRepository;
    private final UserMapper userMapper;

    @Override
    public List<SubscriptionProductDTO> getSubscriptionProducts(String platform) {
        QueryWrapper<SubscriptionProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_active", true);
        if (platform != null && !platform.isEmpty()) {
            queryWrapper.eq("platform", platform);
        }
        queryWrapper.orderByAsc("sort_order");

        List<SubscriptionProduct> products = subscriptionProductRepository.selectList(queryWrapper);
        return products.stream().map(product -> {
            SubscriptionProductDTO dto = new SubscriptionProductDTO();
            BeanUtils.copyProperties(product, dto);
            return dto;
        }).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Order createSubscription(Long userId, SubscriptionCreateRequest request) {
        // Get product info
        SubscriptionProduct product = getProductByProductId(request.getProductId());
        if (product == null || !product.getIsActive()) {
            throw new RuntimeException("Product not found or inactive");
        }

        // Create order
        Order order = new Order();
        order.setUserId(userId);
        order.setOrderNo(generateOrderNo());
        order.setAmount(product.getPrice());
        order.setStatus("Paid"); // Mock payment - directly set to Paid
        order.setPlatform(request.getPlatform());
        order.setProductId(request.getProductId());

        // Subscription fields
        order.setOrderType("subscription");
        order.setSubscriptionPeriod(product.getPlanType());

        LocalDateTime startDate = LocalDateTime.now();
        LocalDateTime endDate = startDate.plusDays(product.getDurationDays());
        order.setSubscriptionStartDate(startDate);
        order.setSubscriptionEndDate(endDate);
        order.setIsAutoRenew(true);

        // Mock transaction IDs
        order.setOriginalTransactionId(generateMockTransactionId(request.getPlatform()));
        order.setPlatformTransactionId("TXN_" + UUID.randomUUID().toString());

        // Mock receipt/token data
        if ("AppStore".equals(request.getPlatform())) {
            order.setReceiptData(generateMockReceipt(order));
        } else if ("GooglePay".equals(request.getPlatform())) {
            order.setPurchaseToken(generateMockPurchaseToken(order));
        }

        // Source tracking
        order.setDistributorId(request.getDistributorId());
        order.setSourcePasscodeId(request.getSourcePasscodeId());
        order.setSourceBookId(request.getSourceBookId());
        order.setSourceEntry(request.getSourceEntry());

        order.setCreateTime(LocalDateTime.now());
        order.setUpdateTime(LocalDateTime.now());

        // Save order
        orderRepository.insert(order);

        // Update user subscription status
        updateUserSubscriptionStatus(userId, order);

        return order;
    }

    @Override
    public SubscriptionStatusDTO getSubscriptionStatus(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        SubscriptionStatusDTO dto = new SubscriptionStatusDTO();
        dto.setSubscriptionStatus(user.getSubscriptionStatus());
        dto.setSubscriptionEndDate(user.getSubscriptionEndDate());
        dto.setSubscriptionPlanType(user.getSubscriptionPlanType());
        dto.setIsSvip(user.getIsSvip());

        // Get current active subscription order
        if ("active".equals(user.getSubscriptionStatus())) {
            QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("user_id", userId);
            queryWrapper.eq("order_type", "subscription");
            queryWrapper.eq("status", "Paid");
            queryWrapper.ge("subscription_end_date", LocalDateTime.now());
            queryWrapper.orderByDesc("create_time");
            queryWrapper.last("LIMIT 1");

            Order order = orderRepository.selectOne(queryWrapper);
            if (order != null) {
                dto.setOrderId(order.getId());
                dto.setOrderNo(order.getOrderNo());
                dto.setAmount(order.getAmount());
                dto.setPlatform(order.getPlatform());
                dto.setSubscriptionStartDate(order.getSubscriptionStartDate());
                dto.setIsAutoRenew(order.getIsAutoRenew());
            }
        }

        return dto;
    }

    @Override
    @Transactional
    public void cancelSubscription(Long userId, String reason) {
        User user = userMapper.selectById(userId);
        if (user == null || !"active".equals(user.getSubscriptionStatus())) {
            throw new RuntimeException("No active subscription to cancel");
        }

        // Update user status
        user.setSubscriptionStatus("cancelled");
        userMapper.updateById(user);

        // Update current active order
        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.eq("order_type", "subscription");
        queryWrapper.eq("status", "Paid");
        queryWrapper.ge("subscription_end_date", LocalDateTime.now());
        queryWrapper.orderByDesc("create_time");
        queryWrapper.last("LIMIT 1");

        Order order = orderRepository.selectOne(queryWrapper);
        if (order != null) {
            order.setIsAutoRenew(false);
            order.setCancelDate(LocalDateTime.now());
            order.setCancelReason(reason);
            order.setUpdateTime(LocalDateTime.now());
            orderRepository.updateById(order);
        }
    }

    @Override
    @Transactional
    public void updateUserSubscriptionStatus(Long userId, Order order) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        user.setIsSvip(true);
        user.setSubscriptionStatus("active");
        user.setSubscriptionEndDate(order.getSubscriptionEndDate());
        user.setSubscriptionPlanType(order.getSubscriptionPeriod());
        userMapper.updateById(user);
    }

    @Override
    public boolean isSubscriptionValid(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return false;
        }

        // Check if user is SVIP (manual assignment or active subscription)
        if (Boolean.TRUE.equals(user.getIsSvip())) {
            // If user has subscriptionEndDate, check if it's still valid
            if (user.getSubscriptionEndDate() != null) {
                return LocalDateTime.now().isBefore(user.getSubscriptionEndDate());
            }
            // If no end date set, SVIP is permanent (manually assigned)
            return true;
        }

        // Check subscription status for non-SVIP users
        if (!"active".equals(user.getSubscriptionStatus())) {
            return false;
        }

        if (user.getSubscriptionEndDate() == null) {
            return false;
        }

        return LocalDateTime.now().isBefore(user.getSubscriptionEndDate());
    }

    @Override
    @Transactional
    public void processExpiredSubscriptions() {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("subscription_status", "active");
        queryWrapper.lt("subscription_end_date", LocalDateTime.now());

        List<User> expiredUsers = userMapper.selectList(queryWrapper);
        for (User user : expiredUsers) {
            user.setSubscriptionStatus("expired");
            user.setIsSvip(false);
            userMapper.updateById(user);
        }
    }

    @Override
    public SubscriptionProduct getProductByProductId(String productId) {
        QueryWrapper<SubscriptionProduct> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("product_id", productId);
        return subscriptionProductRepository.selectOne(queryWrapper);
    }

    /**
     * Generate order number: SUB + timestamp + random 4 digits
     */
    private String generateOrderNo() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        Random random = new Random();
        int randomNum = random.nextInt(9000) + 1000; // 1000-9999
        return "SUB" + timestamp + randomNum;
    }

    /**
     * Generate mock transaction ID
     */
    private String generateMockTransactionId(String platform) {
        long timestamp = System.currentTimeMillis();
        return "MOCK_" + platform.toUpperCase() + "_" + timestamp;
    }

    /**
     * Generate mock Apple receipt (Base64 encoded JSON)
     */
    private String generateMockReceipt(Order order) {
        String receiptJson = String.format(
            "{\"transaction_id\":\"%s\",\"original_transaction_id\":\"%s\",\"product_id\":\"%s\",\"purchase_date_ms\":%d,\"expires_date_ms\":%d}",
            order.getPlatformTransactionId(),
            order.getOriginalTransactionId(),
            order.getProductId(),
            System.currentTimeMillis(),
            System.currentTimeMillis() + (order.getSubscriptionEndDate().getNano() - order.getSubscriptionStartDate().getNano())
        );
        return Base64.getEncoder().encodeToString(receiptJson.getBytes());
    }

    /**
     * Generate mock Google purchase token
     */
    private String generateMockPurchaseToken(Order order) {
        String tokenData = String.format(
            "{\"orderId\":\"%s\",\"productId\":\"%s\",\"purchaseTime\":%d,\"purchaseToken\":\"%s\"}",
            order.getOrderNo(),
            order.getProductId(),
            System.currentTimeMillis(),
            UUID.randomUUID().toString()
        );
        return Base64.getEncoder().encodeToString(tokenData.getBytes());
    }
}
