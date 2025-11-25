CREATE DATABASE IF NOT EXISTS bookstore_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE bookstore_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for languages
-- ----------------------------
DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL COMMENT 'Language Code (e.g., zh, en)',
  `name` varchar(50) NOT NULL COMMENT 'Language Name',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Is Active',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Language Configuration Table';

-- Initialize default languages
INSERT INTO `languages` (`code`, `name`, `is_active`, `sort_order`) VALUES
('zh', '中文', 1, 1),
('en', 'English', 1, 2);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `nickname` varchar(50) DEFAULT NULL COMMENT 'Nickname',
  `email` varchar(100) DEFAULT NULL COMMENT 'Email',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Phone Number',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar URL',
  `coins` int(11) DEFAULT 0 COMMENT 'Coins',
  `bonus` int(11) DEFAULT 0 COMMENT 'Bonus Coins',
  `is_svip` tinyint(1) DEFAULT 0 COMMENT 'Is SVIP',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='User Table';

-- ----------------------------
-- Table structure for book_categories
-- ----------------------------
DROP TABLE IF EXISTS `book_categories`;
CREATE TABLE `book_categories` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT 'Category Name',
  `language` varchar(10) NOT NULL DEFAULT 'zh' COMMENT 'Language Code',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book Category Table';

-- ----------------------------
-- Table structure for books
-- ----------------------------
DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL COMMENT 'Book Title',
  `author` varchar(100) DEFAULT NULL,
  `cover_url` varchar(255) DEFAULT NULL,
  `description` text,
  `category_id` bigint(20) DEFAULT NULL COMMENT 'Category ID',
  `status` varchar(20) DEFAULT 'published' COMMENT 'Status: draft, published, archived',
  `completion_status` varchar(20) DEFAULT 'completed' COMMENT 'Completion Status: ongoing, completed',
  `views` bigint(20) DEFAULT 0 COMMENT 'View Count',
  `likes` bigint(20) DEFAULT 0 COMMENT 'Like Count',
  `rating` decimal(3,2) DEFAULT 0.00,
  `language` varchar(50) DEFAULT 'zh' COMMENT 'Language',
  `requires_membership` tinyint(1) DEFAULT 0 COMMENT 'Requires Membership',
  `is_recommended` tinyint(1) DEFAULT 0 COMMENT 'Is Recommended',
  `is_hot` tinyint(1) DEFAULT 0 COMMENT 'Is Hot',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book Table';

----------------------------
Table structure for chapters
----------------------------
DROP TABLE IF EXISTS `chapters`;
CREATE TABLE `chapters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `title` varchar(100) NOT NULL COMMENT 'Chapter Title',
  `content` longtext COMMENT 'Chapter Content',
  `is_free` tinyint(1) DEFAULT 1 COMMENT 'Is free',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `order_num` int(11) DEFAULT 0 COMMENT 'Order Number',
  PRIMARY KEY (`id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Chapter Table';

-- ----------------------------
-- Table structure for bookshelf
-- ----------------------------
DROP TABLE IF EXISTS `bookshelf`;
CREATE TABLE `bookshelf` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT 'User ID',
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `last_read_chapter_id` bigint(20) DEFAULT NULL COMMENT 'Last Read Chapter ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_book` (`user_id`,`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Bookshelf Table';

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Table structure for admin_users
-- ----------------------------
DROP TABLE IF EXISTS `admin_users`;
CREATE TABLE `admin_users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `email` varchar(100) DEFAULT NULL COMMENT 'Email',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar',
  `status` int(11) DEFAULT 1 COMMENT 'Status: 1:Active, 0:Disabled',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Admin User Table';

-- ----------------------------
-- Table structure for distributors
-- ----------------------------
DROP TABLE IF EXISTS `distributors`;
CREATE TABLE `distributors` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Distributor Name',
  `contact` varchar(100) DEFAULT NULL COMMENT 'Contact Info',
  `code` varchar(50) NOT NULL COMMENT 'Distribution Code',
  `username` varchar(50) NOT NULL COMMENT 'Username for login',
  `password` varchar(100) NOT NULL COMMENT 'Password for login',
  `income` decimal(10,2) DEFAULT 0.00 COMMENT 'Total Income',
  `status` int(11) DEFAULT 1 COMMENT 'Status: 1:Active, 0:Disabled',
  `commission_rate` decimal(5,2) DEFAULT 30.00 COMMENT 'Subscription Commission Rate (0-100)',
  `coins_commission_rate` decimal(5,2) DEFAULT 30.00 COMMENT 'Coins Recharge Commission Rate (0-100)',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dist_code` (`code`),
  UNIQUE KEY `uk_dist_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Distributor Table';

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) NOT NULL COMMENT 'Config Key',
  `config_value` text COMMENT 'Config Value',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='System Config Table';

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT 'User ID',
  `order_no` varchar(100) NOT NULL COMMENT 'Order Number',
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount',
  `status` varchar(20) NOT NULL COMMENT 'Status: Pending/Paid/Refunded',
  `platform` varchar(20) DEFAULT NULL COMMENT 'Platform: AppStore/GooglePay',
  `product_id` varchar(100) DEFAULT NULL COMMENT 'Product ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Order Table';

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
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

-- Insert default tags for Chinese
INSERT INTO `tags` (`name`, `language`, `color`, `sort_order`) VALUES
('热门', 'zh', '#ff4d4f', 1),
('新书', 'zh', '#52c41a', 2),
('精选', 'zh', '#1890ff', 3),
('完结', 'zh', '#722ed1', 4),
('连载中', 'zh', '#faad14', 5);

-- Insert default tags for English
INSERT INTO `tags` (`name`, `language`, `color`, `sort_order`) VALUES
('Romantic', 'en', '#ff4d4f', 1),
('Realistic', 'en', '#52c41a', 2),
('Fantasy', 'en', '#1890ff', 3),
('Suspense', 'en', '#722ed1', 4),
('Ongoing', 'en', '#faad14', 5);

-- ----------------------------
-- Table structure for book_tags
-- ----------------------------
DROP TABLE IF EXISTS `book_tags`;
CREATE TABLE `book_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `tag_id` bigint(20) NOT NULL COMMENT 'Tag ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_book_tag` (`book_id`, `tag_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book-Tag Relation Table';

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `admin_id` bigint(20) DEFAULT NULL COMMENT 'Admin ID',
  `username` varchar(50) DEFAULT NULL COMMENT 'Admin Username',
  `action` varchar(50) DEFAULT NULL COMMENT 'Action Type',
  `target` varchar(255) DEFAULT NULL COMMENT 'Target Object',
  `params` text COMMENT 'Request Params',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP Address',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Operation Log Table';

-- ----------------------------
-- Table structure for book_passcodes
-- ----------------------------
DROP TABLE IF EXISTS `book_passcodes`;
CREATE TABLE `book_passcodes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `distributor_id` bigint(20) NOT NULL COMMENT 'Distributor ID',
  `passcode` varchar(50) NOT NULL COMMENT 'Passcode (Unique)',
  `name` varchar(100) DEFAULT NULL COMMENT 'Passcode Name/Description',
  `max_usage` int(11) DEFAULT NULL COMMENT 'Max Usage Count (NULL = Unlimited)',
  `used_count` int(11) DEFAULT 0 COMMENT 'Used Count',
  `view_count` bigint(20) DEFAULT 0 COMMENT 'View Count via Passcode',
  `status` int(11) DEFAULT 1 COMMENT 'Status: 1-Active, 0-Disabled',
  `valid_from` datetime DEFAULT NULL COMMENT 'Valid From',
  `valid_to` datetime DEFAULT NULL COMMENT 'Valid To',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0 COMMENT 'Soft Delete Flag',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_passcode` (`passcode`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_distributor_id` (`distributor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book Passcode Table';

-- ----------------------------
-- Table structure for passcode_usage_logs
-- ----------------------------
DROP TABLE IF EXISTS `passcode_usage_logs`;
CREATE TABLE `passcode_usage_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `passcode_id` bigint(20) NOT NULL COMMENT 'Passcode ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT 'User ID',
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `distributor_id` bigint(20) NOT NULL COMMENT 'Distributor ID',
  `action_type` varchar(20) NOT NULL COMMENT 'Action Type: open-Open Book, view-View Chapter',
  `ip_address` varchar(50) DEFAULT NULL COMMENT 'IP Address',
  `device_info` varchar(255) DEFAULT NULL COMMENT 'Device Info',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_passcode_id` (`passcode_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_distributor_id` (`distributor_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Passcode Usage Log Table';

-- ----------------------------
-- Alter orders table to add distributor tracking
-- ----------------------------
ALTER TABLE `orders`
ADD COLUMN `distributor_id` bigint(20) DEFAULT NULL COMMENT 'Distributor ID (from passcode)' AFTER `user_id`,
ADD COLUMN `source_passcode_id` bigint(20) DEFAULT NULL COMMENT 'Source Passcode ID' AFTER `distributor_id`,
ADD KEY `idx_distributor_id` (`distributor_id`),
ADD KEY `idx_source_passcode_id` (`source_passcode_id`);

-- ----------------------------
-- Alter orders table to add subscription fields
-- ----------------------------
ALTER TABLE `orders`
ADD COLUMN `order_type` varchar(20) DEFAULT 'onetime' COMMENT 'Order Type: onetime, subscription' AFTER `product_id`,
ADD COLUMN `subscription_period` varchar(20) DEFAULT NULL COMMENT 'Subscription Period: monthly, quarterly, yearly' AFTER `order_type`,
ADD COLUMN `subscription_start_date` datetime DEFAULT NULL COMMENT 'Subscription Start Date' AFTER `subscription_period`,
ADD COLUMN `subscription_end_date` datetime DEFAULT NULL COMMENT 'Subscription End Date' AFTER `subscription_start_date`,
ADD COLUMN `is_auto_renew` tinyint(1) DEFAULT 1 COMMENT 'Auto Renew: 0-No, 1-Yes' AFTER `subscription_end_date`,
ADD COLUMN `cancel_date` datetime DEFAULT NULL COMMENT 'Cancel Date' AFTER `is_auto_renew`,
ADD COLUMN `cancel_reason` varchar(255) DEFAULT NULL COMMENT 'Cancel Reason' AFTER `cancel_date`,
ADD COLUMN `original_transaction_id` varchar(255) DEFAULT NULL COMMENT 'Original Transaction ID (Apple/Google)' AFTER `cancel_reason`,
ADD COLUMN `platform_transaction_id` varchar(255) DEFAULT NULL COMMENT 'Platform Transaction ID' AFTER `original_transaction_id`,
ADD COLUMN `purchase_token` text DEFAULT NULL COMMENT 'Purchase Token (Google)' AFTER `platform_transaction_id`,
ADD COLUMN `receipt_data` text DEFAULT NULL COMMENT 'Receipt Data (Apple)' AFTER `purchase_token`,
ADD COLUMN `source_book_id` bigint(20) DEFAULT NULL COMMENT 'Source Book ID (from which book)' AFTER `source_passcode_id`,
ADD COLUMN `source_entry` varchar(50) DEFAULT NULL COMMENT 'Source Entry: profile, reader' AFTER `source_book_id`,
ADD KEY `idx_order_type` (`order_type`),
ADD KEY `idx_subscription_end_date` (`subscription_end_date`),
ADD KEY `idx_original_transaction_id` (`original_transaction_id`),
ADD KEY `idx_source_book_id` (`source_book_id`);

-- ----------------------------
-- Alter users table to add subscription status
-- ----------------------------
ALTER TABLE `users`
ADD COLUMN `subscription_status` varchar(20) DEFAULT 'none' COMMENT 'Subscription Status: none, active, expired, cancelled' AFTER `is_svip`,
ADD COLUMN `subscription_end_date` datetime DEFAULT NULL COMMENT 'Subscription End Date' AFTER `subscription_status`,
ADD COLUMN `subscription_plan_type` varchar(20) DEFAULT NULL COMMENT 'Plan Type: monthly, quarterly, yearly' AFTER `subscription_end_date`,
ADD KEY `idx_subscription_status` (`subscription_status`),
ADD KEY `idx_subscription_end_date` (`subscription_end_date`);

-- ----------------------------
-- Table structure for subscription_products
-- ----------------------------
DROP TABLE IF EXISTS `subscription_products`;
CREATE TABLE `subscription_products` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` varchar(100) NOT NULL COMMENT 'Product ID (Unique)',
  `product_name` varchar(100) NOT NULL COMMENT 'Product Name',
  `plan_type` varchar(20) NOT NULL COMMENT 'Plan Type: monthly, quarterly, yearly',
  `duration_days` int(11) NOT NULL COMMENT 'Duration in Days',
  `price` decimal(10,2) NOT NULL COMMENT 'Price',
  `currency` varchar(10) DEFAULT 'USD' COMMENT 'Currency',
  `platform` varchar(20) NOT NULL COMMENT 'Platform: AppStore, GooglePay',
  `apple_product_id` varchar(100) DEFAULT NULL COMMENT 'Apple Product ID',
  `google_product_id` varchar(100) DEFAULT NULL COMMENT 'Google Product ID',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Is Active',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order',
  `description` text COMMENT 'Description',
  `features` text COMMENT 'Features (JSON)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_id` (`product_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_plan_type` (`plan_type`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Subscription Product Table';

-- Initialize subscription products
INSERT INTO `subscription_products`
(`product_id`, `product_name`, `plan_type`, `duration_days`, `price`, `currency`, `platform`, `apple_product_id`, `google_product_id`, `is_active`, `sort_order`, `description`, `features`)
VALUES
('svip_monthly_apple', 'SVIP Monthly', 'monthly', 30, 9.99, 'USD', 'AppStore', 'com.bookstore.svip.monthly', NULL, 1, 1, 'SVIP Membership - Monthly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content"]'),
('svip_monthly_google', 'SVIP Monthly', 'monthly', 30, 9.99, 'USD', 'GooglePay', NULL, 'com.bookstore.svip.monthly', 1, 1, 'SVIP Membership - Monthly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content"]'),
('svip_quarterly_apple', 'SVIP Quarterly', 'quarterly', 90, 24.99, 'USD', 'AppStore', 'com.bookstore.svip.quarterly', NULL, 1, 2, 'SVIP Membership - Quarterly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content", "Save 17%"]'),
('svip_quarterly_google', 'SVIP Quarterly', 'quarterly', 90, 24.99, 'USD', 'GooglePay', NULL, 'com.bookstore.svip.quarterly', 1, 2, 'SVIP Membership - Quarterly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content", "Save 17%"]'),
('svip_yearly_apple', 'SVIP Yearly', 'yearly', 365, 79.99, 'USD', 'AppStore', 'com.bookstore.svip.yearly', NULL, 1, 3, 'SVIP Membership - Yearly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content", "Save 33%"]'),
('svip_yearly_google', 'SVIP Yearly', 'yearly', 365, 79.99, 'USD', 'GooglePay', NULL, 'com.bookstore.svip.yearly', 1, 3, 'SVIP Membership - Yearly Plan', '["Unlimited reading", "Ad-free experience", "Early access to new releases", "Exclusive content", "Save 33%"]');

ALTER TABLE `distributors`
ADD COLUMN `commission_rate` decimal(5,2) DEFAULT 30.00 COMMENT 'Subscription Commission Rate (0-100)' AFTER `status`,
ADD COLUMN `coins_commission_rate` decimal(5,2) DEFAULT 30.00 COMMENT 'Coins Recharge Commission Rate (0-100)' AFTER `commission_rate`;

-- ----------------------------
-- Table structure for advertisements
-- ----------------------------
DROP TABLE IF EXISTS `advertisements`;
CREATE TABLE `advertisements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL COMMENT 'Advertisement Title',
  `image_url` varchar(255) NOT NULL COMMENT 'Advertisement Image URL',
  `target_type` varchar(20) NOT NULL DEFAULT 'book' COMMENT 'Target Type: book, url, none',
  `target_id` bigint(20) DEFAULT NULL COMMENT 'Target Book ID (if type is book)',
  `target_url` varchar(255) DEFAULT NULL COMMENT 'Target URL (if type is url)',
  `position` varchar(50) DEFAULT 'home_banner' COMMENT 'Position: home_banner, home_popup, etc.',
  `sort_order` int(11) DEFAULT 0 COMMENT 'Sort Order (smaller number shows first)',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Is Active: 0-No, 1-Yes',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_position` (`position`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_target_id` (`target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Advertisement Table';
