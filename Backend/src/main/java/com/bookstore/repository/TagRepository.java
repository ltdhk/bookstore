package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Tag;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TagRepository extends BaseMapper<Tag> {
}
