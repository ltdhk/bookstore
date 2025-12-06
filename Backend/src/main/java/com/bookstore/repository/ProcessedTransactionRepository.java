package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.ProcessedTransaction;
import org.apache.ibatis.annotations.Mapper;

/**
 * Repository for tracking processed platform transaction IDs
 */
@Mapper
public interface ProcessedTransactionRepository extends BaseMapper<ProcessedTransaction> {
}
