package com.bookstore.repository;

import com.bookstore.entity.Distributor;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DistributorRepository extends BaseMapper<Distributor> {
}
