import React, { useEffect, useState } from 'react';
import { Card, Col, Row, Statistic } from 'antd';
import { UserOutlined, BookOutlined, DollarOutlined, ReadOutlined } from '@ant-design/icons';
import { getDashboardStats } from '../../api/dashboard';
import RevenueChart from '../../components/Charts/RevenueChart';
import TopBooksChart from '../../components/Charts/TopBooksChart';
import UserMapChart from '../../components/Charts/UserMapChart';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<any>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchStats = async () => {
      setLoading(true);
      try {
        const res: any = await getDashboardStats();
        setStats(res.data || {});
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
        <Row gutter={24}>
          <Col span={16}>
            <div style={{ background: '#fff', padding: 24, borderRadius: 8 }}>
              <h3>收入趋势</h3>
              <RevenueChart />
            </div>
          </Col>
          <Col span={8}>
            <div style={{ background: '#fff', padding: 24, borderRadius: 8 }}>
              <h3>用户分布</h3>
              <UserMapChart />
            </div>
          </Col>
        </Row>
      </div>

      <div style={{ marginTop: 24 }}>
        <div style={{ background: '#fff', padding: 24, borderRadius: 8 }}>
          <h3>热门书籍 Top 10</h3>
          <TopBooksChart />
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
