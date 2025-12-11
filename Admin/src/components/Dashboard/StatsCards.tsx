import React from 'react';
import { Card, Col, Row, Statistic } from 'antd';
import { UserOutlined, BookOutlined, DollarOutlined, ShoppingOutlined, RiseOutlined } from '@ant-design/icons';
import type { DashboardStats } from '../../api/dashboard';

interface StatsCardsProps {
  stats: DashboardStats;
  loading: boolean;
}

const StatsCards: React.FC<StatsCardsProps> = ({ stats, loading }) => {
  const cardStyle = {
    borderRadius: 12,
    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)',
  };

  return (
    <Row gutter={[16, 16]}>
      <Col xs={24} sm={12} lg={4}>
        <Card loading={loading} bordered={false} style={cardStyle}>
          <Statistic
            title="总用户数"
            value={stats.totalUsers || 0}
            prefix={<UserOutlined style={{ color: '#1890ff' }} />}
            valueStyle={{ color: '#262626', fontSize: 28, fontWeight: 600 }}
          />
        </Card>
      </Col>
      <Col xs={24} sm={12} lg={4}>
        <Card loading={loading} bordered={false} style={cardStyle}>
          <Statistic
            title="书籍总数"
            value={stats.totalBooks || 0}
            prefix={<BookOutlined style={{ color: '#52c41a' }} />}
            valueStyle={{ color: '#262626', fontSize: 28, fontWeight: 600 }}
          />
        </Card>
      </Col>
      <Col xs={24} sm={12} lg={4}>
        <Card loading={loading} bordered={false} style={cardStyle}>
          <Statistic
            title="总订单数"
            value={stats.totalOrders || 0}
            prefix={<ShoppingOutlined style={{ color: '#faad14' }} />}
            valueStyle={{ color: '#262626', fontSize: 28, fontWeight: 600 }}
          />
        </Card>
      </Col>
      <Col xs={24} sm={12} lg={6}>
        <Card loading={loading} bordered={false} style={cardStyle}>
          <Statistic
            title="总收益"
            value={stats.totalRevenue || 0}
            precision={2}
            prefix="¥"
            suffix={<DollarOutlined style={{ fontSize: 20, marginLeft: 4 }} />}
            valueStyle={{ color: '#f5222d', fontSize: 28, fontWeight: 600 }}
          />
        </Card>
      </Col>
      <Col xs={24} sm={12} lg={6}>
        <Card loading={loading} bordered={false} style={cardStyle}>
          <Statistic
            title="今日收益"
            value={stats.todayRevenue || 0}
            precision={2}
            prefix="¥"
            suffix={<RiseOutlined style={{ fontSize: 20, marginLeft: 4 }} />}
            valueStyle={{ color: '#52c41a', fontSize: 28, fontWeight: 600 }}
          />
        </Card>
      </Col>
    </Row>
  );
};

export default StatsCards;
