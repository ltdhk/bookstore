package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.dto.*;
import com.bookstore.entity.Distributor;
import com.bookstore.entity.Order;
import com.bookstore.repository.*;
import com.bookstore.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final UserMapper userMapper;
    private final BookMapper bookMapper;
    private final OrderRepository orderRepository;
    private final BookPasscodeRepository passcodeRepository;
    private final DistributorRepository distributorRepository;

    @Override
    public DashboardStatsDTO getDashboardStats() {
        DashboardStatsDTO stats = new DashboardStatsDTO();

        // 总用户数
        Long totalUsers = userMapper.selectCount(null);
        stats.setTotalUsers(totalUsers);

        // 活跃用户数（有有效订阅的用户）
        QueryWrapper<com.bookstore.entity.User> activeUserQuery = new QueryWrapper<>();
        activeUserQuery.eq("subscription_status", "active");
        Long activeUsers = userMapper.selectCount(activeUserQuery);
        stats.setActiveUsers(activeUsers);

        // 总书籍数
        Long totalBooks = bookMapper.selectCount(null);
        stats.setTotalBooks(totalBooks);

        // 总订单数
        Long totalOrders = orderRepository.selectCount(null);
        stats.setTotalOrders(totalOrders);

        // 总收益（只统计已支付订单）
        QueryWrapper<Order> paidOrderQuery = new QueryWrapper<>();
        paidOrderQuery.eq("status", "Paid");
        List<Order> paidOrders = orderRepository.selectList(paidOrderQuery);
        BigDecimal totalRevenue = paidOrders.stream()
                .map(Order::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        stats.setTotalRevenue(totalRevenue);

        // 今日收益（只统计已支付订单）
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);
        QueryWrapper<Order> todayOrderQuery = new QueryWrapper<>();
        todayOrderQuery.eq("status", "Paid")
                .ge("create_time", todayStart)
                .le("create_time", todayEnd);
        List<Order> todayOrders = orderRepository.selectList(todayOrderQuery);
        BigDecimal todayRevenue = todayOrders.stream()
                .map(Order::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        stats.setTodayRevenue(todayRevenue);

        return stats;
    }

    @Override
    public List<PasscodeRankingDTO> getPasscodeRanking(String startDate, String endDate, int limit) {
        return passcodeRepository.selectPasscodeRanking(startDate, endDate, limit);
    }

    @Override
    public List<DistributorRevenueRankingDTO> getDistributorRanking(String startDate, String endDate, int limit) {
        // 查询所有已支付订单
        QueryWrapper<Order> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "Paid");

        if (startDate != null && !startDate.isEmpty()) {
            queryWrapper.ge("create_time", startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            queryWrapper.le("create_time", endDate);
        }

        List<Order> orders = orderRepository.selectList(queryWrapper);

        // 按分销商分组统计
        Map<Long, List<Order>> ordersByDistributor = orders.stream()
                .filter(o -> o.getDistributorId() != null)
                .collect(Collectors.groupingBy(Order::getDistributorId));

        // 构建排行榜
        List<DistributorRevenueRankingDTO> ranking = ordersByDistributor.entrySet().stream()
                .map(entry -> {
                    Long distributorId = entry.getKey();
                    List<Order> distributorOrders = entry.getValue();

                    // 查询分销商信息
                    Distributor distributor = distributorRepository.selectById(distributorId);
                    if (distributor == null) {
                        return null;
                    }

                    // 统计订单数和总收益
                    long orderCount = distributorOrders.size();
                    BigDecimal totalRevenue = distributorOrders.stream()
                            .map(Order::getAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    // 计算分销商分成
                    BigDecimal commissionRate = distributor.getCommissionRate() != null
                            ? distributor.getCommissionRate()
                            : BigDecimal.valueOf(30);
                    BigDecimal distributorCommission = totalRevenue
                            .multiply(commissionRate)
                            .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

                    DistributorRevenueRankingDTO dto = new DistributorRevenueRankingDTO();
                    dto.setDistributorId(distributorId);
                    dto.setDistributorName(distributor.getName());
                    dto.setOrderCount(orderCount);
                    dto.setTotalRevenue(totalRevenue);
                    dto.setCommissionRate(commissionRate);
                    dto.setDistributorCommission(distributorCommission);

                    return dto;
                })
                .filter(dto -> dto != null)
                .sorted((a, b) -> Long.compare(b.getOrderCount(), a.getOrderCount()))
                .limit(limit)
                .collect(Collectors.toList());

        return ranking;
    }

    @Override
    public List<RevenueTrendDTO> getRevenueTrend(String startDate, String endDate) {
        return orderRepository.selectRevenueTrend(startDate, endDate);
    }

    @Override
    public List<PlatformDistributionDTO> getPlatformDistribution(String startDate, String endDate) {
        List<PlatformDistributionDTO> distribution = orderRepository.selectPlatformDistribution(startDate, endDate);

        // 计算总收益用于百分比计算
        BigDecimal totalRevenue = distribution.stream()
                .map(PlatformDistributionDTO::getRevenue)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 计算每个平台的百分比
        if (totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
            distribution.forEach(dto -> {
                double percentage = dto.getRevenue()
                        .divide(totalRevenue, 4, RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(100))
                        .doubleValue();
                dto.setPercentage(percentage);
            });
        }

        return distribution;
    }

    @Override
    public List<TopBookDTO> getTopBooks(int limit) {
        return bookMapper.selectTopBooksByViews(limit);
    }
}
