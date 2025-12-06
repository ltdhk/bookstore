-- Migration: Add processed_at column to subscription_events table
-- Date: 2025-12-06
-- Description: Adds the missing processed_at column for tracking when events were processed

ALTER TABLE `subscription_events`
ADD COLUMN `processed_at` datetime DEFAULT NULL COMMENT '处理时间' AFTER `processed`;
