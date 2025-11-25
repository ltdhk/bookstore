package com.bookstore.service;

import org.springframework.web.multipart.MultipartFile;

public interface FileUploadService {
    /**
     * 上传文件到S3
     * @param file 文件
     * @param folder 文件夹名称（如: covers, avatars等）
     * @return 文件的公开访问URL
     */
    String uploadFile(MultipartFile file, String folder) throws Exception;

    /**
     * 删除S3上的文件
     * @param fileUrl 文件URL
     */
    void deleteFile(String fileUrl) throws Exception;
}
