package com.bookstore.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * Apple App Store Server Notification V2 (JWT signed format)
 * https://developer.apple.com/documentation/appstoreservernotifications/responsebodyv2
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AppleServerNotificationV2 {

    /**
     * A cryptographically signed payload, in JSON Web Signature (JWS) format,
     * containing the response body for a version 2 server notification.
     */
    @JsonProperty("signedPayload")
    private String signedPayload;
}
