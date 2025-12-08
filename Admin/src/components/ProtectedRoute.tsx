import React, { useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { Spin } from 'antd';
import { useUserStore } from '../store/userStore';
import { MENU_PERMISSIONS } from '../config/permissions';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredPermissions?: string[];
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, requiredPermissions }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);
  const location = useLocation();
  const { permissions, logout } = useUserStore();

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = () => {
    const token = localStorage.getItem('admin_token');

    if (!token) {
      setIsAuthenticated(false);
      return;
    }

    // Token存在，验证是否有效
    // 可以选择调用后端API验证，或者只检查token是否过期
    try {
      // 简单验证：检查token格式和是否过期
      const tokenParts = token.split('.');
      if (tokenParts.length !== 3) {
        // 无效的JWT格式
        logout();
        setIsAuthenticated(false);
        return;
      }

      // 解析token payload检查过期时间
      const payload = JSON.parse(atob(tokenParts[1]));
      const currentTime = Math.floor(Date.now() / 1000);

      if (payload.exp && payload.exp < currentTime) {
        // Token已过期
        logout();
        setIsAuthenticated(false);
        return;
      }

      setIsAuthenticated(true);
    } catch (error) {
      // Token解析失败
      logout();
      setIsAuthenticated(false);
    }
  };

  // 加载中状态
  if (isAuthenticated === null) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh'
      }}>
        <Spin size="large" tip="验证登录状态..." />
      </div>
    );
  }

  // 未登录，重定向到登录页
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // 检查路由权限
  // 如果指定了 requiredPermissions，使用它；否则使用路径对应的权限
  const permsToCheck = requiredPermissions || MENU_PERMISSIONS[location.pathname];
  if (permsToCheck && permsToCheck.length > 0) {
    // 检查是否有任意一个权限
    const hasAccess = permissions.includes('*') || permsToCheck.some(p => permissions.includes(p));
    if (!hasAccess) {
      // 无权限，重定向到首页
      return <Navigate to="/" replace />;
    }
  }

  // 已登录且有权限，渲染子组件
  return <>{children}</>;
};

export default ProtectedRoute;
