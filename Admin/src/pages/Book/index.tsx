import React, { useEffect, useState } from 'react';
import { Table, Button, Input, Space, Modal, Form, message, Popconfirm } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined, SearchOutlined } from '@ant-design/icons';
import { getBooks, createBook, updateBook, deleteBook } from '../../api/book';

const BookManagement: React.FC = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [searchKeyword, setSearchKeyword] = useState('');
  const [modalVisible, setModalVisible] = useState(false);
  const [editingBook, setEditingBook] = useState<any>(null);
  const [form] = Form.useForm();

  const fetchBooks = async (page = 1, keyword = '') => {
    setLoading(true);
    try {
      const res: any = await getBooks({ page, size: pagination.pageSize, keyword });
      setData(res.records);
      setPagination({ ...pagination, current: page, total: res.total });
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBooks();
  }, []);

  const handleSearch = () => {
    fetchBooks(1, searchKeyword);
  };

  const handleAdd = () => {
    setEditingBook(null);
    form.resetFields();
    setModalVisible(true);
  };

  const handleEdit = (record: any) => {
    setEditingBook(record);
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  const handleDelete = async (id: number) => {
    try {
      await deleteBook(id);
      message.success('删除成功');
      fetchBooks(pagination.current, searchKeyword);
    } catch (error) {
      console.error(error);
    }
  };

  const handleModalOk = async () => {
    try {
      const values = await form.validateFields();
      if (editingBook) {
        await updateBook(editingBook.id, values);
        message.success('更新成功');
      } else {
        await createBook(values);
        message.success('创建成功');
      }
      setModalVisible(false);
      fetchBooks(pagination.current, searchKeyword);
    } catch (error) {
      console.error(error);
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '书名', dataIndex: 'title', key: 'title' },
    { title: '作者', dataIndex: 'author', key: 'author' },
    { title: '分类', dataIndex: 'category', key: 'category' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    { title: '评分', dataIndex: 'rating', key: 'rating', width: 80 },
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
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between' }}>
        <Space>
          <Input
            placeholder="搜索书籍"
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
          新增书籍
        </Button>
      </div>

      <Table
        columns={columns}
        dataSource={data}
        rowKey="id"
        loading={loading}
        pagination={{
          ...pagination,
          onChange: (page) => fetchBooks(page, searchKeyword),
        }}
      />

      <Modal
        title={editingBook ? '编辑书籍' : '新增书籍'}
        open={modalVisible}
        onOk={handleModalOk}
        onCancel={() => setModalVisible(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="书名" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="author" label="作者" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="category" label="分类">
            <Input />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input.TextArea rows={4} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default BookManagement;
