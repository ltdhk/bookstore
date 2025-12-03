package com.bookstore.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "apple.signin")
public class AppleSignInConfig {
    /**
     * Apple Team ID (10-character string from Apple Developer Portal)
     */
    private String teamId;

    /**
     * Apple Key ID (10-character string from the key you created)
     */
    private String keyId;

    /**
     * Client ID - Bundle ID for iOS app
     */
    private String clientId;
}
