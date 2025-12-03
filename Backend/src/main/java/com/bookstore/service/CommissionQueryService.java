package com.bookstore.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.CommissionSummaryDTO;
import com.bookstore.entity.Order;
import com.bookstore.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Commission Query Service
 * Provides dynamic commission calculation based on order data
 * No separate commission table needed - all data is derived from orders
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CommissionQueryService {

    private final OrderRepository orderRepository;

    // Commission rate constant (30%)
    private static final BigDecimal COMMISSION_RATE = new BigDecimal("30.00");

    /**
     * Get commissions for a specific distributor
     *
     * @param distributorId Distributor ID
     * @param startDate Start date (optional)
     * @param endDate End date (optional)
     * @return List of commission summaries
     */
    public List<CommissionSummaryDTO> getDistributorCommissions(
            Long distributorId,
            LocalDateTime startDate,
            LocalDateTime endDate) {

        log.info("查询分销商佣金 - 分销商ID: {}, 时间范围: {} 至 {}",
            distributorId, startDate, endDate);

        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("distributor_id", distributorId);
        queryWrapper.eq("order_type", "subscription");
        queryWrapper.eq("status", "Paid"); // Only paid orders

        if (startDate != null) {
            queryWrapper.ge("create_time", startDate);
        }
        if (endDate != null) {
            queryWrapper.le("create_time", endDate);
        }

        queryWrapper.orderByDesc("create_time");

        List<Order> orders = orderRepository.selectList(queryWrapper);
        log.info("找到 {} 个符合条件的订单", orders.size());

        return orders.stream()
                .map(this::convertToCommissionSummary)
                .collect(Collectors.toList());
    }

    /**
     * Get total commission amount for a distributor
     *
     * @param distributorId Distributor ID
     * @param startDate Start date (optional)
     * @param endDate End date (optional)
     * @return Total commission amount
     */
    public BigDecimal getTotalCommissionAmount(
            Long distributorId,
            LocalDateTime startDate,
            LocalDateTime endDate) {

        List<CommissionSummaryDTO> commissions = getDistributorCommissions(
            distributorId, startDate, endDate);

        BigDecimal total = commissions.stream()
                .map(CommissionSummaryDTO::getCommissionAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        log.info("分销商 {} 总佣金: {}", distributorId, total);
        return total;
    }

    /**
     * Get commissions by passcode
     *
     * @param passcodeId Passcode ID
     * @return List of commission summaries
     */
    public List<CommissionSummaryDTO> getPasscodeCommissions(Long passcodeId) {
        log.info("查询口令佣金 - 口令ID: {}", passcodeId);

        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("source_passcode_id", passcodeId);
        queryWrapper.eq("order_type", "subscription");
        queryWrapper.eq("status", "Paid");
        queryWrapper.isNotNull("distributor_id"); // Must have distributor
        queryWrapper.orderByDesc("create_time");

        List<Order> orders = orderRepository.selectList(queryWrapper);
        log.info("找到 {} 个符合条件的订单", orders.size());

        return orders.stream()
                .map(this::convertToCommissionSummary)
                .collect(Collectors.toList());
    }

    /**
     * Get commissions by book
     *
     * @param bookId Book ID
     * @return List of commission summaries
     */
    public List<CommissionSummaryDTO> getBookCommissions(Long bookId) {
        log.info("查询书籍佣金 - 书籍ID: {}", bookId);

        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("source_book_id", bookId);
        queryWrapper.eq("order_type", "subscription");
        queryWrapper.eq("status", "Paid");
        queryWrapper.isNotNull("distributor_id");
        queryWrapper.orderByDesc("create_time");

        List<Order> orders = orderRepository.selectList(queryWrapper);
        log.info("找到 {} 个符合条件的订单", orders.size());

        return orders.stream()
                .map(this::convertToCommissionSummary)
                .collect(Collectors.toList());
    }

    /**
     * Convert order to commission summary
     */
    private CommissionSummaryDTO convertToCommissionSummary(Order order) {
        CommissionSummaryDTO dto = new CommissionSummaryDTO();
        dto.setDistributorId(order.getDistributorId());
        dto.setOrderId(order.getId());
        dto.setOrderNo(order.getOrderNo());
        dto.setOrderAmount(order.getAmount());
        dto.setCommissionRate(COMMISSION_RATE);

        // Calculate commission amount dynamically
        BigDecimal commissionAmount = order.getAmount()
                .multiply(COMMISSION_RATE)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        dto.setCommissionAmount(commissionAmount);

        dto.setOrderStatus(order.getStatus());
        dto.setPlatform(order.getPlatform());
        dto.setSourcePasscodeId(order.getSourcePasscodeId());
        dto.setSourceBookId(order.getSourceBookId());
        dto.setSourceEntry(order.getSourceEntry());
        dto.setCreateTime(order.getCreateTime());
        dto.setUserId(order.getUserId());
        dto.setProductId(order.getProductId());
        dto.setSubscriptionPeriod(order.getSubscriptionPeriod());

        return dto;
    }

    /**
     * Calculate commission amount (utility method)
     */
    public static BigDecimal calculateCommission(BigDecimal orderAmount) {
        return orderAmount
                .multiply(COMMISSION_RATE)
                .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
    }
}
