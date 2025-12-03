package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.SubscriptionEvent;
import org.apache.ibatis.annotations.Mapper;

/**
 * Subscription event repository
 */
@Mapper
public interface SubscriptionEventRepository extends BaseMapper<SubscriptionEvent> {
}
