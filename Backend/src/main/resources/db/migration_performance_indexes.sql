-- Performance optimization indexes for books table
-- Run this migration to improve query performance

-- 首页查询优化索引
-- Used by: getHomeBooks - hot books query
ALTER TABLE books ADD INDEX idx_is_hot_status_lang (is_hot, status, language);

-- Used by: getHomeBooks - new books query
ALTER TABLE books ADD INDEX idx_status_language (status, language);

-- Used by: getHomeBooks - category query
ALTER TABLE books ADD INDEX idx_category_status_lang (category_id, status, language);

-- Used by: getHomeBooks - order by created_at
ALTER TABLE books ADD INDEX idx_created_status (created_at DESC, status);

-- 搜索优化索引
-- Used by: searchBooks - title search
ALTER TABLE books ADD INDEX idx_title (title(100));

-- Used by: searchBooks - author search
ALTER TABLE books ADD INDEX idx_author (author(100));

-- Note: Run these commands one by one in production to avoid long table locks
-- For large tables, consider using pt-online-schema-change or gh-ost
