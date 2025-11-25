import request from '../utils/request';

export interface Advertisement {
  id?: number;
  title: string;
  imageUrl: string;
  targetType: string; // 'book' | 'url' | 'none'
  targetId?: number;
  targetUrl?: string;
  position: string;
  sortOrder: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

// 获取广告列表
export const getAdvertisements = (params?: {
  page?: number;
  size?: number;
  position?: string;
  isActive?: boolean;
}) => {
  return request({
    url: '/admin/advertisements',
    method: 'get',
    params,
  });
};

// 获取广告详情
export const getAdvertisement = (id: number) => {
  return request({
    url: `/admin/advertisements/${id}`,
    method: 'get',
  });
};

// 创建广告
export const createAdvertisement = (data: Advertisement) => {
  return request({
    url: '/admin/advertisements',
    method: 'post',
    data,
  });
};

// 更新广告
export const updateAdvertisement = (id: number, data: Advertisement) => {
  return request({
    url: `/admin/advertisements/${id}`,
    method: 'put',
    data,
  });
};

// 删除广告
export const deleteAdvertisement = (id: number) => {
  return request({
    url: `/admin/advertisements/${id}`,
    method: 'delete',
  });
};

// 切换广告状态
export const toggleAdvertisementStatus = (id: number) => {
  return request({
    url: `/admin/advertisements/${id}/toggle`,
    method: 'put',
  });
};

// 获取活跃广告（客户端使用）
export const getActiveAdvertisements = (params?: {
  position?: string;
}) => {
  return request({
    url: '/admin/advertisements/active',
    method: 'get',
    params,
  });
};
