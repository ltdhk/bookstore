package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Book;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface BookMapper extends BaseMapper<Book> {

    @Select("<script>" +
            "SELECT b.* FROM books b " +
            "INNER JOIN book_categories c ON b.category_id = c.id " +
            "WHERE c.name = #{categoryName} " +
            "AND b.status = 'published' " +
            "AND b.deleted = 0 " +
            "<if test='language != null and language != \"\"'>" +
            "AND b.language = #{language} " +
            "</if>" +
            "ORDER BY b.created_at DESC " +
            "LIMIT #{pageSize} OFFSET #{offset}" +
            "</script>")
    List<Book> selectBooksByCategory(@Param("categoryName") String categoryName,
                                     @Param("language") String language,
                                     @Param("pageSize") int pageSize,
                                     @Param("offset") int offset);
}
