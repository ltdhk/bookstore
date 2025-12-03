package com.bookstore.dto;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 批量上传结果 DTO
 * 用于返回批量上传的结果统计
 */
@Data
public class BatchUploadResultDTO {

    /**
     * 批次ID
     */
    private String batchId;

    /**
     * 总文件数
     */
    private Integer totalFiles;

    /**
     * 成功数量
     */
    private Integer successCount;

    /**
     * 失败数量
     */
    private Integer failureCount;

    /**
     * 上传成功的封面列表
     */
    private List<CoverImageDTO> uploadedImages = new ArrayList<>();

    /**
     * 错误信息列表
     */
    private List<String> errors = new ArrayList<>();
}
