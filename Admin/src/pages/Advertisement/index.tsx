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
  Upload,
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  LoadingOutlined,
  UploadOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { RcFile } from 'antd/es/upload/interface';
import dayjs from 'dayjs';
import {
  getAdvertisements,
  createAdvertisement,
  updateAdvertisement,
  deleteAdvertisement,
  toggleAdvertisementStatus,
  type Advertisement,
} from '../../api/advertisement';
import { getBooks } from '../../api/book';
import { uploadFile } from '../../api/upload';

const { Option } = Select;

const AdvertisementManagement: React.FC = () => {
  const [data, setData] = useState<Advertisement[]>([]);
  const [books, setBooks] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingItem, setEditingItem] = useState<Advertisement | null>(null);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [uploadLoading, setUploadLoading] = useState(false);
  const [imageUrl, setImageUrl] = useState<string>('');
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });
  const [form] = Form.useForm();

  // 获取广告列表
  const fetchData = async (page = 1) => {
    setLoading(true);
    try {
      const res: any = await getAdvertisements({
        page,
        size: pagination.pageSize,
      });
      if (res.code === 200) {
        setData(res.data.records || []);
        setPagination({
          ...pagination,
          current: page,
          total: res.data.total || 0,
        });
      }
    } catch (error) {
      message.error('获取广告列表失败');
    } finally {
      setLoading(false);
    }
  };

  // 获取书籍列表
  const fetchBooks = async () => {
    try {
      const res: any = await getBooks({ page: 1, size: 1000 });
      if (res.code === 200) {
        setBooks(res.data.records || []);
      }
    } catch (error) {
      console.error('获取书籍列表失败', error);
    }
  };

  useEffect(() => {
    fetchData();
    fetchBooks();
  }, []);

  // 打开新增/编辑模态框
  const handleOpenModal = (item?: Advertisement) => {
    if (item) {
      setEditingItem(item);
      setImageUrl(item.imageUrl);
      form.setFieldsValue({
        ...item,
      });
    } else {
      setEditingItem(null);
      setImageUrl('');
      form.resetFields();
      form.setFieldsValue({
        targetType: 'book',
        position: 'home_banner',
        sortOrder: 0,
        isActive: true,
      });
    }
    setModalVisible(true);
  };

  // 关闭模态框
  const handleCloseModal = () => {
    setModalVisible(false);
    setEditingItem(null);
    setImageUrl('');
    form.resetFields();
  };

  // 处理图片上传
  const handleUpload = async (file: RcFile) => {
    setUploadLoading(true);
    try {
      const res: any = await uploadFile(file, 'advertisements');
      const url = res.data;
      setImageUrl(url);
      form.setFieldsValue({ imageUrl: url });
      message.success('图片上传成功');
    } catch (error) {
      message.error('图片上传失败');
    } finally {
      setUploadLoading(false);
    }
    return false; // 阻止默认上传行为
  };

  // 上传按钮
  const uploadButton = (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px'
    }}>
      {uploadLoading ? (
        <LoadingOutlined style={{ fontSize: 32, color: '#1890ff' }} />
      ) : (
        <PlusOutlined style={{ fontSize: 32, color: '#999' }} />
      )}
      <div style={{ marginTop: 12, color: '#666', fontSize: '14px' }}>
        上传图片
      </div>
    </div>
  );

  // 提交表单
  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();
      setSubmitLoading(true);

      // 确保数据类型正确
      const submitData: any = {
        title: String(values.title || ''),
        imageUrl: String(imageUrl || values.imageUrl || ''),
        targetType: String(values.targetType || 'book'),
        position: String(values.position || 'home_banner'),
        sortOrder: Number(values.sortOrder || 0),
        isActive: Boolean(values.isActive),
      };

      // 根据targetType处理目标字段
      if (values.targetType === 'book' && values.targetId) {
        submitData.targetId = Number(values.targetId);
      } else if (values.targetType === 'url' && values.targetUrl) {
        submitData.targetUrl = String(values.targetUrl);
      }

      let res: any;
      if (editingItem) {
        res = await updateAdvertisement(editingItem.id!, submitData);
      } else {
        res = await createAdvertisement(submitData);
      }

      if (res.code === 200) {
        message.success(editingItem ? '更新成功' : '创建成功');
        handleCloseModal();
        fetchData(pagination.current);
      } else {
        message.error(res.message || '操作失败');
      }
    } catch (error) {
      console.error('提交失败:', error);
      message.error('操作失败');
    } finally {
      setSubmitLoading(false);
    }
  };

  // 删除广告
  const handleDelete = async (id: number) => {
    setLoading(true);
    try {
      const res: any = await deleteAdvertisement(id);
      if (res.code === 200) {
        message.success('删除成功');
        fetchData(pagination.current);
      } else {
        message.error(res.message || '删除失败');
        setLoading(false);
      }
    } catch (error) {
      message.error('删除失败');
      setLoading(false);
    }
  };

  // 切换状态
  const handleToggleStatus = async (id: number) => {
    setLoading(true);
    try {
      const res: any = await toggleAdvertisementStatus(id);
      if (res.code === 200) {
        message.success('状态更新成功');
        fetchData(pagination.current);
      } else {
        message.error(res.message || '状态更新失败');
        setLoading(false);
      }
    } catch (error) {
      message.error('状态更新失败');
      setLoading(false);
    }
  };

  // 表格列定义
  const columns: ColumnsType<Advertisement> = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: '标题',
      dataIndex: 'title',
      key: 'title',
      width: 200,
    },
    {
      title: '广告图片',
      dataIndex: 'imageUrl',
      key: 'imageUrl',
      width: 150,
      render: (imageUrl: string) =>
        imageUrl ? (
          <img
            src={imageUrl}
            alt="广告图片"
            style={{ width: 100, height: 60, objectFit: 'cover' }}
          />
        ) : (
          '-'
        ),
    },
    {
      title: '位置',
      dataIndex: 'position',
      key: 'position',
      width: 120,
      render: (position: string) => {
        const positionMap: any = {
          home_banner: '首页轮播',
          home_popup: '首页弹窗',
        };
        return positionMap[position] || position;
      },
    },
    {
      title: '跳转类型',
      dataIndex: 'targetType',
      key: 'targetType',
      width: 100,
      render: (type: string) => {
        const typeMap: any = {
          book: '书籍',
          url: '链接',
          none: '无',
        };
        return (
          <Tag color={type === 'book' ? 'blue' : type === 'url' ? 'green' : 'default'}>
            {typeMap[type]}
          </Tag>
        );
      },
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
          {isActive ? '启用' : '禁用'}
        </Tag>
      ),
    },
    {
      title: '创建时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 180,
      render: (date: string) => (date ? dayjs(date).format('YYYY-MM-DD HH:mm:ss') : '-'),
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 200,
      render: (_: any, record: Advertisement) => (
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
            onClick={() => handleToggleStatus(record.id!)}
          >
            {record.isActive ? '禁用' : '启用'}
          </Button>
          <Popconfirm
            title="确定要删除吗？"
            onConfirm={() => handleDelete(record.id!)}
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
        title="广告管理"
        extra={
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => handleOpenModal()}
          >
            新增广告
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          pagination={{
            ...pagination,
            onChange: (page) => fetchData(page),
          }}
          scroll={{ x: 1400 }}
        />
      </Card>

      {/* 新增/编辑模态框 */}
      <Modal
        title={editingItem ? '编辑广告' : '新增广告'}
        open={modalVisible}
        onCancel={handleCloseModal}
        onOk={handleSubmit}
        confirmLoading={submitLoading}
        width={700}
        destroyOnClose
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="title"
            label="广告标题"
            rules={[{ required: true, message: '请输入广告标题' }]}
          >
            <Input placeholder="请输入广告标题" />
          </Form.Item>

          <Form.Item
            name="imageUrl"
            label="广告图片"
            rules={[{ required: true, message: '请上传广告图片' }]}
          >
            <Upload
              name="file"
              listType="picture-card"
              showUploadList={false}
              beforeUpload={handleUpload}
              accept="image/*"
            >
              {imageUrl ? (
                <img
                  src={imageUrl}
                  alt="广告图片"
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
              ) : (
                uploadButton
              )}
            </Upload>
          </Form.Item>

          <Form.Item
            name="position"
            label="广告位置"
            rules={[{ required: true, message: '请选择广告位置' }]}
          >
            <Select placeholder="请选择广告位置">
              <Option value="home_banner">首页轮播</Option>
              <Option value="home_popup">首页弹窗</Option>
            </Select>
          </Form.Item>

          <Form.Item
            name="targetType"
            label="跳转类型"
            rules={[{ required: true, message: '请选择跳转类型' }]}
          >
            <Select placeholder="请选择跳转类型">
              <Option value="book">书籍</Option>
              <Option value="url">链接</Option>
              <Option value="none">无</Option>
            </Select>
          </Form.Item>

          <Form.Item
            noStyle
            shouldUpdate={(prevValues, currentValues) =>
              prevValues.targetType !== currentValues.targetType
            }
          >
            {({ getFieldValue }) => {
              const targetType = getFieldValue('targetType');

              if (targetType === 'book') {
                return (
                  <Form.Item
                    name="targetId"
                    label="目标书籍"
                    rules={[{ required: true, message: '请选择目标书籍' }]}
                  >
                    <Select
                      placeholder="请选择目标书籍"
                      showSearch
                      filterOption={(input, option) =>
                        (option?.children as string)
                          ?.toLowerCase()
                          .includes(input.toLowerCase())
                      }
                    >
                      {books.map((book) => (
                        <Option key={book.id} value={book.id}>
                          {book.title}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                );
              }

              if (targetType === 'url') {
                return (
                  <Form.Item
                    name="targetUrl"
                    label="目标链接"
                    rules={[
                      { required: true, message: '请输入目标链接' },
                      { type: 'url', message: '请输入有效的URL' },
                    ]}
                  >
                    <Input placeholder="https://example.com" />
                  </Form.Item>
                );
              }

              return null;
            }}
          </Form.Item>

          <Form.Item
            name="sortOrder"
            label="排序"
            rules={[{ required: true, message: '请输入排序' }]}
          >
            <InputNumber
              min={0}
              style={{ width: '100%' }}
              placeholder="数字越小越靠前"
            />
          </Form.Item>

          <Form.Item name="isActive" label="是否启用" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default AdvertisementManagement;
