package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.entity.Book;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

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

    /**
     * Atomic increment views count to avoid race condition
     */
    @Update("UPDATE books SET views = COALESCE(views, 0) + 1 WHERE id = #{id}")
    void incrementViews(@Param("id") Long id);

    /**
     * Atomic increment likes count to avoid race condition
     */
    @Update("UPDATE books SET likes = COALESCE(likes, 0) + 1 WHERE id = #{id}")
    void incrementLikes(@Param("id") Long id);

    /**
     * Batch query chapter counts for multiple books to avoid N+1 problem
     */
    @Select("<script>" +
            "SELECT book_id, COUNT(*) as chapter_count FROM chapters " +
            "WHERE book_id IN " +
            "<foreach collection='bookIds' item='id' open='(' separator=',' close=')'>" +
            "#{id}" +
            "</foreach>" +
            " GROUP BY book_id" +
            "</script>")
    List<Map<String, Object>> selectChapterCountsByBookIds(@Param("bookIds") List<Long> bookIds);

    /**
     * Get book with chapter count in a single query using subquery
     * This avoids the N+1 problem when getting book details
     */
    @Select("SELECT b.*, " +
            "(SELECT COUNT(*) FROM chapters c WHERE c.book_id = b.id) as chapter_count " +
            "FROM books b WHERE b.id = #{id} AND b.deleted = 0")
    Map<String, Object> selectBookWithChapterCount(@Param("id") Long id);
}
