package com.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * Google Play Real-time Developer Notification
 * https://developer.android.com/google/play/billing/rtdn-reference
 */
@Data
public class GooglePlayNotification {

    /**
     * Version of the notification
     */
    @JsonProperty("version")
    private String version;

    /**
     * Package name
     */
    @JsonProperty("packageName")
    private String packageName;

    /**
     * Event timestamp in milliseconds
     */
    @JsonProperty("eventTimeMillis")
    private Long eventTimeMillis;

    /**
     * Subscription notification
     */
    @JsonProperty("subscriptionNotification")
    private SubscriptionNotification subscriptionNotification;

    /**
     * Test notification (for webhook verification)
     */
    @JsonProperty("testNotification")
    private TestNotification testNotification;

    @Data
    public static class SubscriptionNotification {
        /**
         * Notification type
         * 1: SUBSCRIPTION_RECOVERED
         * 2: SUBSCRIPTION_RENEWED
         * 3: SUBSCRIPTION_CANCELED
         * 4: SUBSCRIPTION_PURCHASED
         * 5: SUBSCRIPTION_ON_HOLD
         * 6: SUBSCRIPTION_IN_GRACE_PERIOD
         * 7: SUBSCRIPTION_RESTARTED
         * 8: SUBSCRIPTION_PRICE_CHANGE_CONFIRMED
         * 9: SUBSCRIPTION_DEFERRED
         * 10: SUBSCRIPTION_PAUSED
         * 11: SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED
         * 12: SUBSCRIPTION_REVOKED
         * 13: SUBSCRIPTION_EXPIRED
         */
        @JsonProperty("notificationType")
        private Integer notificationType;

        /**
         * Purchase token
         */
        @JsonProperty("purchaseToken")
        private String purchaseToken;

        /**
         * Subscription ID
         */
        @JsonProperty("subscriptionId")
        private String subscriptionId;
    }

    @Data
    public static class TestNotification {
        @JsonProperty("version")
        private String version;
    }
}
