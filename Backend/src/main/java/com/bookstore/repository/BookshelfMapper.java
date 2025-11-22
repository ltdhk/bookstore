package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Bookshelf;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BookshelfMapper extends BaseMapper<Bookshelf> {
}
