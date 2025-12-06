-- Create table to track processed platform transaction IDs
-- This prevents duplicate processing without creating duplicate orders
CREATE TABLE IF NOT EXISTS processed_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    platform_transaction_id VARCHAR(255) NOT NULL UNIQUE,
    original_transaction_id VARCHAR(255) NOT NULL,
    order_id BIGINT NULL,
    platform VARCHAR(20) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    processed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_platform_transaction_id (platform_transaction_id),
    INDEX idx_original_transaction_id (original_transaction_id),
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks processed platform transaction IDs to prevent duplicates';
