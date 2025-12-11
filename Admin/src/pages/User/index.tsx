import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Tag, Popconfirm, message, Modal, Form, Input, Switch, InputNumber, Select, DatePicker } from 'antd';
import { CheckCircleOutlined, StopOutlined, DeleteOutlined, PlusOutlined, EditOutlined, SearchOutlined } from '@ant-design/icons';
import { getUsers, updateUserStatus, deleteUser, createUser, updateUser } from '../../api/user';
import type { UserInfo } from '../../api/user';
import dayjs from 'dayjs';

const UserManagement: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalLoading, setModalLoading] = useState(false);
  const [editingUser, setEditingUser] = useState<UserInfo | null>(null);
  const [searchUsername, setSearchUsername] = useState('');
  const [form] = Form.useForm();

  const fetchUsers = async (page = 1, username?: string) => {
    setLoading(true);
    try {
      const res: any = await getUsers({ page, size: pagination.pageSize, username: username ?? searchUsername });
      setData(res.data?.records || []);
      setPagination({ ...pagination, current: page, total: res.data?.total || 0 });
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleToggleStatus = async (id: number, currentStatus: boolean) => {
    try {
      await updateUserStatus(id, currentStatus ? 0 : 1);
      message.success('状态更新成功');
      fetchUsers(pagination.current);
    } catch (error) {
      console.error(error);
    }
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteUser(id);
      message.success('删除成功');
      fetchUsers(pagination.current);
    } catch (error) {
      console.error(error);
    }
  };

  const handleAdd = () => {
    setEditingUser(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: UserInfo) => {
    setEditingUser(record);
    form.setFieldsValue({
      ...record,
      password: '', // 编辑时密码置空
      subscriptionEndDate: record.subscriptionEndDate ? dayjs(record.subscriptionEndDate) : null,
    });
    setModalVisible(true);
  };

  const handleModalOk = async () => {
    try {
      const values = await form.validateFields();
      setModalLoading(true);

      const userData: UserInfo = {
        ...values,
        subscriptionEndDate: values.subscriptionEndDate ? values.subscriptionEndDate.format('YYYY-MM-DDTHH:mm:ss') : null,
      };

      // 如果密码为空且是编辑模式，不传密码
      if (!userData.password) {
        delete userData.password;
      }

      if (editingUser) {
        const res: any = await updateUser(editingUser.id!, userData);
        if (res.code !== 200) {
          form.setFields([{ name: 'username', errors: [res.message || '更新失败'] }]);
          return;
        }
        message.success('更新成功');
      } else {
        if (!userData.password) {
          form.setFields([{ name: 'password', errors: ['新增用户必须设置密码'] }]);
          setModalLoading(false);
          return;
        }
        const res: any = await createUser(userData);
        if (res.code !== 200) {
          form.setFields([{ name: 'username', errors: [res.message || '创建失败'] }]);
          return;
        }
        message.success('创建成功');
      }

      setModalVisible(false);
      fetchUsers(pagination.current);
    } catch (error: any) {
      if (error?.response?.data?.message) {
        message.error(error.response.data.message);
      } else if (error?.message) {
        message.error(error.message);
      }
      console.error(error);
    } finally {
      setModalLoading(false);
    }
  };

  const handleSearch = () => {
    fetchUsers(1, searchUsername);
  };

  const handleReset = () => {
    setSearchUsername('');
    fetchUsers(1, '');
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '用户名', dataIndex: 'username', key: 'username', width: 120 },
    { title: '昵称', dataIndex: 'nickname', key: 'nickname', width: 120 },
    { title: '邮箱', dataIndex: 'email', key: 'email', width: 200 },
    { title: '手机号', dataIndex: 'phone', key: 'phone', width: 130 },
    { title: '金币', dataIndex: 'coins', key: 'coins', width: 80 },
    { title: '奖励', dataIndex: 'bonus', key: 'bonus', width: 80 },
    {
      title: '订阅到期时间',
      dataIndex: 'subscriptionEndDate',
      key: 'subscriptionEndDate',
      width: 170,
      render: (date: string) => date ? new Date(date).toLocaleString('zh-CN') : '-',
    },
    {
      title: 'SVIP',
      dataIndex: 'isSvip',
      key: 'isSvip',
      width: 80,
      render: (isSvip: boolean) => (
        <Tag color={isSvip ? 'gold' : 'default'}>{isSvip ? '是' : '否'}</Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'deleted',
      key: 'deleted',
      width: 80,
      render: (deleted: boolean) => (
        <Tag color={deleted ? 'red' : 'green'}>{deleted ? '禁用' : '正常'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 250,
      fixed: 'right' as const,
      render: (_: any, record: any) => (
        <Space>
          <Button
            type="link"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
          <Button
            type="link"
            icon={record.deleted ? <CheckCircleOutlined /> : <StopOutlined />}
            onClick={() => handleToggleStatus(record.id, record.deleted)}
          >
            {record.deleted ? '激活' : '禁用'}
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
            placeholder="搜索用户名"
            value={searchUsername}
            onChange={(e) => setSearchUsername(e.target.value)}
            onPressEnter={handleSearch}
            style={{ width: 200 }}
            allowClear
          />
          <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
            搜索
          </Button>
          <Button onClick={handleReset}>重置</Button>
        </Space>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增用户
        </Button>
      </div>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        scroll={{ x: 1400 }}
        pagination={{
          ...pagination,
          onChange: (page) => fetchUsers(page),
        }}
      />

      <Modal
        title={editingUser ? '编辑用户' : '新增用户'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
        confirmLoading={modalLoading}
        width={600}
      >
        <Form
          form={form}
          layout="vertical"
          initialValues={{ isSvip: false, coins: 0, bonus: 0 }}
        >
          <Form.Item
            name="username"
            label="用户名（邮箱）"
            rules={[
              { required: true, message: '请输入用户名' },
              { type: 'email', message: '用户名必须是邮箱格式' }
            ]}
          >
            <Input
              placeholder="请输入邮箱作为用户名"
              disabled={!!editingUser}
            />
          </Form.Item>

          <Form.Item
            name="password"
            label="密码"
            rules={editingUser ? [] : [{ required: true, message: '请输入密码' }]}
            extra={editingUser ? '留空则不修改密码' : ''}
          >
            <Input.Password placeholder={editingUser ? '留空则不修改密码' : '请输入密码'} />
          </Form.Item>

          <Form.Item name="nickname" label="昵称">
            <Input placeholder="请输入昵称" />
          </Form.Item>

          <Form.Item
            name="email"
            label="邮箱"
            rules={[{ type: 'email', message: '请输入有效的邮箱地址' }]}
          >
            <Input placeholder="请输入邮箱" />
          </Form.Item>

          <Form.Item name="phone" label="手机号">
            <Input placeholder="请输入手机号" />
          </Form.Item>

          <Space style={{ width: '100%' }} size="large">
            <Form.Item name="coins" label="金币">
              <InputNumber min={0} style={{ width: 150 }} />
            </Form.Item>

            <Form.Item name="bonus" label="奖励">
              <InputNumber min={0} style={{ width: 150 }} />
            </Form.Item>

            <Form.Item name="isSvip" label="SVIP" valuePropName="checked">
              <Switch checkedChildren="是" unCheckedChildren="否" />
            </Form.Item>
          </Space>

          <Space style={{ width: '100%' }} size="large">
            <Form.Item name="subscriptionStatus" label="订阅状态">
              <Select placeholder="选择订阅状态" style={{ width: 150 }} allowClear>
                <Select.Option value="none">无</Select.Option>
                <Select.Option value="active">活跃</Select.Option>
                <Select.Option value="expired">已过期</Select.Option>
                <Select.Option value="cancelled">已取消</Select.Option>
              </Select>
            </Form.Item>

            <Form.Item name="subscriptionPlanType" label="订阅类型">
              <Select placeholder="选择订阅类型" style={{ width: 150 }} allowClear>
                <Select.Option value="monthly">月订阅</Select.Option>
                <Select.Option value="quarterly">季订阅</Select.Option>
                <Select.Option value="yearly">年订阅</Select.Option>
              </Select>
            </Form.Item>

            <Form.Item name="subscriptionEndDate" label="订阅到期时间">
              <DatePicker showTime format="YYYY-MM-DD HH:mm:ss" />
            </Form.Item>
          </Space>
        </Form>
      </Modal>
    </div>
  );
};

export default UserManagement;
