package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bookstore.dto.BatchUploadResultDTO;
import com.bookstore.dto.CoverImageDTO;
import com.bookstore.dto.CoverImageQueryDTO;
import com.bookstore.service.CoverImageService;
import com.bookstore.util.Result;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * 封面图片管理控制器
 */
@RestController
@RequestMapping("/api/admin/covers")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CoverImageController {

    private final CoverImageService coverImageService;

    /**
     * 分页查询封面列表
     *
     * @param query 查询参数
     * @return 分页结果
     */
    @GetMapping
    public Result<IPage<CoverImageDTO>> listCovers(CoverImageQueryDTO query) {
        try {
            IPage<CoverImageDTO> result = coverImageService.listCovers(query);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取单个封面详情
     *
     * @param id 封面ID
     * @return 封面详情
     */
    @GetMapping("/{id}")
    public Result<CoverImageDTO> getCover(@PathVariable Long id) {
        try {
            CoverImageDTO cover = coverImageService.getCover(id);
            return Result.success(cover);
        } catch (Exception e) {
            return Result.error("获取失败: " + e.getMessage());
        }
    }

    /**
     * 上传单个封面
     *
     * @param file 文件
     * @return 封面信息
     */
    @PostMapping("/upload/single")
    public Result<CoverImageDTO> uploadSingle(@RequestParam("file") MultipartFile file) {
        try {
            CoverImageDTO result = coverImageService.uploadSingle(file);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * ZIP 批量上传封面
     *
     * @param zipFile ZIP 文件
     * @return 批量上传结果
     */
    @PostMapping("/upload/batch")
    public Result<BatchUploadResultDTO> uploadBatch(@RequestParam("file") MultipartFile zipFile) {
        try {
            BatchUploadResultDTO result = coverImageService.uploadBatch(zipFile);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("批量上传失败: " + e.getMessage());
        }
    }

    /**
     * 替换封面图片
     *
     * @param id      封面ID
     * @param newFile 新文件
     * @return 更新后的封面信息
     */
    @PutMapping("/{id}/replace")
    public Result<CoverImageDTO> replaceCover(
            @PathVariable Long id,
            @RequestParam("file") MultipartFile newFile) {
        try {
            CoverImageDTO result = coverImageService.replaceCover(id, newFile);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("替换失败: " + e.getMessage());
        }
    }

    /**
     * 删除封面（已使用的封面不允许删除）
     *
     * @param id 封面ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Result<String> deleteCover(@PathVariable Long id) {
        try {
            coverImageService.deleteCover(id);
            return Result.success("删除成功");
        } catch (Exception e) {
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 标记/取消标记封面为已使用
     *
     * @param id   封面ID
     * @param used 是否已使用
     * @return 操作结果
     */
    @PutMapping("/{id}/mark-used")
    public Result<String> markAsUsed(
            @PathVariable Long id,
            @RequestParam Boolean used) {
        try {
            coverImageService.markAsUsed(id, used);
            return Result.success("标记成功");
        } catch (Exception e) {
            return Result.error("标记失败: " + e.getMessage());
        }
    }

    /**
     * 获取一个未使用的封面（用于批量导入）
     *
     * @return 封面信息，如果没有未使用的封面则返回 null
     */
    @GetMapping("/unused/random")
    public Result<CoverImageDTO> getUnusedCover() {
        try {
            CoverImageDTO cover = coverImageService.getUnusedCover();
            return Result.success(cover);
        } catch (Exception e) {
            return Result.error("获取失败: " + e.getMessage());
        }
    }
}
