import request from '../utils/request';

export type UserInfo = {
  id?: number;
  username?: string;
  password?: string;
  nickname?: string;
  email?: string;
  phone?: string;
  avatar?: string;
  coins?: number;
  bonus?: number;
  isSvip?: boolean;
  subscriptionStatus?: string;
  subscriptionEndDate?: string;
  subscriptionPlanType?: string;
  deleted?: number;
}

export const getUsers = (params: { page?: number; size?: number; username?: string }) => {
  return request({
    url: '/admin/users',
    method: 'get',
    params,
  });
};

export const getUserById = (id: number) => {
  return request({
    url: `/admin/users/${id}`,
    method: 'get',
  });
};

export const createUser = (data: UserInfo) => {
  return request({
    url: '/admin/users',
    method: 'post',
    data,
  });
};

export const updateUser = (id: number, data: UserInfo) => {
  return request({
    url: `/admin/users/${id}`,
    method: 'put',
    data,
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
