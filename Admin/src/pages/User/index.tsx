import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Tag, Popconfirm, message } from 'antd';
import { CheckCircleOutlined, StopOutlined, DeleteOutlined } from '@ant-design/icons';
import { getUsers, updateUserStatus, deleteUser } from '../../api/user';

const UserManagement: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });

  const fetchUsers = async (page = 1) => {
    setLoading(true);
    try {
      const res: any = await getUsers({ page, size: pagination.pageSize });
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

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '用户名', dataIndex: 'username', key: 'username', width: 120 },
    { title: '昵称', dataIndex: 'nickname', key: 'nickname', width: 120 },
    { title: '邮箱', dataIndex: 'email', key: 'email', width: 200 },
    { title: '手机号', dataIndex: 'phone', key: 'phone', width: 130 },
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
      width: 100,
      render: (isSvip: boolean) => (
        <Tag color={isSvip ? 'gold' : 'default'}>{isSvip ? '是' : '否'}</Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'deleted',
      key: 'deleted',
      width: 100,
      render: (deleted: boolean) => (
        <Tag color={deleted ? 'red' : 'green'}>{deleted ? '禁用' : '正常'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      fixed: 'right' as const,
      render: (_: any, record: any) => (
        <Space>
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
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        scroll={{ x: 1200 }}
        pagination={{
          ...pagination,
          onChange: (page) => fetchUsers(page),
        }}
      />
    </div>
  );
};

export default UserManagement;
