-- Migration: Add username and password fields to distributors table
-- Date: 2025-11-23

USE bookstore_db;

-- Add username and password fields to distributors table
ALTER TABLE `distributors`
ADD COLUMN `username` varchar(50) NOT NULL COMMENT 'Username for login' AFTER `code`,
ADD COLUMN `password` varchar(100) NOT NULL COMMENT 'Password for login' AFTER `username`;

-- Add unique constraint for username
ALTER TABLE `distributors`
ADD UNIQUE KEY `uk_dist_username` (`username`);
