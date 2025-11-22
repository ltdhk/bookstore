import React, { useEffect, useState } from 'react';
import { Card, Col, Row, Statistic } from 'antd';
import { UserOutlined, BookOutlined, DollarOutlined, ReadOutlined } from '@ant-design/icons';
import { getDashboardStats } from '../../api/dashboard';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<any>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchStats = async () => {
      setLoading(true);
      try {
        const res = await getDashboardStats();
        setStats(res);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  return (
    <div>
      <Row gutter={16}>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="活跃用户"
              value={stats.activeUsers || 0}
              prefix={<UserOutlined />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="书籍总数"
              value={stats.totalBooks || 0}
              prefix={<BookOutlined />}
              valueStyle={{ color: '#cf1322' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="总收入"
              value={stats.totalRevenue || 0}
              precision={2}
              prefix={<DollarOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={loading}>
            <Statistic
              title="阅读时长 (小时)"
              value={stats.readingTime || 0}
              prefix={<ReadOutlined />}
            />
          </Card>
        </Col>
      </Row>
      
      <div style={{ marginTop: 24 }}>
        <h3>收入趋势</h3>
        <div style={{ height: 300, background: '#f0f2f5', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            图表占位符 (可使用 ECharts)
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
