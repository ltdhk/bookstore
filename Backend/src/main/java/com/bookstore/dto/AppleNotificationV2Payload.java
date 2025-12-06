package com.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * Decoded Apple App Store Server Notification V2 Payload
 * This is the structure after decoding the signedPayload JWT
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AppleNotificationV2Payload {

    /**
     * The type of notification
     * Examples: ONE_TIME_CHARGE, SUBSCRIBED, DID_RENEW, DID_FAIL_TO_RENEW, EXPIRED, REFUND, etc.
     */
    @JsonProperty("notificationType")
    private String notificationType;

    /**
     * A subtype for the notification (optional)
     * Examples: INITIAL_BUY, RESUBSCRIBE, DOWNGRADE, UPGRADE, etc.
     */
    @JsonProperty("subtype")
    private String subtype;

    /**
     * Unique identifier for this notification
     */
    @JsonProperty("notificationUUID")
    private String notificationUUID;

    /**
     * Version of the notification (e.g., "2.0")
     */
    @JsonProperty("version")
    private String version;

    /**
     * The timestamp when the notification was signed
     */
    @JsonProperty("signedDate")
    private Long signedDate;

    /**
     * The notification data containing transaction and renewal info
     */
    @JsonProperty("data")
    private NotificationData data;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class NotificationData {
        /**
         * App Apple ID
         */
        @JsonProperty("appAppleId")
        private Long appAppleId;

        /**
         * Bundle ID of the app
         */
        @JsonProperty("bundleId")
        private String bundleId;

        /**
         * Bundle version
         */
        @JsonProperty("bundleVersion")
        private String bundleVersion;

        /**
         * Environment: Sandbox or Production
         */
        @JsonProperty("environment")
        private String environment;

        /**
         * Signed transaction info (JWT) - contains transaction details
         */
        @JsonProperty("signedTransactionInfo")
        private String signedTransactionInfo;

        /**
         * Signed renewal info (JWT) - contains renewal details (optional)
         */
        @JsonProperty("signedRenewalInfo")
        private String signedRenewalInfo;

        /**
         * Status of the subscription (optional)
         * 1 = active, 2 = expired, 3 = billing retry, 4 = billing grace period, 5 = revoked
         */
        @JsonProperty("status")
        private Integer status;
    }
}
