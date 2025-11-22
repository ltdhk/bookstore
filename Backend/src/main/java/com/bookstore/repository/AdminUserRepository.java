package com.bookstore.repository;

import com.bookstore.entity.AdminUser;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdminUserRepository extends BaseMapper<AdminUser> {
}
