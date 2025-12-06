package com.bookstore.service;

import com.bookstore.dto.SubscriptionInfo;
import com.bookstore.exception.ReceiptVerificationException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.Map;

/**
 * Apple receipt verification service
 * Verifies App Store purchase receipts with Apple servers
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AppleReceiptVerificationService {

    @Value("${iap.apple.production-url}")
    private String productionUrl;

    @Value("${iap.apple.sandbox-url}")
    private String sandboxUrl;

    @Value("${iap.apple.shared-secret}")
    private String sharedSecret;

    @Value("${iap.apple.bundle-id}")
    private String bundleId;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Verify Apple receipt (backward compatible - uses last transaction)
     * @param receiptData Base64 encoded receipt data
     * @return Subscription information
     */
    public SubscriptionInfo verifyReceipt(String receiptData) {
        return verifyReceipt(receiptData, null);
    }

    /**
     * Verify Apple receipt and find transaction matching the specified productId
     * @param receiptData Base64 encoded receipt data
     * @param targetProductId Product ID to match (if null, returns last transaction)
     * @return Subscription information
     */
    public SubscriptionInfo verifyReceipt(String receiptData, String targetProductId) {
        try {
            log.info("Verifying Apple receipt, targetProductId: {}", targetProductId);

            // Try production environment first
            JsonNode response = postToApple(productionUrl, receiptData);
            int status = response.get("status").asInt();

            // If status is 21007, it's a sandbox receipt, retry with sandbox URL
            if (status == 21007) {
                log.info("Receipt is from sandbox environment, retrying with sandbox URL");
                response = postToApple(sandboxUrl, receiptData);
                status = response.get("status").asInt();
            }

            // Check status code
            if (status != 0) {
                throw new ReceiptVerificationException("Apple receipt verification failed with status: " + status);
            }

            // Verify bundle ID
            String receivedBundleId = response.get("receipt").get("bundle_id").asText();
            if (!bundleId.equals(receivedBundleId)) {
                throw new ReceiptVerificationException("Bundle ID mismatch: expected " + bundleId + ", got " + receivedBundleId);
            }

            // Extract subscription info from latest_receipt_info
            JsonNode latestReceiptInfo = response.get("latest_receipt_info");
            if (latestReceiptInfo == null || !latestReceiptInfo.isArray() || latestReceiptInfo.size() == 0) {
                throw new ReceiptVerificationException("No subscription info found in receipt");
            }

            // Find the correct transaction based on productId
            JsonNode targetTransaction = null;

            if (targetProductId != null) {
                // 遍历所有交易，找到匹配 productId 的最新交易
                long latestPurchaseDate = 0;
                for (JsonNode txn : latestReceiptInfo) {
                    String txnProductId = txn.get("product_id").asText();
                    if (targetProductId.equals(txnProductId)) {
                        long purchaseDateMs = txn.get("purchase_date_ms").asLong();
                        if (purchaseDateMs > latestPurchaseDate) {
                            latestPurchaseDate = purchaseDateMs;
                            targetTransaction = txn;
                        }
                    }
                }

                if (targetTransaction != null) {
                    log.info("找到匹配 productId {} 的交易: transactionId={}",
                        targetProductId, targetTransaction.get("transaction_id").asText());
                } else {
                    log.warn("未找到匹配 productId {} 的交易，回退到最后一笔交易", targetProductId);
                    targetTransaction = latestReceiptInfo.get(latestReceiptInfo.size() - 1);
                }
            } else {
                // 没有指定 productId，使用最后一笔交易（向后兼容）
                targetTransaction = latestReceiptInfo.get(latestReceiptInfo.size() - 1);
            }

            return parseAppleSubscription(targetTransaction);

        } catch (Exception e) {
            log.error("Failed to verify Apple receipt", e);
            throw new ReceiptVerificationException("Failed to verify Apple receipt: " + e.getMessage(), e);
        }
    }

    /**
     * Post receipt data to Apple server
     */
    private JsonNode postToApple(String url, String receiptData) throws Exception {
        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("receipt-data", receiptData);
        requestBody.put("password", sharedSecret);
        requestBody.put("exclude-old-transactions", "true");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, String>> request = new HttpEntity<>(requestBody, headers);

        ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);

        if (response.getStatusCode() != HttpStatus.OK) {
            throw new ReceiptVerificationException("Apple server returned status: " + response.getStatusCode());
        }

        return objectMapper.readTree(response.getBody());
    }

    /**
     * Parse Apple subscription JSON to SubscriptionInfo
     * 支持 Auto-Renewable Subscription 和 Non-Renewing Subscription
     */
    private SubscriptionInfo parseAppleSubscription(JsonNode subscription) {
        String originalTransactionId = subscription.get("original_transaction_id").asText();
        String transactionId = subscription.get("transaction_id").asText();
        String productId = subscription.get("product_id").asText();

        long purchaseDateMs = subscription.get("purchase_date_ms").asLong();

        LocalDateTime purchaseDate = LocalDateTime.ofInstant(
            Instant.ofEpochMilli(purchaseDateMs),
            ZoneId.systemDefault()
        );

        // Non-Renewing Subscription 没有 expires_date_ms 字段
        // 需要根据产品类型来计算过期时间，或者设为 null 让调用方处理
        LocalDateTime expiryDate = null;
        JsonNode expiresDateNode = subscription.get("expires_date_ms");
        if (expiresDateNode != null && !expiresDateNode.isNull()) {
            long expiresDateMs = expiresDateNode.asLong();
            expiryDate = LocalDateTime.ofInstant(
                Instant.ofEpochMilli(expiresDateMs),
                ZoneId.systemDefault()
            );
        }

        // Check if auto-renewing (Non-Renewing Subscription 没有这个字段)
        boolean autoRenewing = subscription.has("auto_renew_status") &&
            subscription.get("auto_renew_status").asText().equals("1");

        // Check if valid
        // 对于 Non-Renewing Subscription，expiryDate 为 null，默认视为有效（由调用方根据产品设置过期时间）
        boolean valid = expiryDate == null || LocalDateTime.now().isBefore(expiryDate);

        return SubscriptionInfo.builder()
            .originalTransactionId(originalTransactionId)
            .transactionId(transactionId)
            .productId(productId)
            .purchaseDate(purchaseDate)
            .expiryDate(expiryDate)
            .autoRenewing(autoRenewing)
            .valid(valid)
            .build();
    }
}
