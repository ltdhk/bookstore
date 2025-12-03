-- Add Google Sign In support to users table
-- This migration adds google_user_id field to enable Google authentication

-- Add google_user_id column
ALTER TABLE `users`
ADD COLUMN `google_user_id` varchar(255) DEFAULT NULL COMMENT 'Google User ID (sub claim from ID token)';

-- Add unique index for google_user_id to prevent duplicate Google accounts
ALTER TABLE `users`
ADD UNIQUE KEY `uk_google_user_id` (`google_user_id`);
