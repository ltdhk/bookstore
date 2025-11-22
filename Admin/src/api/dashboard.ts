import request from '../utils/request';

export const getDashboardStats = () => {
  return request({
    url: '/dashboard/stats',
    method: 'get',
  });
};
