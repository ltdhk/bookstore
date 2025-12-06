package com.bookstore.controller;

import com.bookstore.dto.AppleServerNotification;
import com.bookstore.dto.AppleServerNotificationV2;
import com.bookstore.dto.GooglePlayNotification;
import com.bookstore.service.AppleWebhookService;
import com.bookstore.service.GoogleWebhookService;
import com.bookstore.util.Result;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * Webhook Controller for App Store and Google Play notifications
 */
@Slf4j
@RestController
@RequestMapping("/api/webhook")
@RequiredArgsConstructor
public class WebhookController {

    private final AppleWebhookService appleWebhookService;
    private final GoogleWebhookService googleWebhookService;

    /**
     * Apple App Store Server Notifications endpoint
     *
     * Configuration in App Store Connect:
     * - Production Server URL: https://your-domain.com/api/webhook/apple
     * - Sandbox Server URL: https://your-domain.com/api/webhook/apple
     *
     * @param notification Apple server notification
     * @return Success response
     */
    @PostMapping("/apple")
    public Result<String> handleAppleNotification(
            @RequestBody String rawBody) {

        log.info("Received Apple webhook - Raw body length: {} bytes", rawBody.length());
        log.debug("Raw body content: {}", rawBody);

        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();

            // Try to detect if this is V2 format (has signedPayload field)
            if (rawBody.contains("\"signedPayload\"")) {
                log.info("Detected Apple App Store Server Notification V2 format");

                // Parse V2 format
                AppleServerNotificationV2 notificationV2 = mapper.readValue(rawBody, AppleServerNotificationV2.class);

                log.info("Received V2 notification with signedPayload (JWT length: {} chars)",
                    notificationV2.getSignedPayload().length());

                // Process V2 notification
                appleWebhookService.handleV2Notification(notificationV2.getSignedPayload());

                return Result.success("V2 notification processed successfully");
            } else {
                log.info("Detected Apple App Store Server Notification V1 format");

                // Parse V1 format
                AppleServerNotification notification = mapper.readValue(rawBody, AppleServerNotification.class);

                log.info("Parsed V1 notification: type={}, uuid={}",
                    notification.getNotificationType(),
                    notification.getNotificationUuid());

                appleWebhookService.handleNotification(notification);
                return Result.success("V1 notification processed successfully");
            }
        } catch (Exception e) {
            log.error("Failed to process Apple notification", e);
            // Still return success to prevent Apple from retrying
            // We log the error for investigation
            return Result.success("Notification received");
        }
    }

    /**
     * Google Play Real-time Developer Notifications endpoint
     *
     * Configuration in Google Play Console:
     * - Topic name: Create a Cloud Pub/Sub topic
     * - Configure Cloud Pub/Sub push subscription to:
     *   https://your-domain.com/api/webhook/google
     *
     * The notification is base64 encoded in the "message.data" field
     *
     * @param request Pub/Sub push request
     * @return Success response
     */
    @PostMapping("/google")
    public Result<String> handleGoogleNotification(@RequestBody PubSubRequest request) {
        log.info("Received Google Play webhook notification");

        try {
            // Decode the base64 encoded message
            if (request.getMessage() != null && request.getMessage().getData() != null) {
                String decodedData = new String(
                    java.util.Base64.getDecoder().decode(request.getMessage().getData())
                );

                log.debug("Decoded Google notification: {}", decodedData);

                // Parse the JSON notification
                com.fasterxml.jackson.databind.ObjectMapper mapper =
                    new com.fasterxml.jackson.databind.ObjectMapper();
                GooglePlayNotification notification =
                    mapper.readValue(decodedData, GooglePlayNotification.class);

                googleWebhookService.handleNotification(notification);
                return Result.success("Notification processed successfully");
            } else {
                log.warn("No message data in Google notification");
                return Result.success("No data");
            }
        } catch (Exception e) {
            log.error("Failed to process Google notification", e);
            // Still return success to prevent Google from retrying
            return Result.success("Notification received");
        }
    }

    /**
     * Pub/Sub push request wrapper
     */
    public static class PubSubRequest {
        private PubSubMessage message;
        private String subscription;

        public PubSubMessage getMessage() {
            return message;
        }

        public void setMessage(PubSubMessage message) {
            this.message = message;
        }

        public String getSubscription() {
            return subscription;
        }

        public void setSubscription(String subscription) {
            this.subscription = subscription;
        }
    }

    /**
     * Pub/Sub message
     */
    public static class PubSubMessage {
        private String data; // Base64 encoded
        private String messageId;
        private java.util.Map<String, String> attributes;

        public String getData() {
            return data;
        }

        public void setData(String data) {
            this.data = data;
        }

        public String getMessageId() {
            return messageId;
        }

        public void setMessageId(String messageId) {
            this.messageId = messageId;
        }

        public java.util.Map<String, String> getAttributes() {
            return attributes;
        }

        public void setAttributes(java.util.Map<String, String> attributes) {
            this.attributes = attributes;
        }
    }
}
