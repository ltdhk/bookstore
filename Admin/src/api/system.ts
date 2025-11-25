import request from '../utils/request';

// System Configs
export const getSystemConfigs = () => {
  return request({
    url: '/admin/system/configs',
    method: 'get',
  });
};

export const saveSystemConfig = (data: any) => {
  return request({
    url: '/admin/system/configs',
    method: 'post',
    data,
  });
};

// Admin Users
export const getAdminUsers = (params: any) => {
  return request({
    url: '/admin/system/users',
    method: 'get',
    params,
  });
};

export const createAdminUser = (data: any) => {
  return request({
    url: '/admin/system/users',
    method: 'post',
    data,
  });
};

export const updateAdminUser = (id: number, data: any) => {
  return request({
    url: `/admin/system/users/${id}`,
    method: 'put',
    data,
  });
};

export const deleteAdminUser = (id: number) => {
  return request({
    url: `/admin/system/users/${id}`,
    method: 'delete',
  });
};

export const getOperationLogs = (params: any) => {
  return request({
    url: '/admin/system/logs',
    method: 'get',
    params,
  });
};
