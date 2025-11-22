import axios from 'axios';
import { message } from 'antd';

const request = axios.create({
  baseURL: '/api/admin', // Proxy will handle this
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
    if (res.code !== 200) {
      message.error(res.message || 'Error');
      if (res.code === 401) {
        // Handle unauthorized
        localStorage.removeItem('admin_token');
        window.location.href = '/login';
      }
      return Promise.reject(new Error(res.message || 'Error'));
    }
    return res.data;
  },
  (error) => {
    message.error(error.message || 'Network Error');
    return Promise.reject(error);
  }
);

export default request;
