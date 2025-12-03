package com.bookstore.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 封面图片 DTO
 * 用于前端展示和数据传输
 */
@Data
public class CoverImageDTO {

    /**
     * 主键ID
     */
    private Long id;

    /**
     * 文件名
     */
    private String fileName;

    /**
     * S3 URL
     */
    private String fileUrl;

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
     * 上传方式：single 或 batch
     */
    private String uploadSource;

    /**
     * 批次ID
     */
    private String batchId;

    /**
     * 是否已使用
     */
    private Boolean isUsed;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
