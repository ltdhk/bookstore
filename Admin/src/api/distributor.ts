import request from '../utils/request';

export const getDistributors = (params: any) => {
  return request({
    url: '/admin/distributors',
    method: 'get',
    params,
  });
};

export const createDistributor = (data: any) => {
  return request({
    url: '/admin/distributors',
    method: 'post',
    data,
  });
};

export const updateDistributor = (id: number, data: any) => {
  return request({
    url: `/admin/distributors/${id}`,
    method: 'put',
    data,
  });
};

export const deleteDistributor = (id: number) => {
  return request({
    url: `/admin/distributors/${id}`,
    method: 'delete',
  });
};

export const getDistributorStats = (id: number) => {
  return request({
    url: `/admin/distributors/${id}/stats`,
    method: 'get',
  });
};

export const getActiveDistributors = () => {
  return request({
    url: '/admin/distributors',
    method: 'get',
    params: {
      page: 1,
      size: 1000,
      status: 1, // Only get active distributors
    },
  });
};
