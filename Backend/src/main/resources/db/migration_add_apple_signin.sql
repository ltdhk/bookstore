-- Migration: Add Apple Sign In support
-- Date: 2024

-- Add apple_user_id column to users table for Apple Sign In
ALTER TABLE `users`
ADD COLUMN `apple_user_id` varchar(255) DEFAULT NULL COMMENT 'Apple User ID (sub claim from identity token)';

-- Add unique index for apple_user_id (allows NULL, only enforces uniqueness for non-NULL values)
ALTER TABLE `users`
ADD UNIQUE KEY `uk_apple_user_id` (`apple_user_id`);
