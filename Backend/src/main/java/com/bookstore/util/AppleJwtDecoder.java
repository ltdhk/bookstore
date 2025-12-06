package com.bookstore.util;

import com.bookstore.dto.AppleNotificationV2Payload;
import com.bookstore.dto.AppleTransactionInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbusds.jwt.SignedJWT;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Base64;

/**
 * Utility class for decoding Apple App Store Server Notification V2 JWTs
 *
 * Apple sends notifications as nested JWTs:
 * 1. Outer signedPayload - contains notification metadata
 * 2. Inner signedTransactionInfo - contains transaction details
 * 3. Inner signedRenewalInfo - contains renewal details (optional)
 */
@Slf4j
@Component
public class AppleJwtDecoder {

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Decode the outer signedPayload JWT to get notification metadata
     *
     * Note: We're NOT verifying the signature for simplicity.
     * In production, you should verify using Apple's public key.
     *
     * @param signedPayload JWT string
     * @return Decoded notification payload
     */
    public AppleNotificationV2Payload decodeNotificationPayload(String signedPayload) {
        try {
            // Parse the JWT without verification (for now)
            SignedJWT signedJWT = SignedJWT.parse(signedPayload);

            // Get the payload (claims)
            String payloadJson = signedJWT.getPayload().toString();

            log.debug("Decoded notification payload: {}", payloadJson);

            // Parse JSON to DTO
            return objectMapper.readValue(payloadJson, AppleNotificationV2Payload.class);

        } catch (Exception e) {
            log.error("Failed to decode Apple notification payload", e);
            throw new RuntimeException("Failed to decode notification payload", e);
        }
    }

    /**
     * Decode the signedTransactionInfo JWT to get transaction details
     *
     * @param signedTransactionInfo JWT string from notification.data.signedTransactionInfo
     * @return Decoded transaction info
     */
    public AppleTransactionInfo decodeTransactionInfo(String signedTransactionInfo) {
        try {
            // Parse the JWT without verification
            SignedJWT signedJWT = SignedJWT.parse(signedTransactionInfo);

            // Get the payload (claims)
            String payloadJson = signedJWT.getPayload().toString();

            log.debug("Decoded transaction info: {}", payloadJson);

            // Parse JSON to DTO
            return objectMapper.readValue(payloadJson, AppleTransactionInfo.class);

        } catch (Exception e) {
            log.error("Failed to decode Apple transaction info", e);
            throw new RuntimeException("Failed to decode transaction info", e);
        }
    }

}
