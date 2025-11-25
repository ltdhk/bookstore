-- Migration: Add email and phone fields to users table
-- Date: 2025-11-23

USE bookstore_db;

-- Add email and phone fields to users table
ALTER TABLE `users`
ADD COLUMN `email` varchar(100) DEFAULT NULL COMMENT 'Email' AFTER `nickname`,
ADD COLUMN `phone` varchar(20) DEFAULT NULL COMMENT 'Phone Number' AFTER `email`;

-- Add unique constraints for email and phone
ALTER TABLE `users`
ADD UNIQUE KEY `uk_email` (`email`),
ADD UNIQUE KEY `uk_phone` (`phone`);
