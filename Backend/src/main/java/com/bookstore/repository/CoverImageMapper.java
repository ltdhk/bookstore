package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.CoverImage;
import org.apache.ibatis.annotations.Mapper;

/**
 * 封面图片 Mapper 接口
 * 提供基础 CRUD 操作
 */
@Mapper
public interface CoverImageMapper extends BaseMapper<CoverImage> {
    // 基础 CRUD 由 MyBatis Plus 的 BaseMapper 提供
    // 包括：insert, deleteById, updateById, selectById, selectList 等
}
