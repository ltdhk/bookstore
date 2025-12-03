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
     * Verify Apple receipt
     * @param receiptData Base64 encoded receipt data
     * @return Subscription information
     */
    public SubscriptionInfo verifyReceipt(String receiptData) {
        try {
            log.info("Verifying Apple receipt");

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

            // Get the latest subscription
            JsonNode latestSubscription = latestReceiptInfo.get(latestReceiptInfo.size() - 1);

            return parseAppleSubscription(latestSubscription);

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
     */
    private SubscriptionInfo parseAppleSubscription(JsonNode subscription) {
        String originalTransactionId = subscription.get("original_transaction_id").asText();
        String transactionId = subscription.get("transaction_id").asText();
        String productId = subscription.get("product_id").asText();

        long purchaseDateMs = subscription.get("purchase_date_ms").asLong();
        long expiresDateMs = subscription.get("expires_date_ms").asLong();

        LocalDateTime purchaseDate = LocalDateTime.ofInstant(
            Instant.ofEpochMilli(purchaseDateMs),
            ZoneId.systemDefault()
        );

        LocalDateTime expiryDate = LocalDateTime.ofInstant(
            Instant.ofEpochMilli(expiresDateMs),
            ZoneId.systemDefault()
        );

        // Check if auto-renewing
        boolean autoRenewing = subscription.has("auto_renew_status") &&
            subscription.get("auto_renew_status").asText().equals("1");

        // Check if valid (not expired)
        boolean valid = LocalDateTime.now().isBefore(expiryDate);

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
