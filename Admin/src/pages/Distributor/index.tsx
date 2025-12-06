import React, { useEffect, useState } from 'react';
import { Table, Button, Input, Space, Modal, Form, message, Popconfirm, Tag, Statistic, Row, Col, Select, Alert, InputNumber } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, SearchOutlined, BarChartOutlined } from '@ant-design/icons';
import { getDistributors, createDistributor, updateDistributor, deleteDistributor, getDistributorStats } from '../../api/distributor';

const DistributorManagement: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [searchKeyword, setSearchKeyword] = useState('');
  const [modalVisible, setModalVisible] = useState(false);
  const [statsVisible, setStatsVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [currentStats, setCurrentStats] = useState<any>({});
  const [errorMsg, setErrorMsg] = useState<string>('');
  const [form] = Form.useForm();

  const fetchData = async (page = 1, name = '') => {
    setLoading(true);
    try {
      const res: any = await getDistributors({ page, size: pagination.pageSize, name });
      setData(res.data?.records || []);
      setPagination({ ...pagination, current: page, total: res.data?.total || 0 });
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleSearch = () => {
    fetchData(1, searchKeyword);
  };

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    setErrorMsg('');
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setErrorMsg('');
    setModalVisible(true);
  };

  const handleStats = async (record: any) => {
    try {
      const res: any = await getDistributorStats(record.id);
      setCurrentStats(res);
      setStatsVisible(true);
    } catch (error) {
      console.error(error);
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteDistributor(id);
      message.success('删除成功');
      fetchData(pagination.current, searchKeyword);
    } catch (error) {
      console.error(error);
    }
  };

  const handleModalOk = async () => {
    try {
      const values = await form.validateFields();
      setErrorMsg(''); // 清空之前的错误
      setSubmitLoading(true);

      if (editingItem) {
        const res: any = await updateDistributor(editingItem.id, values);
        if (res.code === 200) {
          message.success('更新成功');
          setModalVisible(false);
          fetchData(pagination.current, searchKeyword);
        } else {
          // 在 Modal 中显示错误信息
          setErrorMsg(res.message || '更新失败');
        }
      } else {
        const res: any = await createDistributor(values);
        if (res.code === 200) {
          message.success('创建成功');
          setModalVisible(false);
          fetchData(pagination.current, searchKeyword);
        } else {
          // 在 Modal 中显示错误信息
          setErrorMsg(res.message || '创建失败');
        }
      }
    } catch (error: any) {
      // 处理表单验证错误
      if (error.errorFields) {
        setErrorMsg('请检查表单填写是否正确');
      } else {
        // 处理API错误
        const errorMessage = error.response?.data?.message || error.message || '操作失败';
        setErrorMsg(errorMessage);
      }
    } finally {
      setSubmitLoading(false);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '名称', dataIndex: 'name', key: 'name' },
    { title: '用户名', dataIndex: 'username', key: 'username' },
    { title: '联系方式', dataIndex: 'contact', key: 'contact' },
    { title: '分销码', dataIndex: 'code', key: 'code' },
    {
      title: '订阅分成(%)',
      dataIndex: 'commissionRate',
      key: 'commissionRate',
      width: 120,
      render: (rate: number) => rate ? `${rate}%` : '30%'
    },
    {
      title: '充币分成(%)',
      dataIndex: 'coinsCommissionRate',
      key: 'coinsCommissionRate',
      width: 120,
      render: (rate: number) => rate ? `${rate}%` : '30%'
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      render: (status: number) => (
        <Tag color={status === 1 ? 'green' : 'red'}>{status === 1 ? '启用' : '禁用'}</Tag>
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      render: (_: any, record: any) => (
        <Space>
          <Button type="link" icon={<BarChartOutlined />} onClick={() => handleStats(record)}>
            统计
          </Button>
          <Button type="link" icon={<EditOutlined />} onClick={() => handleEdit(record)}>
            编辑
          </Button>
          <Popconfirm title="确定删除?" onConfirm={() => handleDelete(record.id)}>
            <Button type="link" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <Space>
          <Input
            placeholder="搜索分销商"
            value={searchKeyword}
            onChange={(e) => setSearchKeyword(e.target.value)}
            onPressEnter={handleSearch}
            style={{ width: 300 }}
          />
          <Button icon={<SearchOutlined />} onClick={handleSearch}>
            搜索
          </Button>
        </Space>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增分销商
        </Button>
      </div>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{
          ...pagination,
          onChange: (page) => fetchData(page, searchKeyword),
        }}
      />

      <Modal
        title={editingItem ? '编辑分销商' : '新增分销商'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
        confirmLoading={submitLoading}
        maskClosable={false}
      >
        {errorMsg && (
          <Alert
            message={errorMsg}
            type="error"
            showIcon
            closable
            onClose={() => setErrorMsg('')}
            style={{ marginBottom: 16 }}
          />
        )}
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true, message: '请输入名称' }]}>
            <Input placeholder="请输入分销商名称" />
          </Form.Item>
          <Form.Item name="username" label="用户名" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input placeholder="请输入登录用户名" />
          </Form.Item>
          <Form.Item
            name="password"
            label="密码"
            rules={[{ required: !editingItem, message: '请输入密码' }]}
          >
            <Input.Password placeholder={editingItem ? '留空则不修改密码' : '请输入密码'} />
          </Form.Item>
          <Form.Item name="contact" label="联系方式" rules={[{ required: true, message: '请输入联系方式' }]}>
            <Input placeholder="请输入联系方式" />
          </Form.Item>
          <Form.Item name="code" label="分销码" rules={[{ required: true, message: '请输入分销码' }]}>
            <Input placeholder="请输入分销码" />
          </Form.Item>
          <Form.Item
            name="commissionRate"
            label="订阅分成比例(%)"
            initialValue={30}
            rules={[{ required: true, message: '请输入订阅分成比例' }]}
          >
            <InputNumber
              min={0}
              max={100}
              precision={2}
              style={{ width: '100%' }}
              placeholder="请输入0-100的数字，例如30表示30%"
            />
          </Form.Item>
          <Form.Item
            name="coinsCommissionRate"
            label="充币分成比例(%)"
            initialValue={30}
            rules={[{ required: true, message: '请输入充币分成比例' }]}
          >
            <InputNumber
              min={0}
              max={100}
              precision={2}
              style={{ width: '100%' }}
              placeholder="请输入0-100的数字，例如30表示30%"
            />
          </Form.Item>
          <Form.Item name="status" label="状态" initialValue={1}>
            <Select>
              <Select.Option value={1}>启用</Select.Option>
              <Select.Option value={0}>禁用</Select.Option>
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="分销统计"
        open={statsVisible}
        onCancel={() => setStatsVisible(false)}
        footer={null}
      >
        <Row gutter={16}>
          <Col span={8}>
            <Statistic title="点击量" value={currentStats.clicks} />
          </Col>
          <Col span={8}>
            <Statistic title="转化数" value={currentStats.conversions} />
          </Col>
          <Col span={8}>
            <Statistic title="总收入" value={currentStats.income} precision={2} prefix="¥" />
          </Col>
        </Row>
      </Modal>
    </div>
  );
};

export default DistributorManagement;
