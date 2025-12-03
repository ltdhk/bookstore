-- Migration: Add In-App Purchase tables and update subscription products
-- Date: 2025-01-03
-- Description: Creates subscription_events table, updates subscription products with new pricing
-- Note: Commission calculation is done dynamically based on order data, no separate commission table needed

-- Create subscription_events table (订阅事件日志)
CREATE TABLE IF NOT EXISTS `subscription_events` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `order_id` bigint(20) DEFAULT NULL COMMENT '订单ID',
  `event_type` varchar(50) NOT NULL COMMENT '事件类型: purchased/renewed/cancelled/expired/refunded',
  `platform` varchar(20) NOT NULL COMMENT '平台: AppStore/GooglePay',
  `original_transaction_id` varchar(255) NOT NULL COMMENT '原始交易ID',
  `event_date` datetime NOT NULL COMMENT '事件发生时间',
  `notification_data` text COMMENT '原始通知数据',
  `processed` tinyint(1) DEFAULT 0 COMMENT '是否已处理',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_original_transaction_id` (`original_transaction_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_processed` (`processed`),
  KEY `idx_event_date` (`event_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订阅事件日志表';

-- Update subscription products with new pricing and product IDs
-- Weekly plan: $19.9/week
UPDATE `subscription_products`
SET
  `price` = 19.90,
  `duration_days` = 7,
  `apple_product_id` = 'com.novel.pop.weekly',
  `google_product_id` = 'novelpop_weekly'
WHERE `plan_type` = 'weekly';

-- If weekly plan doesn't exist, insert it
INSERT INTO `subscription_products`
  (`product_id`, `product_name`, `plan_type`, `duration_days`, `price`, `currency`, `platform`,
   `apple_product_id`, `google_product_id`, `is_active`, `sort_order`, `description`, `features`)
SELECT
  'weekly_subscription',
  'Weekly SVIP',
  'weekly',
  7,
  19.90,
  'USD',
  'All',
  'com.novel.pop.weekly',
  'novelpop_weekly',
  1,
  1,
  'Weekly subscription with auto-renewal',
  '["Unlimited reading", "Ad-free experience", "Priority support", "Early access to new books"]'
WHERE NOT EXISTS (SELECT 1 FROM `subscription_products` WHERE `plan_type` = 'weekly');

-- Monthly plan: $49.99/month
UPDATE `subscription_products`
SET
  `price` = 49.99,
  `duration_days` = 30,
  `apple_product_id` = 'com.novel.pop.monthly',
  `google_product_id` = 'novelpop_monthly'
WHERE `plan_type` = 'monthly';

-- Yearly plan: $269.99/year
UPDATE `subscription_products`
SET
  `price` = 269.99,
  `duration_days` = 365,
  `apple_product_id` = 'com.novel.pop.yearly',
  `google_product_id` = 'novelpop_yearly'
WHERE `plan_type` = 'yearly';

-- Delete quarterly plan if it exists (replaced by weekly)
DELETE FROM `subscription_products` WHERE `plan_type` = 'quarterly';
