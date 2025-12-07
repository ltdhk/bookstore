package com.bookstore.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.bookstore.dto.BatchUploadResultDTO;
import com.bookstore.dto.CoverImageDTO;
import com.bookstore.dto.CoverImageQueryDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 封面图片服务接口
 */
public interface CoverImageService {

    /**
     * 分页查询封面列表
     *
     * @param query 查询参数
     * @return 分页结果
     */
    IPage<CoverImageDTO> listCovers(CoverImageQueryDTO query);

    /**
     * 获取单个封面详情
     *
     * @param id 封面ID
     * @return 封面详情
     */
    CoverImageDTO getCover(Long id);

    /**
     * 上传单个封面
     *
     * @param file 文件
     * @return 封面信息
     * @throws Exception 上传异常
     */
    CoverImageDTO uploadSingle(MultipartFile file) throws Exception;

    /**
     * ZIP 批量上传封面
     *
     * @param zipFile ZIP 文件
     * @return 批量上传结果
     * @throws Exception 上传异常
     */
    BatchUploadResultDTO uploadBatch(MultipartFile zipFile) throws Exception;

    /**
     * 替换封面图片
     *
     * @param id      封面ID
     * @param newFile 新文件
     * @return 更新后的封面信息
     * @throws Exception 替换异常
     */
    CoverImageDTO replaceCover(Long id, MultipartFile newFile) throws Exception;

    /**
     * 删除封面（检查使用状态）
     *
     * @param id 封面ID
     * @throws Exception 删除异常
     */
    void deleteCover(Long id) throws Exception;

    /**
     * 手动标记/取消标记为已使用
     *
     * @param id   封面ID
     * @param used 是否已使用
     * @throws Exception 标记异常
     */
    void markAsUsed(Long id, Boolean used) throws Exception;

    /**
     * 获取一个未使用的封面（用于批量导入时自动分配）
     *
     * @return 封面信息，如果没有未使用的封面则返回 null
     */
    CoverImageDTO getUnusedCover();

    /**
     * 随机获取指定数量的未使用封面（用于批量导入时自动分配）
     *
     * @param count 需要的封面数量
     * @return 封面列表，如果未使用的封面数量不足则返回空列表
     */
    List<CoverImageDTO> getRandomUnusedCovers(int count);

    /**
     * 批量标记封面为已使用
     *
     * @param ids 封面ID列表
     */
    void batchMarkAsUsed(List<Long> ids);
}
