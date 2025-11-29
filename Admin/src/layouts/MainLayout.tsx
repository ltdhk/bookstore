import React, { useState } from 'react';
import { Layout, Menu, Avatar, Dropdown, message, Modal, Select } from 'antd';
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
  ExclamationCircleOutlined,
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

const { Header, Sider, Content } = Layout;

const MainLayout: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const logout = useUserStore((state) => state.logout);
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

  const menuItems = [
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

  const handleLogout = () => {
    Modal.confirm({
      title: t('common.confirmLogout'),
      icon: <ExclamationCircleOutlined />,
      content: t('common.confirmLogoutMsg'),
      okText: t('common.confirm'),
      cancelText: t('common.cancel'),
      onOk: async () => {
        try {
          // 调用后端退出接口（可选）
          await logoutApi();
        } catch (error) {
          // 即使后端退出失败，也清除本地token
          console.error('Logout API failed:', error);
        } finally {
          // 清除本地存储
          logout();
          message.success(t('common.logoutSuccess'));
          // 跳转到登录页
          navigate('/login', { replace: true });
        }
      }
    });
  };

  const userMenu = (
    <Menu onClick={({ key }) => {
        if (key === 'logout') {
            handleLogout();
        }
    }}>
      <Menu.Item key="logout" icon={<LogoutOutlined />}>
        {t('common.logout')}
      </Menu.Item>
    </Menu>
  );

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider trigger={null} collapsible collapsed={collapsed} theme="light">
        <div className="logo" style={{ height: 64, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20, fontWeight: 'bold', color: '#1890ff' }}>
          {collapsed ? 'NB' : 'Novel Next'}
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
            <Dropdown overlay={userMenu} placement="bottomRight">
              <div style={{ cursor: 'pointer', display: 'flex', alignItems: 'center' }}>
                  <Avatar icon={<UserOutlined />} style={{ marginRight: 8 }} />
                  <span>Admin</span>
              </div>
            </Dropdown>
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
