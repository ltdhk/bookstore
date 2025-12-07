package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.dto.BatchUploadResultDTO;
import com.bookstore.dto.CoverImageDTO;
import com.bookstore.dto.CoverImageQueryDTO;
import com.bookstore.entity.CoverImage;
import com.bookstore.repository.CoverImageMapper;
import com.bookstore.service.CoverImageService;
import com.bookstore.service.FileUploadService;
import com.bookstore.util.ZipExtractor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import org.springframework.beans.factory.annotation.Value;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.*;

/**
 * 封面图片服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CoverImageServiceImpl implements CoverImageService {

    private final CoverImageMapper coverImageMapper;
    private final FileUploadService fileUploadService;
    private final S3Client s3Client;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    @Value("${aws.s3.region}")
    private String region;

    /**
     * 分页查询封面列表
     */
    @Override
    public IPage<CoverImageDTO> listCovers(CoverImageQueryDTO query) {
        // 构建查询条件
        LambdaQueryWrapper<CoverImage> wrapper = new LambdaQueryWrapper<>();

        // 使用状态筛选
        if (query.getIsUsed() != null) {
            wrapper.eq(CoverImage::getIsUsed, query.getIsUsed());
        }

        // 上传方式筛选
        if (query.getUploadSource() != null && !query.getUploadSource().isEmpty()) {
            wrapper.eq(CoverImage::getUploadSource, query.getUploadSource());
        }

        // 关键词搜索（文件名）
        if (query.getKeyword() != null && !query.getKeyword().isEmpty()) {
            wrapper.like(CoverImage::getFileName, query.getKeyword());
        }

        // 按创建时间倒序排列
        wrapper.orderByDesc(CoverImage::getCreatedAt);

        // 分页查询
        Page<CoverImage> page = new Page<>(query.getPage(), query.getSize());
        IPage<CoverImage> result = coverImageMapper.selectPage(page, wrapper);

        // 转换为 DTO
        return result.convert(this::convertToDTO);
    }

    /**
     * 获取单个封面详情
     */
    @Override
    public CoverImageDTO getCover(Long id) {
        CoverImage coverImage = coverImageMapper.selectById(id);
        if (coverImage == null) {
            throw new RuntimeException("封面不存在");
        }
        return convertToDTO(coverImage);
    }

    /**
     * 上传单个封面
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public CoverImageDTO uploadSingle(MultipartFile file) throws Exception {
        // 验证文件
        validateImageFile(file);

        // 上传到 S3
        String fileUrl = fileUploadService.uploadFile(file, "covers");

        // 提取 S3 key
        String s3Key = extractS3Key(fileUrl);

        // 获取图片尺寸
        BufferedImage image = ImageIO.read(file.getInputStream());

        // 创建封面记录
        CoverImage coverImage = new CoverImage();
        coverImage.setFileName(file.getOriginalFilename());
        coverImage.setFileUrl(fileUrl);
        coverImage.setS3Key(s3Key);
        coverImage.setFileSize(file.getSize());
        coverImage.setWidth(image != null ? image.getWidth() : null);
        coverImage.setHeight(image != null ? image.getHeight() : null);
        coverImage.setMimeType(file.getContentType());
        coverImage.setUploadSource("single");
        coverImage.setIsUsed(false);

        coverImageMapper.insert(coverImage);

        return convertToDTO(coverImage);
    }

    /**
     * ZIP 批量上传封面
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public BatchUploadResultDTO uploadBatch(MultipartFile zipFile) throws Exception {
        BatchUploadResultDTO result = new BatchUploadResultDTO();
        result.setBatchId(UUID.randomUUID().toString());
        result.setTotalFiles(0);
        result.setSuccessCount(0);
        result.setFailureCount(0);

        // 创建临时目录
        String tempDir = System.getProperty("java.io.tmpdir") + File.separator + result.getBatchId();
        new File(tempDir).mkdirs();

        List<String> uploadedS3Keys = new ArrayList<>(); // 记录已上传的文件，用于失败时清理

        try {
            // 解压 ZIP 文件
            List<File> imageFiles = ZipExtractor.extractImages(zipFile, tempDir);
            result.setTotalFiles(imageFiles.size());

            // 使用线程池并行上传到 S3
            ExecutorService executor = Executors.newFixedThreadPool(5);
            List<Future<CoverImageDTO>> futures = new ArrayList<>();

            for (File imageFile : imageFiles) {
                Future<CoverImageDTO> future = executor.submit(() -> {
                    try {
                        return uploadSingleImageFile(imageFile, result.getBatchId());
                    } catch (Exception e) {
                        log.error("上传图片失败: " + imageFile.getName(), e);
                        result.getErrors().add(imageFile.getName() + ": " + e.getMessage());
                        return null;
                    }
                });
                futures.add(future);
            }

            // 等待所有上传完成
            executor.shutdown();
            executor.awaitTermination(10, TimeUnit.MINUTES);

            // 收集结果
            for (Future<CoverImageDTO> future : futures) {
                try {
                    CoverImageDTO dto = future.get();
                    if (dto != null) {
                        result.getUploadedImages().add(dto);
                        result.setSuccessCount(result.getSuccessCount() + 1);
                        uploadedS3Keys.add(dto.getFileUrl());
                    } else {
                        result.setFailureCount(result.getFailureCount() + 1);
                    }
                } catch (Exception e) {
                    result.setFailureCount(result.getFailureCount() + 1);
                    result.getErrors().add("处理失败: " + e.getMessage());
                }
            }

        } catch (Exception e) {
            // 批量上传失败，清理已上传的 S3 文件
            log.error("批量上传失败，开始清理已上传文件", e);
            for (String s3Url : uploadedS3Keys) {
                try {
                    fileUploadService.deleteFile(s3Url);
                } catch (Exception ex) {
                    log.error("清理 S3 文件失败: " + s3Url, ex);
                }
            }
            throw e;
        } finally {
            // 清理临时目录
            try {
                Files.walk(Paths.get(tempDir))
                        .sorted((a, b) -> b.compareTo(a)) // 先删除文件，再删除目录
                        .forEach(path -> {
                            try {
                                Files.deleteIfExists(path);
                            } catch (Exception e) {
                                log.warn("清理临时文件失败: " + path, e);
                            }
                        });
            } catch (Exception e) {
                log.warn("清理临时目录失败: " + tempDir, e);
            }
        }

        return result;
    }

    /**
     * 替换封面图片
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public CoverImageDTO replaceCover(Long id, MultipartFile newFile) throws Exception {
        // 查询原封面
        CoverImage coverImage = coverImageMapper.selectById(id);
        if (coverImage == null) {
            throw new RuntimeException("封面不存在");
        }

        // 验证新文件
        validateImageFile(newFile);

        // 上传新图片到 S3
        String newFileUrl = fileUploadService.uploadFile(newFile, "covers");
        String newS3Key = extractS3Key(newFileUrl);

        // 获取新图片尺寸
        BufferedImage image = ImageIO.read(newFile.getInputStream());

        // 删除旧的 S3 文件
        try {
            fileUploadService.deleteFile(coverImage.getFileUrl());
        } catch (Exception e) {
            log.warn("删除旧封面文件失败: " + coverImage.getFileUrl(), e);
        }

        // 更新数据库记录
        coverImage.setFileName(newFile.getOriginalFilename());
        coverImage.setFileUrl(newFileUrl);
        coverImage.setS3Key(newS3Key);
        coverImage.setFileSize(newFile.getSize());
        coverImage.setWidth(image != null ? image.getWidth() : null);
        coverImage.setHeight(image != null ? image.getHeight() : null);
        coverImage.setMimeType(newFile.getContentType());
        // 保持 is_used 状态不变

        coverImageMapper.updateById(coverImage);

        return convertToDTO(coverImage);
    }

    /**
     * 删除封面
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteCover(Long id) throws Exception {
        CoverImage coverImage = coverImageMapper.selectById(id);
        if (coverImage == null) {
            throw new RuntimeException("封面不存在");
        }

        // 检查使用状态
        if (Boolean.TRUE.equals(coverImage.getIsUsed())) {
            throw new RuntimeException("该封面正在使用中，无法删除");
        }

        // 从 S3 删除文件
        try {
            fileUploadService.deleteFile(coverImage.getFileUrl());
        } catch (Exception e) {
            log.warn("删除 S3 文件失败: " + coverImage.getFileUrl(), e);
        }

        // 软删除数据库记录
        coverImageMapper.deleteById(id);
    }

    /**
     * 标记使用状态
     */
    @Override
    public void markAsUsed(Long id, Boolean used) throws Exception {
        CoverImage coverImage = coverImageMapper.selectById(id);
        if (coverImage == null) {
            throw new RuntimeException("封面不存在");
        }

        coverImage.setIsUsed(used);
        coverImageMapper.updateById(coverImage);
    }

    /**
     * 获取未使用的封面
     */
    @Override
    public CoverImageDTO getUnusedCover() {
        LambdaQueryWrapper<CoverImage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CoverImage::getIsUsed, false)
                .orderByAsc(CoverImage::getCreatedAt)
                .last("LIMIT 1");

        CoverImage coverImage = coverImageMapper.selectOne(wrapper);
        return coverImage != null ? convertToDTO(coverImage) : null;
    }

    /**
     * 随机获取指定数量的未使用封面
     */
    @Override
    public List<CoverImageDTO> getRandomUnusedCovers(int count) {
        if (count <= 0) {
            return new ArrayList<>();
        }

        // 查询所有未使用的封面
        LambdaQueryWrapper<CoverImage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CoverImage::getIsUsed, false);

        List<CoverImage> allUnused = coverImageMapper.selectList(wrapper);

        // 如果未使用的封面数量不足，返回空列表
        if (allUnused.size() < count) {
            log.warn("未使用的封面数量不足: 需要 {}, 现有 {}", count, allUnused.size());
            return new ArrayList<>();
        }

        // 随机打乱并取前 count 个
        java.util.Collections.shuffle(allUnused);
        List<CoverImage> selected = allUnused.subList(0, count);

        return selected.stream()
                .map(this::convertToDTO)
                .collect(java.util.stream.Collectors.toList());
    }

    /**
     * 批量标记封面为已使用
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchMarkAsUsed(List<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return;
        }

        for (Long id : ids) {
            CoverImage coverImage = coverImageMapper.selectById(id);
            if (coverImage != null) {
                coverImage.setIsUsed(true);
                coverImageMapper.updateById(coverImage);
            }
        }
        log.info("批量标记 {} 个封面为已使用", ids.size());
    }

    /**
     * 上传单个图片文件（用于批量上传）
     */
    private CoverImageDTO uploadSingleImageFile(File file, String batchId) throws Exception {
        // 生成 S3 文件名
        String extension = getFileExtension(file.getName());
        String s3Key = "covers/" + UUID.randomUUID().toString() + extension;

        // 上传到 S3
        try (FileInputStream fis = new FileInputStream(file)) {
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(s3Key)
                    .contentType(getContentType(extension))
                    .acl(ObjectCannedACL.PUBLIC_READ)
                    .build();

            s3Client.putObject(putObjectRequest, RequestBody.fromInputStream(fis, file.length()));
        }

        // 生成 URL
        String fileUrl = String.format("https://%s.s3.%s.amazonaws.com/%s", bucketName, region, s3Key);

        // 获取图片尺寸
        BufferedImage image = ImageIO.read(file);

        // 创建封面记录
        CoverImage coverImage = new CoverImage();
        coverImage.setFileName(file.getName());
        coverImage.setFileUrl(fileUrl);
        coverImage.setS3Key(s3Key);
        coverImage.setFileSize(file.length());
        coverImage.setWidth(image != null ? image.getWidth() : null);
        coverImage.setHeight(image != null ? image.getHeight() : null);
        coverImage.setMimeType(getContentType(extension));
        coverImage.setUploadSource("batch");
        coverImage.setBatchId(batchId);
        coverImage.setIsUsed(false);

        coverImageMapper.insert(coverImage);

        return convertToDTO(coverImage);
    }

    /**
     * 验证图片文件
     */
    private void validateImageFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        // 检查文件大小（5MB）
        if (file.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException("文件大小不能超过 5MB");
        }

        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("只支持图片文件");
        }
    }

    /**
     * 从 URL 提取 S3 key
     */
    private String extractS3Key(String fileUrl) {
        return fileUrl.substring(fileUrl.indexOf(".com/") + 5);
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot > 0 ? fileName.substring(lastDot) : "";
    }

    /**
     * 根据扩展名获取 Content-Type
     */
    private String getContentType(String extension) {
        switch (extension.toLowerCase()) {
            case ".jpg":
            case ".jpeg":
                return "image/jpeg";
            case ".png":
                return "image/png";
            case ".webp":
                return "image/webp";
            default:
                return "application/octet-stream";
        }
    }

    /**
     * 实体转 DTO
     */
    private CoverImageDTO convertToDTO(CoverImage entity) {
        CoverImageDTO dto = new CoverImageDTO();
        BeanUtils.copyProperties(entity, dto);
        return dto;
    }
}
