package com.bookstore.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "google.signin")
public class GoogleSignInConfig {
    private String webClientId;
    private String androidClientId;
    private String iosClientId;
}
