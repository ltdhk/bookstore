package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.AppVersion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface AppVersionMapper extends BaseMapper<AppVersion> {

    /**
     * Get the latest version for a specific platform
     */
    @Select("SELECT * FROM app_versions WHERE platform = #{platform} ORDER BY version_code DESC LIMIT 1")
    AppVersion selectLatestByPlatform(@Param("platform") String platform);
}
