import request from '../utils/request';

// TypeScript接口定义
export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalBooks: number;
  totalOrders: number;
  totalRevenue: number;
  todayRevenue: number;
}

export interface PasscodeRanking {
  passcodeId: number;
  passcode: string;
  distributorName: string;
  bookTitle: string;
  orderCount: number;
  totalRevenue: number;
}

export interface DistributorRevenueRanking {
  distributorId: number;
  distributorName: string;
  orderCount: number;
  totalRevenue: number;
  commissionRate: number;
  distributorCommission: number;
}

export interface RevenueTrend {
  date: string;
  revenue: number;
  orderCount: number;
}

export interface PlatformDistribution {
  platform: string;
  orderCount: number;
  revenue: number;
  percentage: number;
}

export interface TopBook {
  bookId: number;
  title: string;
  author: string;
  views: number;
  likes: number;
}

// API方法
export const getDashboardStats = () => {
  return request({
    url: '/admin/dashboard/stats',
    method: 'get',
  });
};

export const getPasscodeRanking = (params: { startDate?: string; endDate?: string; limit?: number }) => {
  return request({
    url: '/admin/dashboard/passcode-ranking',
    method: 'get',
    params,
  });
};

export const getDistributorRanking = (params: { startDate?: string; endDate?: string; limit?: number }) => {
  return request({
    url: '/admin/dashboard/distributor-ranking',
    method: 'get',
    params,
  });
};

export const getRevenueTrend = (params: { startDate?: string; endDate?: string }) => {
  return request({
    url: '/admin/dashboard/revenue-trend',
    method: 'get',
    params,
  });
};

export const getPlatformDistribution = (params: { startDate?: string; endDate?: string }) => {
  return request({
    url: '/admin/dashboard/platform-distribution',
    method: 'get',
    params,
  });
};

export const getTopBooks = (params: { limit?: number } = {}) => {
  return request({
    url: '/admin/dashboard/top-books',
    method: 'get',
    params,
  });
};
