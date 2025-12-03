package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 封面图片实体类
 * 用于独立管理书籍封面，支持批量上传和使用状态追踪
 */
@Data
@TableName("cover_images")
public class CoverImage {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 原始文件名
     */
    private String fileName;

    /**
     * S3 完整 URL
     */
    private String fileUrl;

    /**
     * S3 对象键（用于删除文件）
     */
    private String s3Key;

    /**
     * 文件大小（字节）
     */
    private Long fileSize;

    /**
     * 图片宽度（像素）
     */
    private Integer width;

    /**
     * 图片高度（像素）
     */
    private Integer height;

    /**
     * MIME 类型（如 image/jpeg）
     */
    private String mimeType;

    /**
     * 上传方式：single-单个上传, batch-批量上传
     */
    private String uploadSource;

    /**
     * 批次ID（批量上传时使用）
     */
    private String batchId;

    /**
     * 是否已被使用：0-未使用, 1-已使用
     */
    private Boolean isUsed;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    /**
     * 软删除标记：0-未删除, 1-已删除
     */
    @TableLogic
    private Integer deleted;
}
