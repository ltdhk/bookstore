package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * Find soft-deleted user by Apple user ID (bypassing @TableLogic)
     */
    @Select("SELECT * FROM users WHERE apple_user_id = #{appleUserId} AND deleted = 1 LIMIT 1")
    User selectDeletedByAppleUserId(@Param("appleUserId") String appleUserId);

    /**
     * Find soft-deleted user by Google user ID (bypassing @TableLogic)
     */
    @Select("SELECT * FROM users WHERE google_user_id = #{googleUserId} AND deleted = 1 LIMIT 1")
    User selectDeletedByGoogleUserId(@Param("googleUserId") String googleUserId);

    /**
     * Find soft-deleted user by email (bypassing @TableLogic)
     */
    @Select("SELECT * FROM users WHERE email = #{email} AND deleted = 1 LIMIT 1")
    User selectDeletedByEmail(@Param("email") String email);

    /**
     * Find soft-deleted user by username (bypassing @TableLogic)
     */
    @Select("SELECT * FROM users WHERE username = #{username} AND deleted = 1 LIMIT 1")
    User selectDeletedByUsername(@Param("username") String username);

    /**
     * Restore a soft-deleted user
     */
    @Update("UPDATE users SET deleted = 0 WHERE id = #{userId}")
    int restoreUser(@Param("userId") Long userId);
}
