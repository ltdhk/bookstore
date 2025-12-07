package com.bookstore.service.impl;

import com.bookstore.config.CacheConfig;
import com.bookstore.service.CacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import java.util.Objects;

/**
 * 缓存管理服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CacheServiceImpl implements CacheService {

    private final CacheManager cacheManager;

    @Override
    public void evictAllBookCaches() {
        log.info("清除所有书籍相关缓存");
        evictCache(CacheConfig.CACHE_HOME_BOOKS);
        evictCache(CacheConfig.CACHE_BOOK_DETAILS);
        evictCache(CacheConfig.CACHE_CHAPTERS);
        evictCache(CacheConfig.CACHE_CHAPTER_CONTENT);
        evictCache(CacheConfig.CACHE_READER_DATA);
    }

    @Override
    public void evictBookCache(Long bookId) {
        log.info("清除书籍缓存, bookId={}", bookId);
        // 清除书籍详情缓存
        evictCacheKey(CacheConfig.CACHE_BOOK_DETAILS, bookId);
        // 清除该书籍的章节缓存
        evictCacheKey(CacheConfig.CACHE_CHAPTERS, bookId);
        // 清除 readerData 缓存 (key 格式可能是 bookId 或 bookId_userId)
        evictCache(CacheConfig.CACHE_READER_DATA);
        // 清除首页缓存（因为书籍可能出现在首页列表中）
        evictCache(CacheConfig.CACHE_HOME_BOOKS);
    }

    @Override
    public void evictChapterCache(Long bookId) {
        log.info("清除章节列表缓存, bookId={}", bookId);
        evictCacheKey(CacheConfig.CACHE_CHAPTERS, bookId);
        // 同时清除 readerData 缓存
        evictCache(CacheConfig.CACHE_READER_DATA);
    }

    @Override
    public void evictChapterContentCache(Long chapterId) {
        log.info("清除章节内容缓存, chapterId={}", chapterId);
        evictCacheKey(CacheConfig.CACHE_CHAPTER_CONTENT, chapterId);
        // 同时清除 readerData 缓存
        evictCache(CacheConfig.CACHE_READER_DATA);
    }

    @Override
    public void evictHomeBooksCache() {
        log.info("清除首页书籍列表缓存");
        evictCache(CacheConfig.CACHE_HOME_BOOKS);
    }

    /**
     * 清除整个缓存
     */
    private void evictCache(String cacheName) {
        var cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.clear();
        }
    }

    /**
     * 清除指定 key 的缓存
     */
    private void evictCacheKey(String cacheName, Object key) {
        var cache = cacheManager.getCache(cacheName);
        if (cache != null) {
            cache.evict(key);
        }
    }
}
