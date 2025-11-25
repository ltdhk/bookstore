package com.bookstore.controller.admin;

import com.bookstore.common.Result;
import com.bookstore.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/admin/upload")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class FileController {

    private final FileUploadService fileUploadService;

    /**
     * 上传文件到S3
     * @param file 文件
     * @param folder 文件夹名称（可选，默认为covers）
     * @return 文件的公开访问URL
     */
    @PostMapping
    public Result<String> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "covers") String folder) {
        try {
            String fileUrl = fileUploadService.uploadFile(file, folder);
            return Result.success(fileUrl);
        } catch (Exception e) {
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }

    /**
     * 删除S3上的文件
     * @param fileUrl 文件URL
     * @return 删除结果
     */
    @DeleteMapping
    public Result<String> delete(@RequestParam("fileUrl") String fileUrl) {
        try {
            fileUploadService.deleteFile(fileUrl);
            return Result.success("文件删除成功");
        } catch (Exception e) {
            return Result.error("文件删除失败: " + e.getMessage());
        }
    }
}
