import request from '../utils/request';

/**
 * 管理员登录
 */
export const login = (data: { username: string; password: string }) => {
  return request({
    url: '/admin/auth/login',
    method: 'post',
    data,
  });
};

/**
 * 分销商登录
 */
export const distributorLogin = (data: { username: string; password: string }) => {
  return request({
    url: '/admin/auth/distributor-login',
    method: 'post',
    data,
  });
};

export const initAdmin = () => {
  return request({
    url: '/admin/auth/init',
    method: 'post'
  });
};

/**
 * 验证当前token是否有效
 */
export const verifyToken = () => {
  return request({
    url: '/admin/auth/verify',
    method: 'get'
  });
};

/**
 * 获取当前用户信息和权限
 */
export const getUserInfo = () => {
  return request({
    url: '/admin/auth/user-info',
    method: 'get'
  });
};

/**
 * 退出登录
 */
export const logout = () => {
  return request({
    url: '/admin/auth/logout',
    method: 'post'
  });
};
