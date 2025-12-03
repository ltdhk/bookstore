package com.bookstore.controller.admin;

import com.bookstore.common.Result;
import com.bookstore.dto.*;
import com.bookstore.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DashboardController {

    private final DashboardService dashboardService;

    /**
     * 获取Dashboard基础统计数据
     */
    @GetMapping("/stats")
    public Result<DashboardStatsDTO> getStats() {
        DashboardStatsDTO stats = dashboardService.getDashboardStats();
        return Result.success(stats);
    }

    /**
     * 获取口令排行榜（按订单数排序）
     */
    @GetMapping("/passcode-ranking")
    public Result<List<PasscodeRankingDTO>> getPasscodeRanking(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "10") int limit) {
        List<PasscodeRankingDTO> ranking = dashboardService.getPasscodeRanking(startDate, endDate, limit);
        return Result.success(ranking);
    }

    /**
     * 获取分销商收益排行榜
     */
    @GetMapping("/distributor-ranking")
    public Result<List<DistributorRevenueRankingDTO>> getDistributorRanking(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "10") int limit) {
        List<DistributorRevenueRankingDTO> ranking = dashboardService.getDistributorRanking(startDate, endDate, limit);
        return Result.success(ranking);
    }

    /**
     * 获取收益趋势（按天统计）
     */
    @GetMapping("/revenue-trend")
    public Result<List<RevenueTrendDTO>> getRevenueTrend(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        List<RevenueTrendDTO> trend = dashboardService.getRevenueTrend(startDate, endDate);
        return Result.success(trend);
    }

    /**
     * 获取平台分布统计
     */
    @GetMapping("/platform-distribution")
    public Result<List<PlatformDistributionDTO>> getPlatformDistribution(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        List<PlatformDistributionDTO> distribution = dashboardService.getPlatformDistribution(startDate, endDate);
        return Result.success(distribution);
    }

    /**
     * 获取热门书籍Top 10
     */
    @GetMapping("/top-books")
    public Result<List<TopBookDTO>> getTopBooks(
            @RequestParam(defaultValue = "10") int limit) {
        List<TopBookDTO> topBooks = dashboardService.getTopBooks(limit);
        return Result.success(topBooks);
    }
}
