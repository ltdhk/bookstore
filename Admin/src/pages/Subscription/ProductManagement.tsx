import React, { useEffect, useState } from 'react';
import {
  Table,
  Button,
  Modal,
  Form,
  Input,
  InputNumber,
  Select,
  Switch,
  message,
  Popconfirm,
  Space,
  Card,
  Tag,
} from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  getSubscriptionProducts,
  createSubscriptionProduct,
  updateSubscriptionProduct,
  deleteSubscriptionProduct,
  toggleProductStatus,
  type SubscriptionProduct,
} from '../../api/subscription';

const { Option } = Select;
const { TextArea } = Input;

const ProductManagement: React.FC = () => {
  const [products, setProducts] = useState<SubscriptionProduct[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingProduct, setEditingProduct] = useState<SubscriptionProduct | null>(null);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [form] = Form.useForm();

  // 获取产品列表
  const fetchProducts = async () => {
    setLoading(true);
    try {
      const res: any = await getSubscriptionProducts();
      if (res.code === 200) {
        setProducts(res.data || []);
      }
    } catch (error) {
      message.error('获取产品列表失败');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, []);

  // 打开新增/编辑模态框
  const handleOpenModal = (product?: SubscriptionProduct) => {
    if (product) {
      setEditingProduct(product);
      form.setFieldsValue(product);
    } else {
      setEditingProduct(null);
      form.resetFields();
    }
    setModalVisible(true);
  };

  // 关闭模态框
  const handleCloseModal = () => {
    setModalVisible(false);
    setEditingProduct(null);
    form.resetFields();
  };

  // 提交表单
  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();
      setSubmitLoading(true);

      let res: any;
      if (editingProduct) {
        res = await updateSubscriptionProduct(editingProduct.id, values);
      } else {
        res = await createSubscriptionProduct(values);
      }

      if (res.code === 200) {
        message.success(editingProduct ? '更新成功' : '创建成功');
        handleCloseModal();
        fetchProducts();
      } else {
        message.error(res.message || '操作失败');
      }
    } catch (error) {
      message.error('操作失败');
    } finally {
      setSubmitLoading(false);
    }
  };

  // 删除产品
  const handleDelete = async (id: number) => {
    try {
      const res: any = await deleteSubscriptionProduct(id);
      if (res.code === 200) {
        message.success('删除成功');
        fetchProducts();
      } else {
        message.error(res.message || '删除失败');
      }
    } catch (error) {
      message.error('删除失败');
    }
  };

  // 切换产品状态
  const handleToggleStatus = async (id: number) => {
    try {
      const res: any = await toggleProductStatus(id);
      if (res.code === 200) {
        message.success('状态更新成功');
        fetchProducts();
      } else {
        message.error(res.message || '状态更新失败');
      }
    } catch (error) {
      message.error('状态更新失败');
    }
  };

  // 表格列定义
  const columns: ColumnsType<SubscriptionProduct> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: '产品ID',
      dataIndex: 'productId',
      key: 'productId',
      width: 200,
    },
    {
      title: '产品名称',
      dataIndex: 'productName',
      key: 'productName',
      width: 150,
    },
    {
      title: '订阅类型',
      dataIndex: 'planType',
      key: 'planType',
      width: 120,
      render: (planType: string) => {
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
        return <Tag color={colorMap[planType]}>{textMap[planType] || planType}</Tag>;
      },
    },
    {
      title: '时长(天)',
      dataIndex: 'durationDays',
      key: 'durationDays',
      width: 100,
    },
    {
      title: '价格',
      dataIndex: 'price',
      key: 'price',
      width: 100,
      render: (price: number, record: SubscriptionProduct) =>
        `${record.currency} ${price.toFixed(2)}`,
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
      title: 'Apple产品ID',
      dataIndex: 'appleProductId',
      key: 'appleProductId',
      width: 150,
      render: (text: string) => text || '-',
    },
    {
      title: 'Google产品ID',
      dataIndex: 'googleProductId',
      key: 'googleProductId',
      width: 150,
      render: (text: string) => text || '-',
    },
    {
      title: '排序',
      dataIndex: 'sortOrder',
      key: 'sortOrder',
      width: 80,
    },
    {
      title: '状态',
      dataIndex: 'isActive',
      key: 'isActive',
      width: 100,
      render: (isActive: boolean) => (
        <Tag color={isActive ? 'success' : 'default'}>
          {isActive ? '激活' : '未激活'}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 200,
      render: (_: any, record: SubscriptionProduct) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleOpenModal(record)}
          >
            编辑
          </Button>
          <Button
            type="link"
            size="small"
            onClick={() => handleToggleStatus(record.id)}
          >
            {record.isActive ? '停用' : '启用'}
          </Button>
          <Popconfirm
            title="确定要删除吗？"
            onConfirm={() => handleDelete(record.id)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" danger size="small" icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Card
        title="订阅产品管理"
        extra={
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => handleOpenModal()}
          >
            新增产品
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={products}
          rowKey="id"
          loading={loading}
          pagination={false}
          scroll={{ x: 1500 }}
        />
      </Card>

      {/* 新增/编辑模态框 */}
      <Modal
        title={editingProduct ? '编辑订阅产品' : '新增订阅产品'}
        open={modalVisible}
        onCancel={handleCloseModal}
        onOk={handleSubmit}
        confirmLoading={submitLoading}
        width={700}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="productId"
            label="产品ID"
            rules={[{ required: true, message: '请输入产品ID' }]}
          >
            <Input placeholder="如: svip_monthly_apple" />
          </Form.Item>

          <Form.Item
            name="productName"
            label="产品名称"
            rules={[{ required: true, message: '请输入产品名称' }]}
          >
            <Input placeholder="如: SVIP Monthly" />
          </Form.Item>

          <Form.Item
            name="planType"
            label="订阅类型"
            rules={[{ required: true, message: '请选择订阅类型' }]}
          >
            <Select placeholder="请选择订阅类型">
              <Option value="monthly">月度</Option>
              <Option value="quarterly">季度</Option>
              <Option value="yearly">年度</Option>
            </Select>
          </Form.Item>

          <Form.Item
            name="durationDays"
            label="订阅时长(天)"
            rules={[{ required: true, message: '请输入订阅时长' }]}
          >
            <InputNumber min={1} style={{ width: '100%' }} placeholder="30" />
          </Form.Item>

          <Form.Item
            name="price"
            label="价格"
            rules={[{ required: true, message: '请输入价格' }]}
          >
            <InputNumber
              min={0}
              precision={2}
              style={{ width: '100%' }}
              placeholder="9.99"
            />
          </Form.Item>

          <Form.Item
            name="currency"
            label="货币"
            rules={[{ required: true, message: '请输入货币类型' }]}
            initialValue="USD"
          >
            <Input placeholder="USD" />
          </Form.Item>

          <Form.Item
            name="platform"
            label="平台"
            rules={[{ required: true, message: '请选择平台' }]}
          >
            <Select placeholder="请选择平台">
              <Option value="AppStore">AppStore</Option>
              <Option value="GooglePay">GooglePay</Option>
            </Select>
          </Form.Item>

          <Form.Item name="appleProductId" label="Apple产品ID">
            <Input placeholder="如: com.bookstore.svip.monthly" />
          </Form.Item>

          <Form.Item name="googleProductId" label="Google产品ID">
            <Input placeholder="如: svip_monthly" />
          </Form.Item>

          <Form.Item
            name="sortOrder"
            label="排序"
            rules={[{ required: true, message: '请输入排序' }]}
            initialValue={1}
          >
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>

          <Form.Item
            name="isActive"
            label="是否激活"
            valuePropName="checked"
            initialValue={true}
          >
            <Switch />
          </Form.Item>

          <Form.Item name="description" label="描述">
            <TextArea rows={3} placeholder="产品描述" />
          </Form.Item>

          <Form.Item name="features" label="特性(JSON格式)">
            <TextArea
              rows={4}
              placeholder='如: ["无限阅读", "离线下载", "去广告"]'
            />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default ProductManagement;
