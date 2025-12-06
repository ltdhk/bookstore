import React, { useEffect, useState } from 'react';
import { Tabs, Table, Button, Input, Space, Modal, Form, message, Popconfirm, Card, InputNumber, Switch, ColorPicker, Select } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import {
  getSystemConfigs, saveSystemConfig,
  getAdminUsers, createAdminUser, updateAdminUser, deleteAdminUser,
  getOperationLogs
} from '../../api/system';
import { getAllTags, createTag, updateTag, deleteTag } from '../../api/tag';
import { getCategories, createCategory, updateCategory, deleteCategory } from '../../api/category';
import { getLanguages, createLanguage, updateLanguage, deleteLanguage } from '../../api/language';

const { TabPane } = Tabs;

const LogTab: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 20, total: 0 });

  const fetchLogs = async (page = 1) => {
    setLoading(true);
    try {
      const res: any = await getOperationLogs({ page, size: pagination.pageSize });
      setData(res.data?.records || []);
      setPagination({ ...pagination, current: page, total: res.data?.total || 0 });
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
  }, []);

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '管理员', dataIndex: 'username', key: 'username' },
    { title: '动作', dataIndex: 'action', key: 'action' },
    { title: '目标', dataIndex: 'target', key: 'target', ellipsis: true },
    { title: 'IP', dataIndex: 'ip', key: 'ip' },
    { title: '时间', dataIndex: 'createTime', key: 'createTime' },
  ];

  return (
    <Table 
      columns={columns} 
      dataSource={data} 
      rowKey="id" 
      loading={loading}
      pagination={{
        ...pagination,
        onChange: (page) => fetchLogs(page),
      }}
    />
  );
};

const SystemConfigTab: React.FC = () => {
  const [configs, setConfigs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [form] = Form.useForm();

  const fetchConfigs = async () => {
    setLoading(true);
    try {
      const res: any = await getSystemConfigs();
      setConfigs(res.data || []);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchConfigs();
  }, []);

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleModalOk = async () => {
    try {
      const values = await form.validateFields();
      await saveSystemConfig(values);
      message.success('保存成功');
      setModalVisible(false);
      fetchConfigs();
    } catch (error) {
      console.error(error);
    }
  };

  const columns = [
    { title: '配置键', dataIndex: 'configKey', key: 'configKey' },
    { title: '配置值', dataIndex: 'configValue', key: 'configValue' },
    { title: '描述', dataIndex: 'description', key: 'description' },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: any) => (
        <Button type="link" icon={<EditOutlined />} onClick={() => handleEdit(record)}>
          编辑
        </Button>
      ),
    },
  ];

  return (
    <div>
      <div style={{ marginBottom: 16 }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增配置
        </Button>
      </div>
      <Table columns={columns} dataSource={configs} rowKey="id" loading={loading} pagination={false} />
      
      <Modal
        title={editingItem ? '编辑配置' : '新增配置'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="configKey" label="配置键" rules={[{ required: true }]}>
            <Input disabled={!!editingItem} />
          </Form.Item>
          <Form.Item name="configValue" label="配置值" rules={[{ required: true }]}>
            <Input.TextArea rows={4} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

const AdminUserTab: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [form] = Form.useForm();

  const fetchData = async () => {
    setLoading(true);
    try {
      const res: any = await getAdminUsers({ page: 1, size: 100 });
      setData(res.data?.records || []);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue({ ...record, password: '' });
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteAdminUser(id);
      message.success('删除成功');
      fetchData();
    } catch (error) {
      console.error(error);
    }
  };

  const handleModalOk = async () => {
    try {
      const values = await form.validateFields();
      if (editingItem) {
        await updateAdminUser(editingItem.id, values);
        message.success('更新成功');
      } else {
        await createAdminUser(values);
        message.success('创建成功');
      }
      setModalVisible(false);
      fetchData();
    } catch (error) {
      console.error(error);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '用户名', dataIndex: 'username', key: 'username' },
    { title: '邮箱', dataIndex: 'email', key: 'email' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    {
      title: '操作',
      key: 'action',
      render: (_: any, record: any) => (
        <Space>
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
      <div style={{ marginBottom: 16 }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增管理员
        </Button>
      </div>
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} />

      <Modal
        title={editingItem ? '编辑管理员' : '新增管理员'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="username" label="用户名" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item 
            name="password" 
            label={editingItem ? "密码 (留空不修改)" : "密码"} 
            rules={[{ required: !editingItem }]}
          >
            <Input.Password />
          </Form.Item>
          <Form.Item name="email" label="邮箱">
            <Input />
          </Form.Item>
          <Form.Item name="status" label="状态" initialValue="Active">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

const TagManagementTab: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [selectedLanguage, setSelectedLanguage] = useState<string | undefined>(undefined);
  const [languages, setLanguages] = useState<any[]>([]);
  const [form] = Form.useForm();

  const fetchLanguages = async () => {
    try {
      const res: any = await getLanguages();
      setLanguages(res.data || []);
    } catch (error) {
      message.error('获取语言失败');
    }
  };

  const fetchData = async (language?: string) => {
    setLoading(true);
    try {
      const res: any = await getAllTags(language);
      setData(res.data || []);
    } catch (error) {
      message.error('获取标签失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLanguages();
    fetchData(); // 初始加载所有数据
  }, []);

  useEffect(() => {
    fetchData(selectedLanguage);
  }, [selectedLanguage]);

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    const defaultLang = languages[0]?.code || 'zh';
    form.setFieldsValue({ language: defaultLang, color: '#1890ff', sortOrder: 0, isActive: true });
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteTag(id);
      message.success('删除成功');
      fetchData();
    } catch (error) {
      message.error('删除失败');
    }
  };

  const handleModalOk = async () => {
    try {
      setSubmitLoading(true);
      const values = await form.validateFields();

      // 处理颜色值
      if (typeof values.color === 'object') {
        values.color = values.color.toHexString();
      }

      if (editingItem) {
        const res: any = await updateTag(editingItem.id, values);
        if (res.code === 200) {
          message.success('更新成功');
          setModalVisible(false);
          fetchData();
        } else {
          message.error(res.message || '更新失败');
        }
      } else {
        const res: any = await createTag(values);
        if (res.code === 200) {
          message.success('创建成功');
          setModalVisible(false);
          fetchData();
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
    {
      title: '标签名称',
      dataIndex: 'name',
      key: 'name',
      render: (text: string, record: any) => (
        <span style={{ color: record.color }}>{text}</span>
      )
    },
    {
      title: '语言',
      dataIndex: 'language',
      key: 'language',
      width: 100,
      render: (lang: string) => {
        const language = languages.find(l => l.code === lang);
        return language?.name || lang;
      }
    },
    {
      title: '颜色',
      dataIndex: 'color',
      key: 'color',
      width: 120,
      render: (color: string) => (
        <Space>
          <div style={{
            width: 20,
            height: 20,
            backgroundColor: color,
            border: '1px solid #d9d9d9',
            borderRadius: 2
          }} />
          <span>{color}</span>
        </Space>
      )
    },
    { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', width: 100 },
    {
      title: '状态',
      dataIndex: 'isActive',
      key: 'isActive',
      width: 100,
      render: (val: boolean) => val ? '启用' : '禁用'
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
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
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Space>
          <span>语言筛选:</span>
          <Select
            value={selectedLanguage}
            onChange={setSelectedLanguage}
            style={{ width: 120 }}
            allowClear
            placeholder="全部"
          >
            {languages.map(lang => (
              <Select.Option key={lang.code} value={lang.code}>
                {lang.name}
              </Select.Option>
            ))}
          </Select>
        </Space>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增标签
        </Button>
      </div>
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal
        title={editingItem ? '编辑标签' : '新增标签'}
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
      >
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="标签名称" rules={[{ required: true, message: '请输入标签名称' }]}>
            <Input placeholder="例如：热门、新书、精选" />
          </Form.Item>
          <Form.Item name="language" label="语言" rules={[{ required: true, message: '请选择语言' }]}>
            <Select disabled={!!editingItem}>
              {languages.map(lang => (
                <Select.Option key={lang.code} value={lang.code}>
                  {lang.name}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item name="color" label="标签颜色" rules={[{ required: true, message: '请选择颜色' }]}>
            <ColorPicker showText format="hex" />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序" rules={[{ required: true, message: '请输入排序' }]}>
            <InputNumber min={0} style={{ width: '100%' }} placeholder="数字越小越靠前" />
          </Form.Item>
          <Form.Item name="isActive" label="是否启用" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

const CategoryManagementTab: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [selectedLanguage, setSelectedLanguage] = useState<string | undefined>(undefined);
  const [languages, setLanguages] = useState<any[]>([]);
  const [form] = Form.useForm();

  const fetchLanguages = async () => {
    try {
      const res: any = await getLanguages();
      setLanguages(res.data || []);
    } catch (error) {
      message.error('获取语言失败');
    }
  };

  const fetchData = async (language?: string) => {
    setLoading(true);
    try {
      const res: any = await getCategories(language);
      setData(res.data || []);
    } catch (error) {
      message.error('获取分类失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLanguages();
    fetchData(); // 初始加载所有数据
  }, []);

  useEffect(() => {
    fetchData(selectedLanguage);
  }, [selectedLanguage]);

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    const defaultLang = languages[0]?.code || 'zh';
    form.setFieldsValue({ language: defaultLang, sortOrder: 0 });
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteCategory(id);
      message.success('删除成功');
      fetchData(selectedLanguage);
    } catch (error) {
      message.error('删除失败');
    }
  };

  const handleModalOk = async () => {
    try {
      setSubmitLoading(true);
      const values = await form.validateFields();

      if (editingItem) {
        const res: any = await updateCategory(editingItem.id, values);
        if (res.code === 200) {
          message.success('更新成功');
          setModalVisible(false);
          fetchData(selectedLanguage);
        } else {
          message.error(res.message || '更新失败');
        }
      } else {
        const res: any = await createCategory(values);
        if (res.code === 200) {
          message.success('创建成功');
          setModalVisible(false);
          fetchData(selectedLanguage);
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
    { title: '分类名称', dataIndex: 'name', key: 'name' },
    {
      title: '语言',
      dataIndex: 'language',
      key: 'language',
      width: 100,
      render: (lang: string) => {
        const language = languages.find(l => l.code === lang);
        return language?.name || lang;
      }
    },
    { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', width: 100 },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
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
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Space>
          <span>语言筛选:</span>
          <Select
            value={selectedLanguage}
            onChange={setSelectedLanguage}
            style={{ width: 120 }}
            allowClear
            placeholder="全部"
          >
            {languages.map(lang => (
              <Select.Option key={lang.code} value={lang.code}>
                {lang.name}
              </Select.Option>
            ))}
          </Select>
        </Space>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增分类
        </Button>
      </div>
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal
        title={editingItem ? '编辑分类' : '新增分类'}
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
      >
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="分类名称" rules={[{ required: true, message: '请输入分类名称' }]}>
            <Input placeholder="例如：小说、漫画、杂志" />
          </Form.Item>
          <Form.Item name="language" label="语言" rules={[{ required: true, message: '请选择语言' }]}>
            <Select disabled={!!editingItem}>
              {languages.map(lang => (
                <Select.Option key={lang.code} value={lang.code}>
                  {lang.name}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item name="sortOrder" label="排序" rules={[{ required: true, message: '请输入排序' }]}>
            <InputNumber min={0} style={{ width: '100%' }} placeholder="数字越小越靠前" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

const LanguageManagementTab: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);
  const [form] = Form.useForm();

  const fetchData = async () => {
    setLoading(true);
    try {
      const res: any = await getLanguages();
      setData(res.data || []);
    } catch (error) {
      message.error('获取语言失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAdd = () => {
    setEditingItem(null);
    form.resetFields();
    form.setFieldsValue({ isActive: true, sortOrder: 0 });
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteLanguage(id);
      message.success('删除成功');
      fetchData();
    } catch (error) {
      message.error('删除失败');
    }
  };

  const handleModalOk = async () => {
    try {
      setSubmitLoading(true);
      const values = await form.validateFields();

      if (editingItem) {
        const res: any = await updateLanguage(editingItem.id, values);
        if (res.code === 200) {
          message.success('更新成功');
          setModalVisible(false);
          fetchData();
        } else {
          message.error(res.message || '更新失败');
        }
      } else {
        const res: any = await createLanguage(values);
        if (res.code === 200) {
          message.success('创建成功');
          setModalVisible(false);
          fetchData();
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
    { title: '语言代码', dataIndex: 'code', key: 'code', width: 100 },
    { title: '语言名称', dataIndex: 'name', key: 'name' },
    { title: '排序', dataIndex: 'sortOrder', key: 'sortOrder', width: 100 },
    {
      title: '状态',
      dataIndex: 'isActive',
      key: 'isActive',
      width: 100,
      render: (val: boolean) => val ? '启用' : '禁用'
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
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
      <div style={{ marginBottom: 16 }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
          新增语言
        </Button>
      </div>
      <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={false} />

      <Modal
        title={editingItem ? '编辑语言' : '新增语言'}
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
      >
        <Form form={form} layout="vertical">
          <Form.Item name="code" label="语言代码" rules={[{ required: true, message: '请输入语言代码' }]}>
            <Input placeholder="例如：zh, en, ja" disabled={!!editingItem} />
          </Form.Item>
          <Form.Item name="name" label="语言名称" rules={[{ required: true, message: '请输入语言名称' }]}>
            <Input placeholder="例如：中文, English, 日本語" />
          </Form.Item>
          <Form.Item name="sortOrder" label="排序" rules={[{ required: true, message: '请输入排序' }]}>
            <InputNumber min={0} style={{ width: '100%' }} placeholder="数字越小越靠前" />
          </Form.Item>
          <Form.Item name="isActive" label="是否启用" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

const SystemManagement: React.FC = () => {
  return (
    <Card>
      <Tabs defaultActiveKey="1">
        <TabPane tab="系统配置" key="1">
          <SystemConfigTab />
        </TabPane>
        <TabPane tab="管理员管理" key="2">
          <AdminUserTab />
        </TabPane>
        <TabPane tab="语言管理" key="3">
          <LanguageManagementTab />
        </TabPane>
        <TabPane tab="分类管理" key="4">
          <CategoryManagementTab />
        </TabPane>
        <TabPane tab="标签管理" key="5">
          <TagManagementTab />
        </TabPane>
        <TabPane tab="操作日志" key="6">
          <LogTab />
        </TabPane>
      </Tabs>
    </Card>
  );
};

export default SystemManagement;
