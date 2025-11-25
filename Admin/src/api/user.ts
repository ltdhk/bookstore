import request from '../utils/request';

export const getUsers = (params: any) => {
  return request({
    url: '/admin/users',
    method: 'get',
    params,
  });
};

export const updateUserStatus = (id: number, status: number) => {
  return request({
    url: `/admin/users/${id}/status`,
    method: 'put',
    params: { status },
  });
};

export const deleteUser = (id: number) => {
  return request({
    url: `/admin/users/${id}`,
    method: 'delete',
  });
};
