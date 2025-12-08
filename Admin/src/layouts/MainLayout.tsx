import React, { useState, useMemo } from 'react';
import { Layout, Menu, Avatar, message, Select } from 'antd';
import type { MenuProps } from 'antd';
import {
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  DashboardOutlined,
  BookOutlined,
  UserOutlined,
  ShoppingCartOutlined,
  ShopOutlined,
  SettingOutlined,
  LogoutOutlined,
  GlobalOutlined,
  CrownOutlined,
  TagsOutlined,
  DollarOutlined,
  PictureOutlined,
  KeyOutlined,
  UploadOutlined,
} from '@ant-design/icons';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useUserStore } from '../store/userStore';
import { logout as logoutApi } from '../api/auth';
import { MENU_PERMISSIONS } from '../config/permissions';

const { Header, Sider, Content } = Layout;

type MenuItem = Required<MenuProps>['items'][number] & {
  children?: MenuItem[];
};

const MainLayout: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { logout, hasPermission, userInfo, role } = useUserStore();
  const { t, i18n } = useTranslation();

  const changeLanguage = (lang: string) => {
    i18n.changeLanguage(lang);
    localStorage.setItem('language', lang);
  };

  const handleMenuClick = ({ key }: { key: string }) => {
    if (key === 'logout') {
      logout();
      navigate('/login');
    } else {
      navigate(key);
    }
  };

  // 检查用户是否有权限访问指定菜单
  const canAccessMenu = (key: string): boolean => {
    const requiredPerms = MENU_PERMISSIONS[key];
    if (!requiredPerms) return true; // 未配置权限要求的菜单默认允许
    return requiredPerms.some((perm) => hasPermission(perm));
  };

  // 所有菜单项定义
  const allMenuItems: MenuItem[] = [
    {
      key: '/',
      icon: <DashboardOutlined />,
      label: t('menu.dashboard'),
    },
    {
      key: '/book',
      icon: <BookOutlined />,
      label: t('menu.bookManagement'),
      children: [
        {
          key: '/book',
          icon: <BookOutlined />,
          label: '书籍列表',
        },
        {
          key: '/book/import',
          icon: <UploadOutlined />,
          label: '批量导入',
        },
        {
          key: '/book/cover-management',
          icon: <PictureOutlined />,
          label: '封面管理',
        },
      ],
    },
    {
      key: '/user',
      icon: <UserOutlined />,
      label: t('menu.userManagement'),
    },
    {
      key: '/subscription',
      icon: <CrownOutlined />,
      label: '订阅管理',
      children: [
        {
          key: '/subscription',
          icon: <ShoppingCartOutlined />,
          label: '订阅订单',
        },
        {
          key: '/subscription/products',
          icon: <TagsOutlined />,
          label: '订阅产品',
        },
        {
          key: '/subscription/distributor-revenue',
          icon: <DollarOutlined />,
          label: '分销商收益',
        },
      ],
    },
    {
      key: '/distributor',
      icon: <ShopOutlined />,
      label: t('menu.distribution'),
    },
    {
      key: '/advertisement',
      icon: <PictureOutlined />,
      label: '广告管理',
    },
    {
      key: '/passcode',
      icon: <KeyOutlined />,
      label: '口令管理',
    },
    {
      key: '/system',
      icon: <SettingOutlined />,
      label: t('menu.system'),
    },
  ];

  // 根据权限过滤菜单项
  const menuItems = useMemo(() => {
    const filterMenuItems = (items: MenuItem[]): MenuItem[] => {
      return items
        .filter((item) => {
          const key = item?.key as string;
          return canAccessMenu(key);
        })
        .map((item) => {
          if (item.children && Array.isArray(item.children)) {
            const filteredChildren = filterMenuItems(item.children);
            // 如果子菜单全部被过滤掉，则不显示父菜单
            if (filteredChildren.length === 0) {
              return null;
            }
            return { ...item, children: filteredChildren };
          }
          return item;
        })
        .filter(Boolean) as MenuItem[];
    };
    return filterMenuItems(allMenuItems);
  }, [role, t]); // 依赖 role 变化时重新计算

  // 获取显示的用户名
  const displayName = useMemo(() => {
    if (userInfo?.displayName) return userInfo.displayName;
    if (role === 'distributor') return '分销商';
    return 'Admin';
  }, [userInfo, role]);

  const handleLogout = async () => {
    // 直接执行退出
    try {
      await logoutApi();
    } catch (error) {
      console.error('Logout API failed:', error);
    }

    // 清除本地存储
    logout();
    message.success('退出成功');

    // 跳转到登录页（使用完整路径强制刷新页面）
    window.location.href = '/admin/login';
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider trigger={null} collapsible collapsed={collapsed} theme="light">
        <div className="logo" style={{ height: 64, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 'bold', color: '#1890ff' }}>
          {collapsed ? 'Novel' : 'Novel Admin'}
        </div>
        <Menu
          theme="light"
          mode="inline"
          selectedKeys={[location.pathname]}
          items={menuItems}
          onClick={handleMenuClick}
        />
      </Sider>
      <Layout className="site-layout">
        <Header className="site-layout-background" style={{ padding: '0 24px', background: '#fff', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          {React.createElement(collapsed ? MenuUnfoldOutlined : MenuFoldOutlined, {
            className: 'trigger',
            onClick: () => setCollapsed(!collapsed),
            style: { fontSize: 18, cursor: 'pointer' }
          })}

          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <Select
              value={i18n.language}
              onChange={changeLanguage}
              style={{ width: 120 }}
              options={[
                { value: 'zh', label: '中文' },
                { value: 'en', label: 'English' },
              ]}
              suffixIcon={<GlobalOutlined />}
            />
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <Avatar icon={<UserOutlined />} />
              <span>{displayName}</span>
              <span
                style={{ cursor: 'pointer', padding: '4px 8px', display: 'flex', alignItems: 'center' }}
                onClick={() => {
                  console.log('Logout icon clicked');
                  handleLogout();
                }}
                title={t('common.logout') || '退出登录'}
              >
                <LogoutOutlined style={{ fontSize: 16, color: '#999' }} />
              </span>
            </div>
          </div>
        </Header>
        <Content
          className="site-layout-background"
          style={{
            margin: '24px 16px',
            padding: 24,
            minHeight: 280,
            background: '#fff',
            borderRadius: 8
          }}
        >
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
};

export default MainLayout;
