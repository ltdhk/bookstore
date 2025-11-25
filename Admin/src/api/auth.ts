import request from '../utils/request';

export const login = (data: any) => {
  return request({
    url: '/admin/auth/login',
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
 * 退出登录
 */
export const logout = () => {
  return request({
    url: '/admin/auth/logout',
    method: 'post'
  });
};
