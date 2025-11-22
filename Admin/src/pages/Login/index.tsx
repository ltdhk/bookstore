import React, { useState } from 'react';
import { Form, Input, Button, Checkbox, message } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { useUserStore } from '../../store/userStore';
import { login } from '../../api/auth';
import './index.css';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const setToken = useUserStore((state) => state.setToken);
  const [loading, setLoading] = useState(false);

  const onFinish = async (values: any) => {
    setLoading(true);
    try {
      const res = await login(values) as any;
      setToken(res.token);
      message.success('Login successful');
      navigate('/');
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-left">
        <div className="login-header">
          <div className="logo-icon">📘</div>
          <span className="logo-text">Novel Backend</span>
        </div>
        <div className="login-form-wrapper">
          <h2 className="welcome-text">Welcome Back</h2>
          <p className="sub-text">Enter your credentials to access the admin dashboard.</p>
          
          <Form
            name="login"
            layout="vertical"
            onFinish={onFinish}
            initialValues={{ remember: true }}
          >
            <Form.Item
              label="Username or Email"
              name="username"
              rules={[{ required: true, message: 'Please input your username!' }]}
            >
              <Input prefix={<UserOutlined />} placeholder="Enter your username or email" size="large" />
            </Form.Item>

            <Form.Item
              label="Password"
              name="password"
              rules={[{ required: true, message: 'Please input your password!' }]}
            >
              <Input.Password prefix={<LockOutlined />} placeholder="Enter your password" size="large" />
            </Form.Item>

            <div className="login-options">
              <Form.Item name="remember" valuePropName="checked" noStyle>
                <Checkbox>Remember Me</Checkbox>
              </Form.Item>
              <a className="forgot-password" href="">Forgot Password?</a>
            </div>

            <Form.Item>
              <Button type="primary" htmlType="submit" block size="large" loading={loading}>
                Sign In
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
