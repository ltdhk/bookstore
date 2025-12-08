import React, { useEffect, useState } from 'react';
import { Row, Col, Card, Button, Space } from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import {
  getDashboardStats,
  getPasscodeRanking,
  getDistributorRanking,
  getRevenueTrend,
  getTopBooks,
  type DashboardStats,
  type PasscodeRanking,
  type DistributorRevenueRanking,
  type RevenueTrend,
  type TopBook,
} from '../../api/dashboard';
import StatsCards from '../../components/Dashboard/StatsCards';
import DateRangeSelector from '../../components/Dashboard/DateRangeSelector';
import PasscodeRankingTable from '../../components/Dashboard/PasscodeRankingTable';
import DistributorRankingTable from '../../components/Dashboard/DistributorRankingTable';
import RevenueTrendChart from '../../components/Dashboard/RevenueTrendChart';
import OrderTrendChart from '../../components/Dashboard/OrderTrendChart';
import TopBooksChart from '../../components/Charts/TopBooksChart';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    activeUsers: 0,
    totalBooks: 0,
    totalOrders: 0,
    totalRevenue: 0,
  });
  const [passcodeRanking, setPasscodeRanking] = useState<PasscodeRanking[]>([]);
  const [distributorRanking, setDistributorRanking] = useState<DistributorRevenueRanking[]>([]);
  const [revenueTrend, setRevenueTrend] = useState<RevenueTrend[]>([]);
  const [topBooks, setTopBooks] = useState<TopBook[]>([]);

  const [dateRange, setDateRange] = useState<[string, string] | null>([
    dayjs().subtract(30, 'day').format('YYYY-MM-DD HH:mm:ss'),
    dayjs().format('YYYY-MM-DD HH:mm:ss'),
  ]);
  const [loading, setLoading] = useState(false);

  const fetchAllData = async () => {
    setLoading(true);
    try {
      const [statsRes, passcodeRes, distributorRes, trendRes, booksRes]: any = await Promise.all([
        getDashboardStats(),
        getPasscodeRanking({
          startDate: dateRange?.[0],
          endDate: dateRange?.[1],
          limit: 10,
        }),
        getDistributorRanking({
          startDate: dateRange?.[0],
          endDate: dateRange?.[1],
          limit: 10,
        }),
        getRevenueTrend({
          startDate: dateRange?.[0],
          endDate: dateRange?.[1],
        }),
        getTopBooks({ limit: 10 }),
      ]);

      setStats(statsRes.data || stats);
      setPasscodeRanking(passcodeRes.data || []);
      setDistributorRanking(distributorRes.data || []);
      setRevenueTrend(trendRes.data || []);
      setTopBooks(booksRes.data || []);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
  }, [dateRange]);

  const cardStyle = {
    borderRadius: 12,
    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)',
  };

  return (
    <div style={{ padding: '24px', background: '#fff', minHeight: '100vh' }}>
      <div style={{
        marginBottom: 24,
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingBottom: 16,
        borderBottom: '1px solid #f0f0f0',
      }}>
        <h2 style={{ margin: 0, fontSize: 24, fontWeight: 600, color: '#262626' }}>数据看板</h2>
        <Space size="middle">
          <DateRangeSelector onChange={setDateRange} />
          <Button
            icon={<ReloadOutlined />}
            onClick={fetchAllData}
            type="primary"
            style={{ borderRadius: 6 }}
          >
            刷新
          </Button>
        </Space>
      </div>

      <StatsCards stats={stats} loading={loading} />

      <div style={{ marginTop: 24 }}>
        <Row gutter={[16, 16]}>
          <Col xs={24} xl={12}>
            <Card
              bordered={false}
              style={cardStyle}
              bodyStyle={{ padding: '24px' }}
            >
              <h3 style={{ margin: '0 0 16px 0', fontSize: 18, fontWeight: 600, color: '#262626' }}>
                收益趋势
              </h3>
              <RevenueTrendChart data={revenueTrend} />
            </Card>
          </Col>
          <Col xs={24} xl={12}>
            <Card
              bordered={false}
              style={cardStyle}
              bodyStyle={{ padding: '24px' }}
            >
              <h3 style={{ margin: '0 0 16px 0', fontSize: 18, fontWeight: 600, color: '#262626' }}>
                订单趋势
              </h3>
              <OrderTrendChart data={revenueTrend} />
            </Card>
          </Col>
        </Row>
      </div>

      <div style={{ marginTop: 24 }}>
        <Row gutter={[16, 16]}>
          <Col xs={24} xl={12}>
            <PasscodeRankingTable data={passcodeRanking} loading={loading} />
          </Col>
          <Col xs={24} xl={12}>
            <DistributorRankingTable data={distributorRanking} loading={loading} />
          </Col>
        </Row>
      </div>

      <div style={{ marginTop: 24 }}>
        <Card
          bordered={false}
          style={cardStyle}
          bodyStyle={{ padding: '24px' }}
        >
          <h3 style={{ margin: '0 0 16px 0', fontSize: 18, fontWeight: 600, color: '#262626' }}>
            热门书籍 Top 10
          </h3>
          <TopBooksChart data={topBooks} />
        </Card>
      </div>
    </div>
  );
};

export default Dashboard;
