import React, { useEffect, useState } from 'react';
import {
  Table,
  Card,
  DatePicker,
  Space,
  Button,
  Statistic,
  Row,
  Col,
  Tag,
  message,
} from 'antd';
import { SearchOutlined, DollarOutlined, UserOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { getDistributorsRevenueReport } from '../../api/subscription';

const { RangePicker } = DatePicker;

interface DistributorRevenueItem {
  distributorId: number;
  distributorName: string;
  distributorCode: string;
  commissionRate: number;
  orderCount: number;
  totalRevenue: number;
  distributorCommission: number;
}

const DistributorRevenue: React.FC = () => {
  const [data, setData] = useState<DistributorRevenueItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [dateRange, setDateRange] = useState<any>(null);
  const [stats, setStats] = useState({
    totalDistributors: 0,
    totalOrders: 0,
    totalRevenue: 0,
    totalCommission: 0,
  });

  // 获取报表数据
  const fetchReport = async (params?: any) => {
    setLoading(true);
    try {
      const res: any = await getDistributorsRevenueReport(params);
      if (res.code === 200) {
        const reportData = res.data || [];
        setData(reportData);

        // 计算统计数据
        const totalOrders = reportData.reduce((sum: number, item: DistributorRevenueItem) => sum + item.orderCount, 0);
        const totalRevenue = reportData.reduce((sum: number, item: DistributorRevenueItem) => sum + item.totalRevenue, 0);
        const totalCommission = reportData.reduce((sum: number, item: DistributorRevenueItem) => sum + item.distributorCommission, 0);

        setStats({
          totalDistributors: reportData.length,
          totalOrders,
          totalRevenue,
          totalCommission,
        });
      }
    } catch (error) {
      message.error('获取报表数据失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReport();
  }, []);

  // 搜索
  const handleSearch = () => {
    const params: any = {};
    if (dateRange && dateRange.length === 2) {
      params.startDate = dateRange[0].format('YYYY-MM-DD');
      params.endDate = dateRange[1].format('YYYY-MM-DD');
    }
    fetchReport(params);
  };

  // 重置
  const handleReset = () => {
    setDateRange(null);
    fetchReport();
  };

  // 表格列定义
  const columns: ColumnsType<DistributorRevenueItem> = [
    {
      title: '分销商ID',
      dataIndex: 'distributorId',
      key: 'distributorId',
      width: 100,
    },
    {
      title: '分销商名称',
      dataIndex: 'distributorName',
      key: 'distributorName',
      width: 150,
    },
    {
      title: '分销码',
      dataIndex: 'distributorCode',
      key: 'distributorCode',
      width: 150,
    },
    {
      title: '分成比例',
      dataIndex: 'commissionRate',
      key: 'commissionRate',
      width: 120,
      render: (rate: number) => (
        <Tag color="blue">{rate.toFixed(2)}%</Tag>
      ),
    },
    {
      title: '订单数量',
      dataIndex: 'orderCount',
      key: 'orderCount',
      width: 120,
      sorter: (a, b) => a.orderCount - b.orderCount,
    },
    {
      title: '总营收',
      dataIndex: 'totalRevenue',
      key: 'totalRevenue',
      width: 150,
      render: (revenue: number) => `$${revenue.toFixed(2)}`,
      sorter: (a, b) => a.totalRevenue - b.totalRevenue,
    },
    {
      title: '分销商收益',
      dataIndex: 'distributorCommission',
      key: 'distributorCommission',
      width: 150,
      render: (commission: number) => (
        <span style={{ color: '#52c41a', fontWeight: 'bold' }}>
          ${commission.toFixed(2)}
        </span>
      ),
      sorter: (a, b) => a.distributorCommission - b.distributorCommission,
    },
  ];

  return (
    <div>
      {/* 统计卡片 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="分销商总数"
              value={stats.totalDistributors}
              prefix={<UserOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="总订单数"
              value={stats.totalOrders}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="总营收"
              value={stats.totalRevenue}
              prefix={<DollarOutlined />}
              precision={2}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="总分成支出"
              value={stats.totalCommission}
              prefix={<DollarOutlined />}
              precision={2}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 筛选条件 */}
      <Card style={{ marginBottom: 24 }}>
        <Space>
          <RangePicker
            value={dateRange}
            onChange={setDateRange}
            placeholder={['开始日期', '结束日期']}
          />
          <Button
            type="primary"
            icon={<SearchOutlined />}
            onClick={handleSearch}
          >
            搜索
          </Button>
          <Button onClick={handleReset}>重置</Button>
        </Space>
      </Card>

      {/* 报表数据表格 */}
      <Card title="分销商收益明细">
        <Table
          columns={columns}
          dataSource={data}
          rowKey="distributorId"
          loading={loading}
          pagination={{
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `共 ${total} 条`,
          }}
          summary={(pageData) => {
            const totalOrders = pageData.reduce((sum, item) => sum + item.orderCount, 0);
            const totalRevenue = pageData.reduce((sum, item) => sum + item.totalRevenue, 0);
            const totalCommission = pageData.reduce((sum, item) => sum + item.distributorCommission, 0);

            return (
              <Table.Summary.Row style={{ backgroundColor: '#fafafa' }}>
                <Table.Summary.Cell index={0} colSpan={4}>
                  <strong>当前页合计</strong>
                </Table.Summary.Cell>
                <Table.Summary.Cell index={1}>
                  <strong>{totalOrders}</strong>
                </Table.Summary.Cell>
                <Table.Summary.Cell index={2}>
                  <strong>${totalRevenue.toFixed(2)}</strong>
                </Table.Summary.Cell>
                <Table.Summary.Cell index={3}>
                  <strong style={{ color: '#52c41a' }}>
                    ${totalCommission.toFixed(2)}
                  </strong>
                </Table.Summary.Cell>
              </Table.Summary.Row>
            );
          }}
        />
      </Card>
    </div>
  );
};

export default DistributorRevenue;
