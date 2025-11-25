package com.bookstore.service.impl;

import com.bookstore.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileUploadServiceImpl implements FileUploadService {

    private final S3Client s3Client;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.region}")
    private String region;

    @Override
    public String uploadFile(MultipartFile file, String folder) throws Exception {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        // 获取原始文件名和扩展名
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        // 生成唯一文件名
        String fileName = folder + "/" + UUID.randomUUID().toString() + extension;

        try {
            // 上传到S3
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(file.getContentType())
                    .acl(ObjectCannedACL.PUBLIC_READ) // 设置为公开读取
                    .build();

            s3Client.putObject(putObjectRequest, RequestBody.fromBytes(file.getBytes()));

            // 返回文件的公开URL
            return String.format("https://%s.s3.%s.amazonaws.com/%s", bucketName, region, fileName);
        } catch (IOException e) {
            throw new Exception("文件上传失败: " + e.getMessage());
        }
    }

    @Override
    public void deleteFile(String fileUrl) throws Exception {
        try {
            // 从URL中提取文件key
            // URL格式: https://bucket-name.s3.region.amazonaws.com/folder/filename.ext
            String key = fileUrl.substring(fileUrl.indexOf(".com/") + 5);

            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build();

            s3Client.deleteObject(deleteObjectRequest);
        } catch (Exception e) {
            throw new Exception("文件删除失败: " + e.getMessage());
        }
    }
}
