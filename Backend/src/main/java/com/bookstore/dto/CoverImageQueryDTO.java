package com.bookstore.dto;

import lombok.Data;

/**
 * 封面图片查询 DTO
 * 用于分页和筛选查询
 */
@Data
public class CoverImageQueryDTO {

    /**
     * 页码（从1开始）
     */
    private Integer page = 1;

    /**
     * 每页数量
     */
    private Integer size = 20;

    /**
     * 是否已使用（null = 全部, true = 已使用, false = 未使用）
     */
    private Boolean isUsed;

    /**
     * 上传方式（null = 全部, "single" 或 "batch"）
     */
    private String uploadSource;

    /**
     * 关键词（搜索文件名）
     */
    private String keyword;
}
