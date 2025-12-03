-- Migration: Add completion_status field to books table
-- Date: 2025-11-23

USE bookstore_db;

-- Add completion_status field to books table
ALTER TABLE `books`
ADD COLUMN `completion_status` varchar(20) DEFAULT 'completed' COMMENT 'Completion Status: ongoing, completed' AFTER `status`;
