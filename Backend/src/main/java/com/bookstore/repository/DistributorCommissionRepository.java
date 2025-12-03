package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.DistributorCommission;
import org.apache.ibatis.annotations.Mapper;

/**
 * Distributor commission repository
 */
@Mapper
public interface DistributorCommissionRepository extends BaseMapper<DistributorCommission> {
}
