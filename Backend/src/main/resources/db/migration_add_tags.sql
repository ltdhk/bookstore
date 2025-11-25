-- Migration: Create tags and book_tags tables with language support
-- Date: 2025-11-23

USE bookstore_db;

-- Create tags table if not exists
CREATE TABLE IF NOT EXISTS `tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'Tag Name',
  `language` varchar(10) NOT NULL DEFAULT 'zh' COMMENT 'Language Code',
  `color` varchar(20) DEFAULT '#1890ff' COMMENT 'Tag Color',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Is Active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_language` (`name`, `language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tag Table';

-- Insert default tags for Chinese (only if not exists)
INSERT IGNORE INTO `tags` (`name`, `language`, `color`, `sort_order`) VALUES
('热门', 'zh', '#ff4d4f', 1),
('新书', 'zh', '#52c41a', 2),
('精选', 'zh', '#1890ff', 3),
('完结', 'zh', '#722ed1', 4),
('连载中', 'zh', '#faad14', 5);

-- Insert default tags for English (only if not exists)
INSERT IGNORE INTO `tags` (`name`, `language`, `color`, `sort_order`) VALUES
('Hot', 'en', '#ff4d4f', 1),
('New', 'en', '#52c41a', 2),
('Featured', 'en', '#1890ff', 3),
('Completed', 'en', '#722ed1', 4),
('Ongoing', 'en', '#faad14', 5);

-- Create book_tags table if not exists
CREATE TABLE IF NOT EXISTS `book_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `tag_id` bigint(20) NOT NULL COMMENT 'Tag ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_book_tag` (`book_id`, `tag_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book-Tag Relation Table';
