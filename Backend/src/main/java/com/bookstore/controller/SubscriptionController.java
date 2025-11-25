package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.dto.SubscriptionCreateRequest;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.dto.SubscriptionStatusDTO;
import com.bookstore.entity.Order;
import com.bookstore.service.SubscriptionService;
import com.bookstore.util.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/subscription")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;
    private final JwtUtils jwtUtils;

    /**
     * Get subscription products
     */
    @GetMapping("/products")
    public Result<List<SubscriptionProductDTO>> getProducts(
            @RequestParam(required = false) String platform) {
        try {
            List<SubscriptionProductDTO> products = subscriptionService.getSubscriptionProducts(platform);
            return Result.success(products);
        } catch (Exception e) {
            return Result.error("Failed to get products: " + e.getMessage());
        }
    }

    /**
     * Create subscription (mock payment)
     */
    @PostMapping("/create")
    public Result<Order> createSubscription(
            @RequestBody SubscriptionCreateRequest request,
            HttpServletRequest httpRequest) {
        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            Order order = subscriptionService.createSubscription(userId, request);
            return Result.success(order);
        } catch (Exception e) {
            return Result.error("Failed to create subscription: " + e.getMessage());
        }
    }

    /**
     * Get subscription status
     */
    @GetMapping("/status")
    public Result<SubscriptionStatusDTO> getStatus(HttpServletRequest httpRequest) {
        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            SubscriptionStatusDTO status = subscriptionService.getSubscriptionStatus(userId);
            return Result.success(status);
        } catch (Exception e) {
            return Result.error("Failed to get status: " + e.getMessage());
        }
    }

    /**
     * Cancel subscription
     */
    @PostMapping("/cancel")
    public Result<String> cancelSubscription(
            @RequestParam(required = false) String reason,
            HttpServletRequest httpRequest) {
        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            subscriptionService.cancelSubscription(userId, reason);
            return Result.success("Subscription cancelled successfully");
        } catch (Exception e) {
            return Result.error("Failed to cancel subscription: " + e.getMessage());
        }
    }

    /**
     * Check if subscription is valid
     */
    @GetMapping("/valid")
    public Result<Boolean> isValid(HttpServletRequest httpRequest) {
        try {
            // Get user ID from token
            String token = httpRequest.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            Long userId = jwtUtils.getUserIdFromToken(token);

            boolean isValid = subscriptionService.isSubscriptionValid(userId);
            return Result.success(isValid);
        } catch (Exception e) {
            return Result.error("Failed to check subscription: " + e.getMessage());
        }
    }
}
