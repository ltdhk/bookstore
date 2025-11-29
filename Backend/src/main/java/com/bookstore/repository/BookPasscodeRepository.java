package com.bookstore.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.bookstore.dto.BookPasscodeDTO;
import com.bookstore.entity.BookPasscode;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface BookPasscodeRepository extends BaseMapper<BookPasscode> {

    /**
     * 分页查询口令列表（连接查询，一次获取所有数据）
     */
    @Select("<script>" +
            "SELECT " +
            "  p.id, p.book_id AS bookId, p.distributor_id AS distributorId, " +
            "  p.passcode, p.name, p.max_usage AS maxUsage, " +
            "  p.used_count AS usedCount, p.view_count AS viewCount, " +
            "  p.status, p.valid_from AS validFrom, p.valid_to AS validTo, " +
            "  p.created_at AS createdAt, p.updated_at AS updatedAt, " +
            "  b.title AS bookTitle, " +
            "  d.name AS distributorName, " +
            "  COALESCE(os.order_count, 0) AS orderCount, " +
            "  COALESCE(os.total_amount, 0) AS totalAmount " +
            "FROM book_passcodes p " +
            "LEFT JOIN books b ON p.book_id = b.id " +
            "LEFT JOIN distributors d ON p.distributor_id = d.id " +
            "LEFT JOIN (" +
            "  SELECT source_passcode_id, COUNT(*) AS order_count, SUM(amount) AS total_amount " +
            "  FROM orders WHERE status = 'Paid' GROUP BY source_passcode_id" +
            ") os ON p.id = os.source_passcode_id " +
            "WHERE p.deleted = 0 " +
            "<if test='passcode != null and passcode != \"\"'>" +
            "AND p.passcode LIKE CONCAT('%', #{passcode}, '%') " +
            "</if>" +
            "<if test='distributorId != null'>" +
            "AND p.distributor_id = #{distributorId} " +
            "</if>" +
            "ORDER BY p.created_at DESC " +
            "LIMIT #{size} OFFSET #{offset}" +
            "</script>")
    List<BookPasscodeDTO> selectPasscodesWithDetails(
            @Param("passcode") String passcode,
            @Param("distributorId") Long distributorId,
            @Param("size") int size,
            @Param("offset") int offset);

    /**
     * 统计口令总数
     */
    @Select("<script>" +
            "SELECT COUNT(*) FROM book_passcodes p " +
            "WHERE p.deleted = 0 " +
            "<if test='passcode != null and passcode != \"\"'>" +
            "AND p.passcode LIKE CONCAT('%', #{passcode}, '%') " +
            "</if>" +
            "<if test='distributorId != null'>" +
            "AND p.distributor_id = #{distributorId} " +
            "</if>" +
            "</script>")
    long countPasscodes(
            @Param("passcode") String passcode,
            @Param("distributorId") Long distributorId);
}
