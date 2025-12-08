import React, { useEffect, useState } from 'react';
import {
  Table,
  Button,
  Modal,
  Form,
  Input,
  Select,
  message,
  Space,
  Row,
  Col,
  Card,
  Statistic,
  Tag,
  DatePicker,
  Descriptions,
} from 'antd';
import {
  DollarOutlined,
  UserOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  SearchOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  getSubscriptionOrders,
  getSubscriptionDetail,
  forceCancelSubscription,
  getSubscriptionStats,
  type SubscriptionOrder,
  type SubscriptionStats,
} from '../../api/subscription';
import { getActiveDistributors } from '../../api/distributor';

const { RangePicker } = DatePicker;
const { Option } = Select;

// 扩展订单类型，包含用户名和分销商名称
interface SubscriptionOrderWithNames extends SubscriptionOrder {
  username?: string;
  distributorName?: string;
}

const SubscriptionManagement: React.FC = () => {
  const [orders, setOrders] = useState<SubscriptionOrderWithNames[]>([]);
  const [stats, setStats] = useState<SubscriptionStats | null>(null);
  const [loading, setLoading] = useState(false);
  const [statsLoading, setStatsLoading] = useState(false);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [currentOrder, setCurrentOrder] = useState<any | null>(null);
  const [searchForm] = Form.useForm();
  const [distributors, setDistributors] = useState<any[]>([]);

  // 搜索参数
  const [searchParams, setSearchParams] = useState<any>({
    status: undefined,
    platform: undefined,
    subscriptionPeriod: undefined,
  });

  // 获取订阅订单列表
  const fetchOrders = async (page = 1, params = searchParams) => {
    setLoading(true);
    try {
      const res: any = await getSubscriptionOrders({
        page,
        size: pagination.pageSize,
        ...params,
      });
      if (res.code === 200) {
        setOrders(res.data.records || []);
        setPagination({
          ...pagination,
          current: page,
          total: res.data.total || 0,
        });
      }
    } catch (error) {
      message.error('获取订阅订单失败');
    } finally {
      setLoading(false);
    }
  };

  // 获取统计数据
  const fetchStats = async (params?: any) => {
    setStatsLoading(true);
    try {
      const res: any = await getSubscriptionStats(params);
      if (res.code === 200) {
        setStats(res.data);
      }
    } catch (error) {
      message.error('获取统计数据失败');
    } finally {
      setStatsLoading(false);
    }
  };

  // 获取分销商列表
  const fetchDistributors = async () => {
    try {
      const res: any = await getActiveDistributors();
      if (res.code === 200) {
        setDistributors(res.data?.records || []);
      }
    } catch (error) {
      console.error('获取分销商列表失败', error);
    }
  };

  useEffect(() => {
    fetchOrders();
    fetchStats();
    fetchDistributors();
  }, []);

  // 查看订单详情
  const handleViewDetail = async (id: number) => {
    try {
      const res: any = await getSubscriptionDetail(id);
      if (res.code === 200) {
        setCurrentOrder(res.data);
        setDetailModalVisible(true);
      }
    } catch (error) {
      message.error('获取订单详情失败');
    }
  };

  // 强制取消订阅
  const handleForceCancel = async (id: number) => {
    Modal.confirm({
      title: '确认取消订阅',
      content: '确定要强制取消该订阅吗？此操作不可撤销。',
      onOk: async () => {
        try {
          const res: any = await forceCancelSubscription(id, '管理员强制取消');
          if (res.code === 200) {
            message.success('取消成功');
            fetchOrders(pagination.current);
            fetchStats();
          } else {
            message.error(res.message || '取消失败');
          }
        } catch (error) {
          message.error('取消订阅失败');
        }
      },
    });
  };

  // 搜索
  const handleSearch = () => {
    const values = searchForm.getFieldsValue();
    const params: any = {};

    if (values.status) params.status = values.status;
    if (values.platform) params.platform = values.platform;
    if (values.subscriptionPeriod) params.subscriptionPeriod = values.subscriptionPeriod;
    if (values.username) params.username = values.username;
    if (values.distributorId) params.distributorId = values.distributorId;
    if (values.dateRange && values.dateRange.length === 2) {
      params.startDate = values.dateRange[0].format('YYYY-MM-DD');
      params.endDate = values.dateRange[1].format('YYYY-MM-DD');
    }

    setSearchParams(params);
    fetchOrders(1, params);
    fetchStats({
      startDate: params.startDate,
      endDate: params.endDate,
    });
  };

  // 重置搜索
  const handleReset = () => {
    searchForm.resetFields();
    setSearchParams({});
    fetchOrders(1, {});
    fetchStats();
  };

  // 表格列定义
  const columns: ColumnsType<SubscriptionOrderWithNames> = [
    {
      title: '订单号',
      dataIndex: 'orderNo',
      key: 'orderNo',
      width: 180,
    },
    {
      title: '用户',
      dataIndex: 'username',
      key: 'username',
      width: 150,
      render: (username: string, record) => username || record.userId || '-',
    },
    {
      title: '分销商',
      dataIndex: 'distributorName',
      key: 'distributorName',
      width: 120,
      render: (name: string) => name || '-',
    },
    {
      title: '平台',
      dataIndex: 'platform',
      key: 'platform',
      width: 120,
      render: (platform: string) => (
        <Tag color={platform === 'AppStore' ? 'blue' : 'green'}>{platform}</Tag>
      ),
    },
    {
      title: '订阅类型',
      dataIndex: 'subscriptionPeriod',
      key: 'subscriptionPeriod',
      width: 100,
      render: (period: string) => {
        const colorMap: any = {
          monthly: 'cyan',
          quarterly: 'purple',
          yearly: 'gold',
        };
        const textMap: any = {
          monthly: '月度',
          quarterly: '季度',
          yearly: '年度',
        };
        return <Tag color={colorMap[period]}>{textMap[period] || period}</Tag>;
      },
    },
    {
      title: '金额',
      dataIndex: 'amount',
      key: 'amount',
      width: 100,
      render: (amount: number) => `$${amount.toFixed(2)}`,
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: 100,
      render: (status: string) => {
        const colorMap: any = {
          Paid: 'success',
          Pending: 'warning',
          Refunded: 'error',
        };
        return <Tag color={colorMap[status]}>{status}</Tag>;
      },
    },
    {
      title: '订阅开始时间',
      dataIndex: 'subscriptionStartDate',
      key: 'subscriptionStartDate',
      width: 180,
      render: (date: string) => dayjs(date).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '订阅结束时间',
      dataIndex: 'subscriptionEndDate',
      key: 'subscriptionEndDate',
      width: 180,
      render: (date: string) => dayjs(date).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '自动续订',
      dataIndex: 'isAutoRenew',
      key: 'isAutoRenew',
      width: 100,
      render: (isAutoRenew: boolean) =>
        isAutoRenew ? (
          <Tag color="success">是</Tag>
        ) : (
          <Tag color="default">否</Tag>
        ),
    },
    {
      title: '来源',
      dataIndex: 'sourceEntry',
      key: 'sourceEntry',
      width: 100,
      render: (source: string) => {
        const textMap: any = {
          profile: '个人中心',
          reader: '阅读页',
        };
        return textMap[source] || source || '-';
      },
    },
    {
      title: '创建时间',
      dataIndex: 'createTime',
      key: 'createTime',
      width: 180,
      render: (date: string) => dayjs(date).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
      render: (_: any, record: SubscriptionOrderWithNames) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            onClick={() => handleViewDetail(record.id)}
          >
            详情
          </Button>
          {record.status === 'Paid' &&
            dayjs(record.subscriptionEndDate).isAfter(dayjs()) && (
              <Button
                type="link"
                danger
                size="small"
                onClick={() => handleForceCancel(record.id)}
              >
                强制取消
              </Button>
            )}
        </Space>
      ),
    },
  ];

  return (
    <div>
      {/* 统计卡片 */}
      <Row gutter={16} style={{ marginBottom: 24 }}>
        <Col span={6}>
          <Card loading={statsLoading}>
            <Statistic
              title="总订阅数"
              value={stats?.totalSubscriptions || 0}
              prefix={<UserOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={statsLoading}>
            <Statistic
              title="活跃订阅"
              value={stats?.activeSubscriptions || 0}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#3f8600' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={statsLoading}>
            <Statistic
              title="已取消订阅"
              value={stats?.cancelledSubscriptions || 0}
              prefix={<CloseCircleOutlined />}
              valueStyle={{ color: '#cf1322' }}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card loading={statsLoading}>
            <Statistic
              title="总收入"
              value={stats?.totalRevenue || 0}
              prefix={<DollarOutlined />}
              precision={2}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 搜索表单 */}
      <Card style={{ marginBottom: 24 }}>
        <Form form={searchForm} layout="inline">
          <Form.Item name="status" label="状态">
            <Select placeholder="请选择状态" style={{ width: 120 }} allowClear>
              <Option value="Paid">Paid</Option>
              <Option value="Pending">Pending</Option>
              <Option value="Refunded">Refunded</Option>
            </Select>
          </Form.Item>
          <Form.Item name="platform" label="平台">
            <Select placeholder="请选择平台" style={{ width: 140 }} allowClear>
              <Option value="AppStore">AppStore</Option>
              <Option value="GooglePay">GooglePay</Option>
            </Select>
          </Form.Item>
          <Form.Item name="subscriptionPeriod" label="订阅类型">
            <Select placeholder="请选择订阅类型" style={{ width: 120 }} allowClear>
              <Option value="monthly">月度</Option>
              <Option value="quarterly">季度</Option>
              <Option value="yearly">年度</Option>
              <Option value="weekly">周度</Option>
            </Select>
          </Form.Item>
          <Form.Item name="username" label="用户名">
            <Input placeholder="请输入用户名" style={{ width: 140 }} />
          </Form.Item>
          <Form.Item name="distributorId" label="分销商">
            <Select
              placeholder="请选择分销商"
              style={{ width: 160 }}
              allowClear
              showSearch
              optionFilterProp="children"
            >
              {distributors.map((d: any) => (
                <Option key={d.id} value={d.id}>
                  {d.name}
                </Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item name="dateRange" label="创建时间">
            <RangePicker />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button
                type="primary"
                icon={<SearchOutlined />}
                onClick={handleSearch}
              >
                搜索
              </Button>
              <Button onClick={handleReset}>重置</Button>
            </Space>
          </Form.Item>
        </Form>
      </Card>

      {/* 订单列表 */}
      <Card>
        <Table
          columns={columns}
          dataSource={orders}
          rowKey="id"
          loading={loading}
          pagination={{
            ...pagination,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `共 ${total} 条`,
          }}
          onChange={(pagination) => {
            fetchOrders(pagination.current || 1);
          }}
          scroll={{ x: 1800 }}
        />
      </Card>

      {/* 订单详情模态框 */}
      <Modal
        title="订阅订单详情"
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        footer={null}
        width={800}
      >
        {currentOrder && (
          <div>
            <Descriptions bordered column={2}>
              <Descriptions.Item label="订单号" span={2}>
                {currentOrder.orderNo}
              </Descriptions.Item>
              <Descriptions.Item label="用户ID">
                {currentOrder.userId}
              </Descriptions.Item>
              <Descriptions.Item label="用户名">
                {currentOrder.username}
              </Descriptions.Item>
              <Descriptions.Item label="平台">
                <Tag
                  color={
                    currentOrder.platform === 'AppStore' ? 'blue' : 'green'
                  }
                >
                  {currentOrder.platform}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="状态">
                <Tag
                  color={
                    currentOrder.status === 'Paid' ? 'success' : 'warning'
                  }
                >
                  {currentOrder.status}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="订阅类型">
                {currentOrder.subscriptionPeriod}
              </Descriptions.Item>
              <Descriptions.Item label="金额">
                ${currentOrder.amount?.toFixed(2)}
              </Descriptions.Item>
              <Descriptions.Item label="产品ID" span={2}>
                {currentOrder.productId}
              </Descriptions.Item>
              <Descriptions.Item label="产品名称" span={2}>
                {currentOrder.productName}
              </Descriptions.Item>
              <Descriptions.Item label="订阅开始时间" span={2}>
                {dayjs(currentOrder.subscriptionStartDate).format(
                  'YYYY-MM-DD HH:mm:ss'
                )}
              </Descriptions.Item>
              <Descriptions.Item label="订阅结束时间" span={2}>
                {dayjs(currentOrder.subscriptionEndDate).format(
                  'YYYY-MM-DD HH:mm:ss'
                )}
              </Descriptions.Item>
              <Descriptions.Item label="自动续订">
                {currentOrder.isAutoRenew ? '是' : '否'}
              </Descriptions.Item>
              <Descriptions.Item label="分销商ID">
                {currentOrder.distributorId
                  ? `${currentOrder.distributorId} (${currentOrder.distributorName || '-'})`
                  : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="来源通行证ID">
                {currentOrder.sourcePasscodeId
                  ? `${currentOrder.sourcePasscodeId} (${currentOrder.passcodeName || currentOrder.passcodeCode || '-'})`
                  : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="来源书籍ID">
                {currentOrder.sourceBookId
                  ? `${currentOrder.sourceBookId} (${currentOrder.bookTitle || '-'})`
                  : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="来源入口" span={2}>
                {currentOrder.sourceEntry === 'profile'
                  ? '个人中心'
                  : currentOrder.sourceEntry === 'reader'
                  ? '阅读页'
                  : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="原始交易ID" span={2}>
                {currentOrder.originalTransactionId}
              </Descriptions.Item>
              <Descriptions.Item label="平台交易ID" span={2}>
                {currentOrder.platformTransactionId}
              </Descriptions.Item>
              {currentOrder.cancelDate && (
                <>
                  <Descriptions.Item label="取消时间" span={2}>
                    {dayjs(currentOrder.cancelDate).format(
                      'YYYY-MM-DD HH:mm:ss'
                    )}
                  </Descriptions.Item>
                  <Descriptions.Item label="取消原因" span={2}>
                    {currentOrder.cancelReason}
                  </Descriptions.Item>
                </>
              )}
              <Descriptions.Item label="创建时间" span={2}>
                {dayjs(currentOrder.createTime).format(
                  'YYYY-MM-DD HH:mm:ss'
                )}
              </Descriptions.Item>
            </Descriptions>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default SubscriptionManagement;
