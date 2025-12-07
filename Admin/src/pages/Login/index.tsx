import React, { useState, useEffect } from 'react';
import { Form, Input, Button, Checkbox, message, Select } from 'antd';
import { UserOutlined, LockOutlined, GlobalOutlined } from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useUserStore } from '../../store/userStore';
import { login } from '../../api/auth';
import './index.css';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const setToken = useUserStore((state) => state.setToken);
  const token = useUserStore((state) => state.token);
  const [loading, setLoading] = useState(false);
  const { t, i18n } = useTranslation();

  const changeLanguage = (lang: string) => {
    i18n.changeLanguage(lang);
    localStorage.setItem('language', lang);
  };

  // 如果已经登录，直接跳转到首页或之前访问的页面
  useEffect(() => {
    if (token) {
      const from = (location.state as any)?.from?.pathname || '/';
      navigate(from, { replace: true });
    }
  }, [token, navigate, location]);

  const onFinish = async (values: any) => {
    setLoading(true);
    try {
      const res = await login(values) as any;
      if (res.code === 200 && res.data?.token) {
        setToken(res.data.token);
        message.success('登录成功');

        // 跳转到之前访问的页面，如果没有则跳转到首页
        const from = (location.state as any)?.from?.pathname || '/';
        navigate(from, { replace: true });
      } else {
        message.error(res.message || '登录失败');
      }
    } catch (error: any) {
      console.error(error);
      const errorMsg = error.response?.data?.message || error.message || '登录失败，请检查用户名和密码';
      message.error(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-left">
        <div className="login-header">
          <div className="logo-icon">📘</div>
          <span className="logo-text">NovelPop Admin</span>
          <Select
            value={i18n.language}
            onChange={changeLanguage}
            style={{ width: 100, marginLeft: 'auto' }}
            size="small"
            options={[
              { value: 'zh', label: '中文' },
              { value: 'en', label: 'English' },
            ]}
            suffixIcon={<GlobalOutlined />}
          />
        </div>
        <div className="login-form-wrapper">
          <h2 className="welcome-text">{t('login.title')}</h2>
          <p className="sub-text">{t('login.username')}</p>
          
          <Form
            name="login"
            layout="vertical"
            onFinish={onFinish}
            initialValues={{ remember: true }}
          >
            <Form.Item
              label={t('login.username')}
              name="username"
              rules={[{ required: true, message: t('login.pleaseInputUsername') }]}
            >
              <Input prefix={<UserOutlined />} placeholder={t('login.pleaseInputUsername')} size="large" />
            </Form.Item>

            <Form.Item
              label={t('login.password')}
              name="password"
              rules={[{ required: true, message: t('login.pleaseInputPassword') }]}
            >
              <Input.Password prefix={<LockOutlined />} placeholder={t('login.pleaseInputPassword')} size="large" />
            </Form.Item>

            <div className="login-options">
              <Form.Item name="remember" valuePropName="checked" noStyle>
                <Checkbox>{t('login.rememberMe')}</Checkbox>
              </Form.Item>
              <a className="forgot-password" href="">{t('login.forgotPassword')}</a>
            </div>

            <Form.Item>
              <Button type="primary" htmlType="submit" block size="large" loading={loading}>
                {t('login.login')}
              </Button>
            </Form.Item>
          </Form>
          
          <div className="footer-text">
            © 2024 Novel Inc. All rights reserved.
          </div>
        </div>
      </div>
      <div className="login-right">
        <div className="analytics-icon">📊</div>
        <h2 className="right-title">Powerful Analytics</h2>
        <p className="right-desc">
          Gain deep insights into your novel's performance, reader engagement, and revenue with our comprehensive analytics dashboard.
        </p>
        <div className="dots">
            <span className="dot active"></span>
            <span className="dot"></span>
            <span className="dot"></span>
        </div>
      </div>
    </div>
  );
};

export default Login;
