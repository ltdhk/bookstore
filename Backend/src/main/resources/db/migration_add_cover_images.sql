-- 封面图片管理表
-- 用于独立管理书籍封面，支持批量上传和使用状态追踪

CREATE TABLE IF NOT EXISTS `cover_images` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `file_name` VARCHAR(255) NOT NULL COMMENT '原始文件名',
  `file_url` VARCHAR(500) NOT NULL COMMENT 'S3 完整 URL',
  `s3_key` VARCHAR(500) NOT NULL COMMENT 'S3 对象键（用于删除）',
  `file_size` BIGINT(20) DEFAULT 0 COMMENT '文件大小（字节）',
  `width` INT(11) DEFAULT NULL COMMENT '图片宽度（像素）',
  `height` INT(11) DEFAULT NULL COMMENT '图片高度（像素）',
  `mime_type` VARCHAR(50) DEFAULT NULL COMMENT 'MIME 类型（如 image/jpeg）',
  `upload_source` VARCHAR(20) DEFAULT 'single' COMMENT '上传方式：single-单个上传, batch-批量上传',
  `batch_id` VARCHAR(50) DEFAULT NULL COMMENT '批次ID（批量上传时使用）',
  `is_used` TINYINT(1) DEFAULT 0 COMMENT '是否已被使用：0-未使用, 1-已使用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT(1) DEFAULT 0 COMMENT '软删除标记：0-未删除, 1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_file_url` (`file_url`(255)) COMMENT '文件URL唯一索引',
  INDEX `idx_batch_id` (`batch_id`) COMMENT '批次ID索引',
  INDEX `idx_is_used` (`is_used`) COMMENT '使用状态索引',
  INDEX `idx_created_at` (`created_at`) COMMENT '创建时间索引',
  INDEX `idx_deleted` (`deleted`) COMMENT '软删除索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='封面图片表';
