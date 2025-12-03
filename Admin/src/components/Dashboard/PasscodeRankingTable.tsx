import React from 'react';
import { Table, Card, Tag } from 'antd';
import { TrophyOutlined } from '@ant-design/icons';
import type { PasscodeRanking } from '../../api/dashboard';

interface PasscodeRankingTableProps {
  data: PasscodeRanking[];
  loading: boolean;
}

const PasscodeRankingTable: React.FC<PasscodeRankingTableProps> = ({ data, loading }) => {
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
            <TrophyOutlined style={{ fontSize: 20, color: getRankColor(index + 1) }} />
          ) : (
            <span style={{ fontSize: 16, fontWeight: 600, color: '#8c8c8c' }}>{index + 1}</span>
          )}
        </div>
      ),
    },
    {
      title: '口令',
      dataIndex: 'passcode',
      key: 'passcode',
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: '分销商',
      dataIndex: 'distributorName',
      key: 'distributorName',
    },
    {
      title: '书籍',
      dataIndex: 'bookTitle',
      key: 'bookTitle',
      ellipsis: true,
    },
    {
      title: '订单数',
      dataIndex: 'orderCount',
      key: 'orderCount',
      align: 'right' as const,
      sorter: (a: PasscodeRanking, b: PasscodeRanking) => a.orderCount - b.orderCount,
      render: (value: number) => <span style={{ fontWeight: 600 }}>{value}</span>,
    },
    {
      title: '总收益',
      dataIndex: 'totalRevenue',
      key: 'totalRevenue',
      align: 'right' as const,
      render: (value: number) => (
        <span style={{ color: '#f5222d', fontWeight: 600 }}>¥{value.toFixed(2)}</span>
      ),
      sorter: (a: PasscodeRanking, b: PasscodeRanking) => a.totalRevenue - b.totalRevenue,
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
        <h3 style={{ margin: 0, fontSize: 18, fontWeight: 600, color: '#262626' }}>口令排行榜</h3>
      </div>
      <Table
        columns={columns}
        dataSource={data}
        loading={loading}
        rowKey="passcodeId"
        pagination={false}
        scroll={{ x: 800 }}
        size="middle"
      />
    </Card>
  );
};

export default PasscodeRankingTable;
