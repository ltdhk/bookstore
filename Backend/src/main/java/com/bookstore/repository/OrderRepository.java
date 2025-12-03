package com.bookstore.repository;

import com.bookstore.dto.PlatformDistributionDTO;
import com.bookstore.dto.RevenueTrendDTO;
import com.bookstore.entity.Order;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface OrderRepository extends BaseMapper<Order> {

    /**
     * 获取收益趋势（按天统计）
     */
    @Select("<script>" +
            "SELECT " +
            "  DATE(create_time) AS date, " +
            "  SUM(amount) AS revenue, " +
            "  COUNT(*) AS orderCount " +
            "FROM orders " +
            "WHERE status = 'Paid' " +
            "<if test='startDate != null and startDate != \"\"'>" +
            "  AND create_time &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null and endDate != \"\"'>" +
            "  AND create_time &lt;= #{endDate} " +
            "</if>" +
            "GROUP BY DATE(create_time) " +
            "ORDER BY date" +
            "</script>")
    List<RevenueTrendDTO> selectRevenueTrend(
            @Param("startDate") String startDate,
            @Param("endDate") String endDate);

    /**
     * 获取平台分布统计
     */
    @Select("<script>" +
            "SELECT " +
            "  platform, " +
            "  COUNT(*) AS orderCount, " +
            "  SUM(amount) AS revenue " +
            "FROM orders " +
            "WHERE status = 'Paid' " +
            "<if test='startDate != null and startDate != \"\"'>" +
            "  AND create_time &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null and endDate != \"\"'>" +
            "  AND create_time &lt;= #{endDate} " +
            "</if>" +
            "GROUP BY platform" +
            "</script>")
    List<PlatformDistributionDTO> selectPlatformDistribution(
            @Param("startDate") String startDate,
            @Param("endDate") String endDate);
}
