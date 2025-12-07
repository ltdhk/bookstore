package com.bookstore.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.util.concurrent.TimeUnit;

/**
 * Caffeine 本地缓存配置
 *
 * 缓存策略:
 * - homeBooks: 首页书籍列表，TTL 5分钟，最大500条
 * - bookDetails: 书籍详情，TTL 10分钟，最大1000条
 * - chapters: 章节列表，TTL 10分钟，最大500条
 * - chapterContent: 章节内容，TTL 30分钟，最大200条
 */
@Configuration
@EnableCaching
public class CacheConfig {

    public static final String CACHE_HOME_BOOKS = "homeBooks";
    public static final String CACHE_BOOK_DETAILS = "bookDetails";
    public static final String CACHE_CHAPTERS = "chapters";
    public static final String CACHE_CHAPTER_CONTENT = "chapterContent";
    public static final String CACHE_READER_DATA = "readerData";

    @Bean
    @Primary
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeine(defaultCaffeine());
        cacheManager.setCacheNames(java.util.List.of(
            CACHE_HOME_BOOKS,
            CACHE_BOOK_DETAILS,
            CACHE_CHAPTERS,
            CACHE_CHAPTER_CONTENT,
            CACHE_READER_DATA
        ));
        return cacheManager;
    }

    /**
     * 首页书籍列表缓存 - 短TTL，更新频繁
     */
    @Bean
    public Caffeine<Object, Object> homeBooksCaffeine() {
        return Caffeine.newBuilder()
                .expireAfterWrite(5, TimeUnit.MINUTES)
                .maximumSize(500)
                .recordStats();
    }

    /**
     * 书籍详情缓存 - 中等TTL
     */
    @Bean
    public Caffeine<Object, Object> bookDetailsCaffeine() {
        return Caffeine.newBuilder()
                .expireAfterWrite(10, TimeUnit.MINUTES)
                .maximumSize(1000)
                .recordStats();
    }

    /**
     * 章节列表缓存
     */
    @Bean
    public Caffeine<Object, Object> chaptersCaffeine() {
        return Caffeine.newBuilder()
                .expireAfterWrite(10, TimeUnit.MINUTES)
                .maximumSize(500)
                .recordStats();
    }

    /**
     * 章节内容缓存 - 较长TTL，内容不常变
     */
    @Bean
    public Caffeine<Object, Object> chapterContentCaffeine() {
        return Caffeine.newBuilder()
                .expireAfterWrite(30, TimeUnit.MINUTES)
                .maximumSize(200)
                .recordStats();
    }

    /**
     * 默认缓存配置
     */
    private Caffeine<Object, Object> defaultCaffeine() {
        return Caffeine.newBuilder()
                .expireAfterWrite(10, TimeUnit.MINUTES)
                .maximumSize(500)
                .recordStats();
    }
}
