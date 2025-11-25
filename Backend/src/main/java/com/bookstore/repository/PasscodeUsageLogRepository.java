package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.PasscodeUsageLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PasscodeUsageLogRepository extends BaseMapper<PasscodeUsageLog> {
}
