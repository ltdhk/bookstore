import request from '../utils/request';

export const getDashboardStats = () => {
  return request({
    url: '/admin/dashboard/stats',
    method: 'get',
  });
};
