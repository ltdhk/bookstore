import React from 'react';
import { Table, Card, Progress } from 'antd';
import { CrownOutlined } from '@ant-design/icons';
import type { DistributorRevenueRanking } from '../../api/dashboard';

interface DistributorRankingTableProps {
  data: DistributorRevenueRanking[];
  loading: boolean;
}

const DistributorRankingTable: React.FC<DistributorRankingTableProps> = ({ data, loading }) => {
  const maxCommission = Math.max(...data.map(d => d.distributorCommission), 0);

  const getRankColor = (rank: number) => {
    if (rank === 1) return '#FFD700';
    if (rank === 2) return '#C0C0C0';
    if (rank === 3) return '#CD7F32';
    return '#8c8c8c';
  };

  const columns = [
    {
      title: '排名',
      key: 'rank',
      width: 80,
      align: 'center' as const,
      render: (_: any, __: any, index: number) => (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {index < 3 ? (
            <CrownOutlined style={{ fontSize: 20, color: getRankColor(index + 1) }} />
          ) : (
            <span style={{ fontSize: 16, fontWeight: 600, color: '#8c8c8c' }}>{index + 1}</span>
          )}
        </div>
      ),
    },
    {
      title: '分销商',
      dataIndex: 'distributorName',
      key: 'distributorName',
      render: (text: string) => <span style={{ fontWeight: 500 }}>{text}</span>,
    },
    {
      title: '订单数',
      dataIndex: 'orderCount',
      key: 'orderCount',
      align: 'right' as const,
      sorter: (a: DistributorRevenueRanking, b: DistributorRevenueRanking) => a.orderCount - b.orderCount,
      render: (value: number) => <span style={{ fontWeight: 600 }}>{value}</span>,
    },
    {
      title: '总收益',
      dataIndex: 'totalRevenue',
      key: 'totalRevenue',
      align: 'right' as const,
      render: (value: number) => <span>¥{value.toFixed(2)}</span>,
    },
    {
      title: '分成比例',
      dataIndex: 'commissionRate',
      key: 'commissionRate',
      align: 'center' as const,
      render: (value: number) => <span style={{ color: '#1890ff' }}>{value}%</span>,
    },
    {
      title: '分成收益',
      dataIndex: 'distributorCommission',
      key: 'distributorCommission',
      align: 'right' as const,
      render: (value: number, record: DistributorRevenueRanking) => (
        <div>
          <div style={{ color: '#52c41a', fontWeight: 600, marginBottom: 4 }}>
            ¥{value.toFixed(2)}
          </div>
          <Progress
            percent={maxCommission > 0 ? (value / maxCommission) * 100 : 0}
            showInfo={false}
            strokeColor="#52c41a"
            size="small"
          />
        </div>
      ),
      sorter: (a: DistributorRevenueRanking, b: DistributorRevenueRanking) =>
        a.distributorCommission - b.distributorCommission,
    },
  ];

  const cardStyle = {
    borderRadius: 12,
    boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)',
  };

  return (
    <Card
      bordered={false}
      style={cardStyle}
      bodyStyle={{ padding: 0 }}
    >
      <div style={{ padding: '16px 24px', borderBottom: '1px solid #f0f0f0' }}>
        <h3 style={{ margin: 0, fontSize: 18, fontWeight: 600, color: '#262626' }}>分销商收益排行榜</h3>
      </div>
      <Table
        columns={columns}
        dataSource={data}
        loading={loading}
        rowKey="distributorId"
        pagination={false}
        scroll={{ x: 900 }}
        size="middle"
      />
    </Card>
  );
};

export default DistributorRankingTable;
