package com.bookstore.config;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.AndroidPublisherScopes;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;

/**
 * Google API Configuration
 * Configures AndroidPublisher for Google Play receipt verification
 */
@Slf4j
@Configuration
public class GoogleApiConfig {

    @Value("${iap.google.service-account-file}")
    private Resource serviceAccountFile;

    @Value("${iap.google.package-name}")
    private String packageName;

    /**
     * Create AndroidPublisher bean for Google Play API calls
     */
    @Bean
    public AndroidPublisher androidPublisher() {
        try {
            log.info("Initializing Google AndroidPublisher with package name: {}", packageName);

            // Load service account credentials
            GoogleCredentials credentials = GoogleCredentials
                .fromStream(serviceAccountFile.getInputStream())
                .createScoped(Collections.singleton(AndroidPublisherScopes.ANDROIDPUBLISHER));

            // Build AndroidPublisher
            AndroidPublisher publisher = new AndroidPublisher.Builder(
                GoogleNetHttpTransport.newTrustedTransport(),
                JacksonFactory.getDefaultInstance(),
                new HttpCredentialsAdapter(credentials)
            )
            .setApplicationName(packageName)
            .build();

            log.info("AndroidPublisher initialized successfully");
            return publisher;

        } catch (IOException e) {
            log.error("Failed to load Google service account file", e);
            throw new RuntimeException("Failed to initialize Google API: " + e.getMessage(), e);
        } catch (GeneralSecurityException e) {
            log.error("Security exception while initializing Google API", e);
            throw new RuntimeException("Failed to initialize Google API: " + e.getMessage(), e);
        }
    }
}
