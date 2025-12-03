-- Migration: Optimize orders table for commission calculation
-- Date: 2025-01-03
-- Description: Add verified_at field and additional indexes for commission calculation
-- Note: Most fields already exist in schema.sql, only adding missing ones

-- Add verified_at field (this is the only new field not in schema.sql)
ALTER TABLE `orders`
ADD COLUMN `verified_at` datetime DEFAULT NULL COMMENT '验证时间' AFTER `receipt_data`;

-- Add additional indexes for better query performance
-- Note: idx_distributor_id and idx_source_passcode_id already exist in schema.sql
ALTER TABLE `orders`
ADD INDEX `idx_user_id_status` (`user_id`, `status`),
ADD INDEX `idx_create_time` (`create_time`),
ADD INDEX `idx_verified_at` (`verified_at`);

-- Update existing orders to set default values
UPDATE `orders` SET `source_entry` = 'unknown' WHERE `source_entry` IS NULL AND `source_entry` IS NOT NULL;

-- Add comment to clarify commission calculation approach
ALTER TABLE `orders` COMMENT = 'Order Table - Commission is calculated dynamically: amount * 0.30 for orders with distributor_id';
