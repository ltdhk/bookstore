package com.bookstore.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Data
@Configuration
@ConfigurationProperties(prefix = "book-import")
public class BookImportConfig {
    private Integer maxBooksPerBatch = 50;
    private Integer maxChaptersPerBook = 500;
    private Long maxCoverSize = 5 * 1024 * 1024L; // 5MB in bytes
    private String tempDir = System.getProperty("java.io.tmpdir") + "/book-import";
    private List<String> supportedImageFormats = List.of("jpg", "jpeg", "png", "gif", "webp");
}
