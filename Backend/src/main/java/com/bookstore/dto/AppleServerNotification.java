package com.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * Apple App Store Server Notification
 * https://developer.apple.com/documentation/appstoreservernotifications
 */
@Data
public class AppleServerNotification {

    /**
     * Notification type
     * Examples: SUBSCRIBED, DID_RENEW, DID_FAIL_TO_RENEW, DID_CHANGE_RENEWAL_STATUS, EXPIRED, REFUND
     */
    @JsonProperty("notification_type")
    private String notificationType;

    /**
     * Notification subtype (optional)
     */
    @JsonProperty("subtype")
    private String subtype;

    /**
     * Notification UUID
     */
    @JsonProperty("notification_uuid")
    private String notificationUuid;

    /**
     * Signed renewal info (JWT)
     */
    @JsonProperty("data")
    private NotificationData data;

    @Data
    public static class NotificationData {
        /**
         * App Apple ID
         */
        @JsonProperty("app_apple_id")
        private Long appAppleId;

        /**
         * Bundle ID
         */
        @JsonProperty("bundle_id")
        private String bundleId;

        /**
         * Environment (Sandbox or Production)
         */
        @JsonProperty("environment")
        private String environment;

        /**
         * Signed transaction info (JWT)
         */
        @JsonProperty("signed_transaction_info")
        private String signedTransactionInfo;

        /**
         * Signed renewal info (JWT)
         */
        @JsonProperty("signed_renewal_info")
        private String signedRenewalInfo;
    }
}
