package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Advertisement;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdvertisementRepository extends BaseMapper<Advertisement> {
}
