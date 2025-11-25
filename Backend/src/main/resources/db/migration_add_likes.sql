-- Migration: Add likes column to books table
-- Date: 2025-11-23

USE bookstore_db;

-- Check if column exists and add if not
ALTER TABLE `books`
ADD COLUMN IF NOT EXISTS `likes` bigint(20) DEFAULT 0 COMMENT 'Like Count' AFTER `views`;
