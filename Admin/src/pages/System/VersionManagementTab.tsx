import React, { useEffect, useState } from 'react';
import { Table, Button, Space, Modal, Form, message, Popconfirm, Input, InputNumber, Switch, Select } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { getVersions, createVersion, updateVersion, deleteVersion } from '../../api/version';
import type { AppVersion } from '../../api/version';

const { TextArea } = Input;

const VersionManagementTab: React.FC = () => {
  const [data, setData] = useState<AppVersion[]>([]);
  const [loading, setLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<AppVersion | null>(null);
  const [selectedPlatform, setSelectedPlatform] = useState<string | undefined>(undefined);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();

  const fetchData = async (page = 1, platform?: string) => {
    setLoading(true);
    try {
      const res: any = await getVersions({ page, size: pagination.pageSize, platform });
      setData(res.data?.records || []);
      setPagination({ ...pagination, current: page, total: res.data?.total || 0 });
    } catch (error) {
      message.error('获取版本列表失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData(1, selectedPlatform);
  }, [selectedPlatform]);

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    form.setFieldsValue({
      platform: 'ios',
      forceUpdate: false,
      minSupportedVersion: 0,
      versionCode: 10000,
      versionName: '1.0.0'
    });
    setModalVisible(true);
  };

  const handleEdit = (record: AppVersion) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteVersion(id);
      message.success('删除成功');
      fetchData(pagination.current, selectedPlatform);
    } catch (error) {
      message.error('删除失败');
    }
  };

  const handleModalOk = async () => {
    try {
      setSubmitLoading(true);
      const values = await form.validateFields();

      if (editingItem) {
        const res: any = await updateVersion(editingItem.id!, values);
        if (res.code === 200) {
          message.success('更新成功');
          setModalVisible(false);
          fetchData(pagination.current, selectedPlatform);
        } else {
          message.error(res.message || '更新失败');
        }
      } else {
        const res: any = await createVersion(values);
        if (res.code === 200) {
          message.success('创建成功');
          setModalVisible(false);
          fetchData(1, selectedPlatform);
        } else {
          message.error(res.message || '创建失败');
        }
      }
    } catch (error: any) {
      if (error.errorFields) {
        message.error('请检查表单填写是否正确');
      } else {
        const errorMsg = error.response?.data?.message || error.message || '操作失败';
        message.error(errorMsg);
      }
    } finally {
      setSubmitLoading(false);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '版本名称', dataIndex: 'versionName', key: 'versionName', width: 100 },
    { title: '版本号', dataIndex: 'versionCode', key: 'versionCode', width: 100 },
    {
      title: '平台',
      dataIndex: 'platform',
      key: 'platform',
      width: 100,
      render: (platform: string) => platform === 'ios' ? 'iOS' : 'Android'
    },
    {
      title: '强制更新',
      dataIndex: 'forceUpdate',
      key: 'forceUpdate',
      width: 100,
      render: (val: boolean) => val ? '是' : '否'
    },
    {
      title: '最低支持版本',
      dataIndex: 'minSupportedVersion',
      key: 'minSupportedVersion',
      width: 120
    },
    {
      title: '更新链接',
      dataIndex: 'updateUrl',
      key: 'updateUrl',
      ellipsis: true
    },
    {
      title: '创建时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 180
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: AppVersion) => (
        <Space>
          <Button type="link" icon={<EditOutlined />} onClick={() => handleEdit(record)}>
            编辑
          </Button>
          <Popconfirm title="确定删除?" onConfirm={() => handleDelete(record.id!)}>
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
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Space>
          <span>平台筛选:</span>
          <Select
            value={selectedPlatform}
            onChange={setSelectedPlatform}
            style={{ width: 120 }}
            allowClear
            placeholder="全部"
          >
            <Select.Option value="ios">iOS</Select.Option>
            <Select.Option value="android">Android</Select.Option>
          </Select>
        </Space>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增版本
        </Button>
      </div>
      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{
          ...pagination,
          onChange: (page) => fetchData(page, selectedPlatform),
        }}
      />

      <Modal
        title={editingItem ? '编辑版本' : '新增版本'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => {
          if (!submitLoading) {
            setModalVisible(false);
          }
        }}
        confirmLoading={submitLoading}
        maskClosable={!submitLoading}
        closable={!submitLoading}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="platform" label="平台" rules={[{ required: true, message: '请选择平台' }]}>
            <Select disabled={!!editingItem}>
              <Select.Option value="ios">iOS</Select.Option>
              <Select.Option value="android">Android</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item name="versionName" label="版本名称" rules={[{ required: true, message: '请输入版本名称' }]}>
            <Input placeholder="例如：1.2.3" />
          </Form.Item>
          <Form.Item
            name="versionCode"
            label="版本号"
            rules={[{ required: true, message: '请输入版本号' }]}
            tooltip="用于版本比较的数字，例如：10203 表示 1.2.3"
          >
            <InputNumber min={1} style={{ width: '100%' }} placeholder="例如：10203" />
          </Form.Item>
          <Form.Item name="forceUpdate" label="强制更新" valuePropName="checked">
            <Switch />
          </Form.Item>
          <Form.Item
            name="minSupportedVersion"
            label="最低支持版本"
            tooltip="低于此版本的用户必须更新"
          >
            <InputNumber min={0} style={{ width: '100%' }} placeholder="例如：10000" />
          </Form.Item>
          <Form.Item name="updateUrl" label="商店链接" rules={[{ required: true, message: '请输入商店链接' }]}>
            <Input placeholder="App Store 或 Google Play 链接" />
          </Form.Item>
          <Form.Item name="releaseNotes" label="更新说明">
            <TextArea rows={4} placeholder="更新内容说明，支持换行" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default VersionManagementTab;
