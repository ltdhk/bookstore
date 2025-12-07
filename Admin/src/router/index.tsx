import { createBrowserRouter, Navigate } from 'react-router-dom';
import Login from '../pages/Login';
import Dashboard from '../pages/Dashboard';
import BookManagement from '../pages/Book';
import BookImport from '../pages/Book/Import';
import CoverManagement from '../pages/Book/CoverManagement';
import UserManagement from '../pages/User';
import DistributorManagement from '../pages/Distributor';
import SystemManagement from '../pages/System';
import SubscriptionManagement from '../pages/Subscription';
import ProductManagement from '../pages/Subscription/ProductManagement';
import DistributorRevenue from '../pages/Subscription/DistributorRevenue';
import AdvertisementManagement from '../pages/Advertisement';
import PasscodeManagement from '../pages/Passcode';
import MainLayout from '../layouts/MainLayout';
import ProtectedRoute from '../components/ProtectedRoute';

const router = createBrowserRouter(
  [
    {
      path: '/login',
      element: <Login />,
    },
    {
      path: '/',
      element: (
        <ProtectedRoute>
          <MainLayout />
        </ProtectedRoute>
      ),
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
          path: '/book/import',
          element: <BookImport />,
        },
        {
          path: '/book/cover-management',
          element: <CoverManagement />,
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
          path: '/subscription',
          element: <SubscriptionManagement />,
        },
        {
          path: '/subscription/products',
          element: <ProductManagement />,
        },
        {
          path: '/subscription/distributor-revenue',
          element: <DistributorRevenue />,
        },
        {
          path: '/distributor',
          element: <DistributorManagement />,
        },
        {
          path: '/system',
          element: <SystemManagement />,
        },
        {
          path: '/advertisement',
          element: <AdvertisementManagement />,
        },
        {
          path: '/passcode',
          element: <PasscodeManagement />,
        },
      ],
    },
    {
      path: '*',
      element: <Navigate to="/" replace />,
    },
  ],
  {
    basename: '/admin',
  }
);

export default router;
