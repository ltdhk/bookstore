package com.bookstore.service;

import com.bookstore.dto.*;

import java.util.List;

public interface DashboardService {

    /**
     * 获取Dashboard基础统计数据
     */
    DashboardStatsDTO getDashboardStats();

    /**
     * 获取口令排行榜
     */
    List<PasscodeRankingDTO> getPasscodeRanking(String startDate, String endDate, int limit);

    /**
     * 获取分销商收益排行榜
     */
    List<DistributorRevenueRankingDTO> getDistributorRanking(String startDate, String endDate, int limit);

    /**
     * 获取收益趋势（按天）
     */
    List<RevenueTrendDTO> getRevenueTrend(String startDate, String endDate);

    /**
     * 获取平台分布统计
     */
    List<PlatformDistributionDTO> getPlatformDistribution(String startDate, String endDate);

    /**
     * 获取热门书籍Top N
     */
    List<TopBookDTO> getTopBooks(int limit);
}
