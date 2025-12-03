package com.bookstore.util;

import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * ZIP 文件解压工具类
 * 用于从 ZIP 文件中提取图片
 */
public class ZipExtractor {

    /**
     * 允许的图片扩展名
     */
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "webp");

    /**
     * 单个文件最大大小：5MB
     */
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    /**
     * 最大文件数量
     */
    private static final int MAX_FILES = 100;

    /**
     * 从 ZIP 文件提取图片到临时目录
     * 仅处理根目录的文件，不递归子目录
     *
     * @param zipFile ZIP 文件
     * @param tempDir 临时目录路径
     * @return 提取的图片文件列表
     * @throws Exception 提取异常
     */
    public static List<File> extractImages(MultipartFile zipFile, String tempDir) throws Exception {
        List<File> imageFiles = new ArrayList<>();
        int fileCount = 0;

        try (ZipInputStream zis = new ZipInputStream(zipFile.getInputStream())) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                // 跳过目录
                if (entry.isDirectory()) {
                    continue;
                }

                // 跳过子目录中的文件（检查路径中是否包含 / 或 \）
                String entryName = entry.getName();
                if (entryName.contains("/") || entryName.contains("\\")) {
                    continue;
                }

                // 检查文件数量限制
                if (fileCount >= MAX_FILES) {
                    throw new IllegalArgumentException("ZIP 文件包含超过 " + MAX_FILES + " 个文件");
                }
                fileCount++;

                // 检查文件扩展名
                String fileName = new File(entryName).getName();
                String extension = getExtension(fileName).toLowerCase();
                if (!ALLOWED_EXTENSIONS.contains(extension)) {
                    continue; // 跳过非图片文件
                }

                // 检查文件大小
                if (entry.getSize() > MAX_FILE_SIZE) {
                    throw new IllegalArgumentException(
                            "文件过大: " + fileName + " (最大 5MB)"
                    );
                }

                // 写入临时文件
                File tempFile = new File(tempDir, fileName);
                try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                    byte[] buffer = new byte[8192];
                    int len;
                    while ((len = zis.read(buffer)) > 0) {
                        fos.write(buffer, 0, len);
                    }
                }

                // 验证图片完整性
                if (isValidImage(tempFile)) {
                    imageFiles.add(tempFile);
                } else {
                    tempFile.delete(); // 删除无效图片
                }

                zis.closeEntry();
            }
        }

        if (imageFiles.isEmpty()) {
            throw new IllegalArgumentException("ZIP 文件中没有找到有效的图片文件");
        }

        return imageFiles;
    }

    /**
     * 验证图片是否有效
     *
     * @param file 文件
     * @return 是否有效
     */
    private static boolean isValidImage(File file) {
        try {
            BufferedImage img = ImageIO.read(file);
            return img != null && img.getWidth() > 0 && img.getHeight() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 获取文件扩展名
     *
     * @param fileName 文件名
     * @return 扩展名（不含点）
     */
    private static String getExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot > 0 ? fileName.substring(lastDot + 1) : "";
    }
}
