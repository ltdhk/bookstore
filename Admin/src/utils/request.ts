import axios from 'axios';
import { message } from 'antd';

const request = axios.create({
  baseURL: '/api', // Proxy will handle this
  timeout: 10000,
});

request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

request.interceptors.response.use(
  (response) => {
    const res = response.data;
    // 只处理401未授权错误，其他错误由业务代码处理
    if (res.code === 401) {
      message.error(res.message || '登录已过期，请重新登录');
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_user');
      // 延迟跳转，确保消息提示显示
      setTimeout(() => {
        window.location.href = '/login';
      }, 500);
      return Promise.reject(new Error(res.message || 'Unauthorized'));
    }
    // 返回完整的响应对象，让业务代码自己判断code和处理错误
    return res;
  },
  (error) => {
    // 处理HTTP状态码错误
    if (error.response) {
      const { status } = error.response;

      if (status === 401) {
        message.error('登录已过期，请重新登录');
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        setTimeout(() => {
          window.location.href = '/login';
        }, 500);
      } else if (status === 403) {
        message.error('没有权限访问');
      } else if (status === 404) {
        message.error('请求的资源不存在');
      } else if (status === 500) {
        message.error('服务器错误，请稍后重试');
      } else {
        message.error(error.response.data?.message || 'Error');
      }
    } else if (error.request) {
      message.error('网络错误，请检查网络连接');
    } else {
      message.error(error.message || 'Network Error');
    }
    return Promise.reject(error);
  }
);

export default request;
