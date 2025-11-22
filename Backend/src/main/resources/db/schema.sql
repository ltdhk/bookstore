CREATE DATABASE IF NOT EXISTS bookstore_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE bookstore_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Username',
  `password` varchar(100) NOT NULL COMMENT 'Password',
  `nickname` varchar(50) DEFAULT NULL COMMENT 'Nickname',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Avatar URL',
  `coins` int(11) DEFAULT 0 COMMENT 'Coins',
  `bonus` int(11) DEFAULT 0 COMMENT 'Bonus Coins',
  `is_svip` tinyint(1) DEFAULT 0 COMMENT 'Is SVIP',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='User Table';

-- ----------------------------
-- Table structure for books
-- ----------------------------
DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL COMMENT 'Book Title',
  `author` varchar(50) NOT NULL COMMENT 'Author',
  `cover_url` varchar(255) DEFAULT NULL COMMENT 'Cover URL',
  `description` text COMMENT 'Description',
  `category` varchar(50) DEFAULT NULL COMMENT 'Category',
  `status` varchar(20) DEFAULT 'Ongoing' COMMENT 'Status: Ongoing/Completed',
  `views` bigint(20) DEFAULT 0 COMMENT 'View Count',
  `rating` decimal(3,1) DEFAULT 0.0 COMMENT 'Rating',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Book Table';

-- ----------------------------
-- Table structure for chapters
-- ----------------------------
DROP TABLE IF EXISTS `chapters`;
CREATE TABLE `chapters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `book_id` bigint(20) NOT NULL COMMENT 'Book ID',
  `title` varchar(100) NOT NULL COMMENT 'Chapter Title',
  `content` longtext COMMENT 'Chapter Content',
  `order_num` int(11) NOT NULL COMMENT 'Order Number',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` tinyint(1) DEFAULT 0,
  `language` varchar(10) NOT NULL COMMENT 'Language',
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
  `income` decimal(10,2) DEFAULT 0.00 COMMENT 'Total Income',
  `status` int(11) DEFAULT 1 COMMENT 'Status: 1:Active, 0:Disabled',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dist_code` (`code`)
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
