import request from '../utils/request';

// 订阅订单相关接口
export interface SubscriptionOrder {
  id: number;
  userId: number;
  distributorId?: number;
  sourcePasscodeId?: number;
  orderNo: string;
  amount: number;
  status: string;
  platform: string;
  productId: string;
  orderType: string;
  subscriptionPeriod: string;
  subscriptionStartDate: string;
  subscriptionEndDate: string;
  isAutoRenew: boolean;
  cancelDate?: string;
  cancelReason?: string;
  originalTransactionId: string;
  platformTransactionId: string;
  purchaseToken?: string;
  receiptData?: string;
  sourceBookId?: number;
  sourceEntry?: string;
  createTime: string;
  updateTime: string;
}

export interface SubscriptionProduct {
  id: number;
  productId: string;
  productName: string;
  planType: string;
  durationDays: number;
  price: number;
  currency: string;
  platform: string;
  appleProductId?: string;
  googleProductId?: string;
  isActive: boolean;
  sortOrder: number;
  description?: string;
  features?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface SubscriptionStats {
  totalSubscriptions: number;
  activeSubscriptions: number;
  cancelledSubscriptions: number;
  expiredSubscriptions: number;
  totalRevenue: number;
  revenueByPlatform: { [key: string]: number };
  revenueByPeriod: { [key: string]: number };
  subscriptionsByPlan: { [key: string]: number };
  subscriptionsBySource: { [key: string]: number };
}

// 获取订阅订单列表
export const getSubscriptionOrders = (params: {
  page?: number;
  size?: number;
  status?: string;
  platform?: string;
  subscriptionPeriod?: string;
  username?: string;
  distributorId?: number;
  startDate?: string;
  endDate?: string;
}) => {
  return request({
    url: '/admin/subscriptions',
    method: 'get',
    params,
  });
};

// 获取订阅订单详情
export const getSubscriptionDetail = (id: number) => {
  return request({
    url: `/admin/subscriptions/${id}`,
    method: 'get',
  });
};

// 强制取消订阅
export const forceCancelSubscription = (id: number, reason?: string) => {
  return request({
    url: `/admin/subscriptions/${id}/cancel`,
    method: 'put',
    params: { reason },
  });
};

// 获取订阅统计数据
export const getSubscriptionStats = (params?: {
  startDate?: string;
  endDate?: string;
}) => {
  return request({
    url: '/admin/subscriptions/stats',
    method: 'get',
    params,
  });
};

// 根据分销商ID获取订阅
export const getSubscriptionsByDistributor = (
  distributorId: number,
  params?: {
    page?: number;
    size?: number;
  }
) => {
  return request({
    url: `/admin/subscriptions/by-distributor/${distributorId}`,
    method: 'get',
    params,
  });
};

// 订阅产品管理相关接口

// 获取订阅产品列表
export const getSubscriptionProducts = (params?: {
  platform?: string;
  isActive?: boolean;
}) => {
  return request({
    url: '/admin/subscriptions/products',
    method: 'get',
    params,
  });
};

// 创建订阅产品
export const createSubscriptionProduct = (data: Partial<SubscriptionProduct>) => {
  return request({
    url: '/admin/subscriptions/products',
    method: 'post',
    data,
  });
};

// 更新订阅产品
export const updateSubscriptionProduct = (
  id: number,
  data: Partial<SubscriptionProduct>
) => {
  return request({
    url: `/admin/subscriptions/products/${id}`,
    method: 'put',
    data,
  });
};

// 删除订阅产品
export const deleteSubscriptionProduct = (id: number) => {
  return request({
    url: `/admin/subscriptions/products/${id}`,
    method: 'delete',
  });
};

// 切换产品激活状态
export const toggleProductStatus = (id: number) => {
  return request({
    url: `/admin/subscriptions/products/${id}/toggle`,
    method: 'put',
  });
};

// 获取分销商收益报表
export const getDistributorsRevenueReport = (params?: {
  startDate?: string;
  endDate?: string;
}) => {
  return request({
    url: '/admin/subscriptions/distributors/revenue-report',
    method: 'get',
    params,
  });
};
