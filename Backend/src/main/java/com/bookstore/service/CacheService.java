package com.bookstore.service;

/**
 * 缓存管理服务接口
 * 用于在数据更新时清除相关缓存
 */
public interface CacheService {

    /**
     * 清除所有书籍相关缓存
     */
    void evictAllBookCaches();

    /**
     * 清除指定书籍的缓存
     */
    void evictBookCache(Long bookId);

    /**
     * 清除指定书籍的章节缓存
     */
    void evictChapterCache(Long bookId);

    /**
     * 清除指定章节内容缓存
     */
    void evictChapterContentCache(Long chapterId);

    /**
     * 清除首页书籍列表缓存
     */
    void evictHomeBooksCache();
}
