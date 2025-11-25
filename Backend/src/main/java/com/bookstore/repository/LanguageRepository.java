package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Language;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface LanguageRepository extends BaseMapper<Language> {
}
