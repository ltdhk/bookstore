package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.SubscriptionProduct;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SubscriptionProductRepository extends BaseMapper<SubscriptionProduct> {
}
