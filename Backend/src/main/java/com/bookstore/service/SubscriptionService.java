package com.bookstore.service;

import com.bookstore.dto.SubscriptionCreateRequest;
import com.bookstore.dto.SubscriptionProductDTO;
import com.bookstore.dto.SubscriptionStatusDTO;
import com.bookstore.dto.SubscriptionVerifyRequest;
import com.bookstore.entity.Order;
import com.bookstore.entity.SubscriptionProduct;

import java.util.List;

public interface SubscriptionService {

    /**
     * Get all active subscription products
     */
    List<SubscriptionProductDTO> getSubscriptionProducts(String platform);

    /**
     * Create subscription order (mock payment)
     */
    Order createSubscription(Long userId, SubscriptionCreateRequest request);

    /**
     * Get user subscription status
     */
    SubscriptionStatusDTO getSubscriptionStatus(Long userId);

    /**
     * Cancel subscription
     */
    void cancelSubscription(Long userId, String reason);

    /**
     * Update user subscription status after payment verification
     */
    void updateUserSubscriptionStatus(Long userId, Order order);

    /**
     * Check if subscription is valid
     */
    boolean isSubscriptionValid(Long userId);

    /**
     * Process expired subscriptions (for scheduled task)
     */
    void processExpiredSubscriptions();

    /**
     * Get subscription product by product ID
     */
    SubscriptionProduct getProductByProductId(String productId);

    /**
     * Verify purchase receipt and activate subscription
     */
    Order verifyAndActivateSubscription(Long userId, SubscriptionVerifyRequest request);
}
