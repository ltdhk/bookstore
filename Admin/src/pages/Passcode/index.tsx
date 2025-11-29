import React, { useEffect, useState } from 'react';
import {
  Table,
  Button,
  Input,
  Select,
  Space,
  Tag,
  Modal,
  Card,
  Row,
  Col,
  message,
} from 'antd';
import { SearchOutlined, EyeOutlined } from '@ant-design/icons';
import {
  getAllPasscodes,
  getPasscodeStats,
  getPasscodeLogs,
  type BookPasscode,
  type PasscodeStats,
  type PasscodeUsageLog,
} from '../../api/passcode';
import { getActiveDistributors } from '../../api/distributor';

const PasscodeManagement: React.FC = () => {
  const [data, setData] = useState<BookPasscode[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [searchPasscode, setSearchPasscode] = useState('');
  const [searchDistributorId, setSearchDistributorId] = useState<number | undefined>(undefined);
  const [distributors, setDistributors] = useState<any[]>([]);

  // Stats modal
  const [statsModalVisible, setStatsModalVisible] = useState(false);
  const [currentStats, setCurrentStats] = useState<PasscodeStats | null>(null);

  // Logs modal
  const [logsModalVisible, setLogsModalVisible] = useState(false);
  const [currentLogs, setCurrentLogs] = useState<PasscodeUsageLog[]>([]);
  const [logsPage, setLogsPage] = useState(1);
  const [logsTotal, setLogsTotal] = useState(0);
  const [currentPasscodeId, setCurrentPasscodeId] = useState<number | null>(null);

  const fetchDistributors = async () => {
    try {
      const res: any = await getActiveDistributors();
      const distributorList = res.data?.records || res.data || [];
      setDistributors(distributorList);
    } catch (error) {
      console.error('Failed to fetch distributors', error);
    }
  };

  const fetchData = async (page = 1, passcode?: string, distributorId?: number) => {
    setLoading(true);
    try {
      const res: any = await getAllPasscodes({
        page,
        size: pagination.pageSize,
        passcode: passcode || undefined,
        distributorId: distributorId || undefined,
      });
      setData(res.data?.records || []);
      setPagination({
        ...pagination,
        current: page,
        total: res.data?.total || 0,
      });
    } catch (error) {
      message.error('获取口令列表失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDistributors();
    fetchData();
  }, []);

  const handleSearch = () => {
    fetchData(1, searchPasscode, searchDistributorId);
  };

  const handleReset = () => {
    setSearchPasscode('');
    setSearchDistributorId(undefined);
    fetchData(1);
  };

  const handleViewStats = async (passcodeId: number) => {
    try {
      const res: any = await getPasscodeStats(passcodeId);
      setCurrentStats(res.data);
      setStatsModalVisible(true);
    } catch (error) {
      message.error('获取统计数据失败');
    }
  };

  const handleViewLogs = async (passcodeId: number, page = 1) => {
    try {
      setCurrentPasscodeId(passcodeId);
      const res: any = await getPasscodeLogs(passcodeId, { page, size: 10 });
      setCurrentLogs(res.data?.records || []);
      setLogsTotal(res.data?.total || 0);
      setLogsPage(page);
      setLogsModalVisible(true);
    } catch (error) {
      message.error('获取使用记录失败');
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: '口令',
      dataIndex: 'passcode',
      key: 'passcode',
      width: 120,
      render: (text: string) => (
        <span style={{ fontFamily: 'monospace', fontWeight: 'bold' }}>{text}</span>
      ),
    },
    {
      title: '名称',
      dataIndex: 'name',
      key: 'name',
      width: 120,
      render: (text: string) => text || '-',
    },
    {
      title: '绑定书籍',
      dataIndex: 'bookTitle',
      key: 'bookTitle',
      width: 200,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '分销商',
      dataIndex: 'distributorName',
      key: 'distributorName',
      width: 120,
      render: (text: string) => text || '-',
    },
    {
      title: '使用次数',
      dataIndex: 'usedCount',
      key: 'usedCount',
      width: 90,
      render: (count: number) => (
        <span style={{ color: '#1890ff', fontWeight: 'bold' }}>{count || 0}</span>
      ),
    },
    {
      title: '浏览次数',
      dataIndex: 'viewCount',
      key: 'viewCount',
      width: 90,
      render: (count: number) => (
        <span style={{ color: '#52c41a', fontWeight: 'bold' }}>{count || 0}</span>
      ),
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: 80,
      render: (status: number) => (
        <Tag color={status === 1 ? 'green' : 'red'}>
          {status === 1 ? '启用' : '禁用'}
        </Tag>
      ),
    },
    {
      title: '有效期',
      key: 'validPeriod',
      width: 200,
      render: (_: any, record: BookPasscode) => {
        if (!record.validFrom && !record.validTo) {
          return <Tag color="blue">永久有效</Tag>;
        }
        const from = record.validFrom ? new Date(record.validFrom).toLocaleDateString() : '无限制';
        const to = record.validTo ? new Date(record.validTo).toLocaleDateString() : '无限制';
        return `${from} ~ ${to}`;
      },
    },
    {
      title: '订单数量',
      dataIndex: 'orderCount',
      key: 'orderCount',
      width: 90,
      render: (count: number) => (
        <span style={{ color: '#faad14', fontWeight: 'bold' }}>{count || 0}</span>
      ),
    },
    {
      title: '总金额',
      dataIndex: 'totalAmount',
      key: 'totalAmount',
      width: 100,
      render: (amount: number) => (
        <span style={{ color: '#f5222d', fontWeight: 'bold' }}>
          ¥{(amount || 0).toFixed(2)}
        </span>
      ),
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right' as const,
      width: 150,
      render: (_: any, record: BookPasscode) => (
        <Space>
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleViewStats(record.id!)}
          >
            统计
          </Button>
          <Button
            type="link"
            size="small"
            onClick={() => handleViewLogs(record.id!)}
          >
            记录
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div>
      {/* 搜索区域 */}
      <Card style={{ marginBottom: 16 }}>
        <Space wrap>
          <Input
            placeholder="搜索口令"
            value={searchPasscode}
            onChange={(e) => setSearchPasscode(e.target.value)}
            onPressEnter={handleSearch}
            style={{ width: 200 }}
            allowClear
          />
          <Select
            placeholder="选择分销商"
            value={searchDistributorId}
            onChange={(value) => setSearchDistributorId(value)}
            style={{ width: 200 }}
            allowClear
          >
            {distributors.map((dist) => (
              <Select.Option key={dist.id} value={dist.id}>
                {dist.name}
              </Select.Option>
            ))}
          </Select>
          <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
            搜索
          </Button>
          <Button onClick={handleReset}>重置</Button>
        </Space>
      </Card>

      {/* 口令列表 */}
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        scroll={{ x: 1400 }}
        pagination={{
          ...pagination,
          showSizeChanger: true,
          showQuickJumper: true,
          showTotal: (total) => `共 ${total} 条`,
          onChange: (page, pageSize) => {
            setPagination({ ...pagination, pageSize: pageSize || 10 });
            fetchData(page, searchPasscode, searchDistributorId);
          },
        }}
      />

      {/* 统计Modal */}
      <Modal
        title="口令统计"
        open={statsModalVisible}
        onCancel={() => setStatsModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setStatsModalVisible(false)}>
            关闭
          </Button>,
        ]}
        width={700}
      >
        {currentStats && (
          <div style={{ padding: '20px 0' }}>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>口令</div>
                    <div style={{ fontSize: 20, fontWeight: 'bold', marginTop: 8, fontFamily: 'monospace' }}>
                      {currentStats.passcode}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>名称</div>
                    <div style={{ fontSize: 20, fontWeight: 'bold', marginTop: 8 }}>
                      {currentStats.name || '-'}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={8}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>使用次数</div>
                    <div style={{ fontSize: 28, fontWeight: 'bold', marginTop: 8, color: '#1890ff' }}>
                      {currentStats.usedCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={8}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>浏览次数</div>
                    <div style={{ fontSize: 28, fontWeight: 'bold', marginTop: 8, color: '#52c41a' }}>
                      {currentStats.viewCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={8}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>独立用户</div>
                    <div style={{ fontSize: 28, fontWeight: 'bold', marginTop: 8, color: '#722ed1' }}>
                      {currentStats.uniqueUsers}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>订单数量</div>
                    <div style={{ fontSize: 28, fontWeight: 'bold', marginTop: 8, color: '#faad14' }}>
                      {currentStats.orderCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>总金额</div>
                    <div style={{ fontSize: 28, fontWeight: 'bold', marginTop: 8, color: '#f5222d' }}>
                      ¥{currentStats.totalAmount}
                    </div>
                  </div>
                </Card>
              </Col>
            </Row>
          </div>
        )}
      </Modal>

      {/* 使用记录Modal */}
      <Modal
        title="使用记录"
        open={logsModalVisible}
        onCancel={() => setLogsModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setLogsModalVisible(false)}>
            关闭
          </Button>,
        ]}
        width={1000}
      >
        <Table
          dataSource={currentLogs}
          rowKey="id"
          pagination={{
            current: logsPage,
            pageSize: 10,
            total: logsTotal,
            onChange: (page) => {
              if (currentPasscodeId) {
                handleViewLogs(currentPasscodeId, page);
              }
            },
          }}
          columns={[
            {
              title: 'ID',
              dataIndex: 'id',
              key: 'id',
              width: 80,
            },
            {
              title: '用户ID',
              dataIndex: 'userId',
              key: 'userId',
              width: 100,
              render: (id: number) => id || '-',
            },
            {
              title: '操作类型',
              dataIndex: 'actionType',
              key: 'actionType',
              width: 100,
              render: (type: string) => {
                const typeMap: Record<string, { text: string; color: string }> = {
                  use: { text: '使用', color: '#1890ff' },
                  open: { text: '打开', color: '#52c41a' },
                  view: { text: '浏览', color: '#faad14' },
                  sub: { text: '订阅', color: '#722ed1' },
                };
                const config = typeMap[type] || { text: type, color: '#999' };
                return <Tag color={config.color}>{config.text}</Tag>;
              },
            },
            {
              title: 'IP地址',
              dataIndex: 'ipAddress',
              key: 'ipAddress',
              width: 150,
              render: (ip: string) => ip || '-',
            },
            {
              title: '设备信息',
              dataIndex: 'deviceInfo',
              key: 'deviceInfo',
              ellipsis: true,
              render: (info: string) => info || '-',
            },
            {
              title: '时间',
              dataIndex: 'createdAt',
              key: 'createdAt',
              width: 180,
            },
          ]}
        />
      </Modal>
    </div>
  );
};

export default PasscodeManagement;
