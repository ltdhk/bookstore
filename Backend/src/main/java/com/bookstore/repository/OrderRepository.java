package com.bookstore.repository;

import com.bookstore.dto.PlatformDistributionDTO;
import com.bookstore.dto.RevenueTrendDTO;
import com.bookstore.dto.SubscriptionOrderDetailDTO;
import com.bookstore.dto.SubscriptionOrderListDTO;
import com.bookstore.entity.Order;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface OrderRepository extends BaseMapper<Order> {

    /**
     * 分页查询订阅订单列表（使用 JOIN 查询关联的用户名和分销商名称）
     */
    @Select("<script>" +
            "SELECT " +
            "  o.id, o.order_no AS orderNo, o.user_id AS userId, u.username, " +
            "  o.platform, o.subscription_period AS subscriptionPeriod, o.amount, o.status, " +
            "  o.subscription_start_date AS subscriptionStartDate, " +
            "  o.subscription_end_date AS subscriptionEndDate, " +
            "  o.is_auto_renew AS isAutoRenew, o.source_entry AS sourceEntry, " +
            "  o.distributor_id AS distributorId, d.name AS distributorName, " +
            "  o.create_time AS createTime " +
            "FROM orders o " +
            "LEFT JOIN users u ON o.user_id = u.id " +
            "LEFT JOIN distributors d ON o.distributor_id = d.id " +
            "WHERE o.order_type = 'subscription' " +
            "<if test='status != null and status != \"\"'>" +
            "  AND o.status = #{status} " +
            "</if>" +
            "<if test='platform != null and platform != \"\"'>" +
            "  AND o.platform = #{platform} " +
            "</if>" +
            "<if test='subscriptionPeriod != null and subscriptionPeriod != \"\"'>" +
            "  AND o.subscription_period = #{subscriptionPeriod} " +
            "</if>" +
            "<if test='username != null and username != \"\"'>" +
            "  AND u.username LIKE CONCAT('%', #{username}, '%') " +
            "</if>" +
            "<if test='distributorId != null'>" +
            "  AND o.distributor_id = #{distributorId} " +
            "</if>" +
            "<if test='startDate != null and startDate != \"\"'>" +
            "  AND o.create_time &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null and endDate != \"\"'>" +
            "  AND o.create_time &lt;= #{endDate} " +
            "</if>" +
            "ORDER BY o.create_time DESC " +
            "LIMIT #{size} OFFSET #{offset}" +
            "</script>")
    List<SubscriptionOrderListDTO> selectSubscriptionOrderList(
            @Param("status") String status,
            @Param("platform") String platform,
            @Param("subscriptionPeriod") String subscriptionPeriod,
            @Param("username") String username,
            @Param("distributorId") Long distributorId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("size") int size,
            @Param("offset") int offset);

    /**
     * 统计订阅订单总数（与列表查询条件一致）
     */
    @Select("<script>" +
            "SELECT COUNT(*) " +
            "FROM orders o " +
            "LEFT JOIN users u ON o.user_id = u.id " +
            "WHERE o.order_type = 'subscription' " +
            "<if test='status != null and status != \"\"'>" +
            "  AND o.status = #{status} " +
            "</if>" +
            "<if test='platform != null and platform != \"\"'>" +
            "  AND o.platform = #{platform} " +
            "</if>" +
            "<if test='subscriptionPeriod != null and subscriptionPeriod != \"\"'>" +
            "  AND o.subscription_period = #{subscriptionPeriod} " +
            "</if>" +
            "<if test='username != null and username != \"\"'>" +
            "  AND u.username LIKE CONCAT('%', #{username}, '%') " +
            "</if>" +
            "<if test='distributorId != null'>" +
            "  AND o.distributor_id = #{distributorId} " +
            "</if>" +
            "<if test='startDate != null and startDate != \"\"'>" +
            "  AND o.create_time &gt;= #{startDate} " +
            "</if>" +
            "<if test='endDate != null and endDate != \"\"'>" +
            "  AND o.create_time &lt;= #{endDate} " +
            "</if>" +
            "</script>")
    long countSubscriptionOrders(
            @Param("status") String status,
            @Param("platform") String platform,
            @Param("subscriptionPeriod") String subscriptionPeriod,
            @Param("username") String username,
            @Param("distributorId") Long distributorId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate);

    /**
     * 获取订阅订单详情（使用 JOIN 查询关联的分销商、通行证、书籍名称）
     */
    @Select("SELECT " +
            "  o.id, o.user_id AS userId, o.order_no AS orderNo, o.amount, o.status, " +
            "  o.platform, o.product_id AS productId, o.order_type AS orderType, " +
            "  o.subscription_period AS subscriptionPeriod, " +
            "  o.subscription_start_date AS subscriptionStartDate, " +
            "  o.subscription_end_date AS subscriptionEndDate, " +
            "  o.is_auto_renew AS isAutoRenew, o.cancel_date AS cancelDate, " +
            "  o.cancel_reason AS cancelReason, o.original_transaction_id AS originalTransactionId, " +
            "  o.platform_transaction_id AS platformTransactionId, " +
            "  o.source_entry AS sourceEntry, o.create_time AS createTime, o.update_time AS updateTime, " +
            "  o.distributor_id AS distributorId, o.source_passcode_id AS sourcePasscodeId, " +
            "  o.source_book_id AS sourceBookId, " +
            "  d.name AS distributorName, " +
            "  p.name AS passcodeName, p.passcode AS passcodeCode, " +
            "  b.title AS bookTitle, " +
            "  u.username AS username, " +
            "  sp.product_name AS productName " +
            "FROM orders o " +
            "LEFT JOIN distributors d ON o.distributor_id = d.id " +
            "LEFT JOIN book_passcodes p ON o.source_passcode_id = p.id " +
            "LEFT JOIN books b ON o.source_book_id = b.id " +
            "LEFT JOIN users u ON o.user_id = u.id " +
            "LEFT JOIN subscription_products sp ON o.product_id = sp.product_id " +
            "WHERE o.id = #{id}")
    SubscriptionOrderDetailDTO selectSubscriptionOrderDetail(@Param("id") Long id);

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
