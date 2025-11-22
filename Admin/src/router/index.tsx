import { createBrowserRouter, Navigate } from 'react-router-dom';
import Login from '../pages/Login';
import Dashboard from '../pages/Dashboard';
import BookManagement from '../pages/Book';
import UserManagement from '../pages/User';
import MainLayout from '../layouts/MainLayout';

const router = createBrowserRouter([
  {
    path: '/login',
    element: <Login />,
  },
  {
    path: '/',
    element: <MainLayout />,
    children: [
      {
        path: '/',
        element: <Dashboard />,
      },
      {
        path: '/book',
        element: <BookManagement />,
      },
      {
        path: '/user',
        element: <UserManagement />,
      },
      {
        path: '/order',
        element: <div>订单管理 (开发中)</div>,
      },
      {
        path: '/distributor',
        element: <div>分销管理 (开发中)</div>,
      },
      {
        path: '/system',
        element: <div>系统管理 (开发中)</div>,
      },
    ],
  },
  {
    path: '*',
    element: <Navigate to="/" replace />,
  },
]);

export default router;
