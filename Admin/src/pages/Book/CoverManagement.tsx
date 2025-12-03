import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Select, Badge, Image, Popconfirm, message, Upload, Card, Row, Col, Tag } from 'antd';
import { UploadOutlined, FileZipOutlined, EditOutlined, DeleteOutlined, CheckCircleOutlined, CloseCircleOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import { getCoverImages, deleteCover, uploadSingleCover, markCoverAsUsed } from '../../api/coverImage';
import type { CoverImage, CoverImageQuery } from '../../api/coverImage';
import BatchUploadModal from './components/BatchUploadModal';
import ReplaceCoverModal from './components/ReplaceCoverModal';

const { Option } = Select;

const CoverManagement: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [covers, setCovers] = useState<CoverImage[]>([]);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });

  // 筛选条件
  const [filters, setFilters] = useState<CoverImageQuery>({
    page: 1,
    size: 20,
  });

  // 模态框状态
  const [batchUploadVisible, setBatchUploadVisible] = useState(false);
  const [replaceModalVisible, setReplaceModalVisible] = useState(false);
  const [selectedCover, setSelectedCover] = useState<CoverImage | null>(null);

  // 加载封面列表
  const loadCovers = async () => {
    setLoading(true);
    try {
      const res: any = await getCoverImages(filters);
      const data = res.data?.data || res.data;

      setCovers(data.records || []);
      setPagination({
        current: data.current || 1,
        pageSize: data.size || 20,
        total: data.total || 0,
      });
    } catch (error: any) {
      message.error('加载失败: ' + (error.response?.data?.message || error.message));
    } finally {
      setLoading(false);
    }
  };

  // 初始加载
  useEffect(() => {
    loadCovers();
  }, [filters]);

  // 单个上传
  const handleSingleUpload = async (file: File) => {
    try {
      await uploadSingleCover(file);
      message.success('上传成功');
      loadCovers();
    } catch (error: any) {
      message.error('上传失败: ' + (error.response?.data?.message || error.message));
    }
    return false;
  };

  // 删除封面
  const handleDelete = async (id: number) => {
    try {
      await deleteCover(id);
      message.success('删除成功');
      loadCovers();
    } catch (error: any) {
      message.error('删除失败: ' + (error.response?.data?.message || error.message));
    }
  };

  // 标记使用状态
  const handleMarkAsUsed = async (id: number, used: boolean) => {
    try {
      await markCoverAsUsed(id, used);
      message.success('标记成功');
      loadCovers();
    } catch (error: any) {
      message.error('标记失败: ' + (error.response?.data?.message || error.message));
    }
  };

  // 打开替换模态框
  const handleReplace = (cover: CoverImage) => {
    setSelectedCover(cover);
    setReplaceModalVisible(true);
  };

  // 格式化文件大小
  const formatFileSize = (bytes: number) => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(2) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
  };

  // 表格列定义
  const columns: ColumnsType<CoverImage> = [
    {
      title: '封面预览',
      dataIndex: 'fileUrl',
      key: 'preview',
      width: 100,
      render: (url, record) => (
        <Image
          src={url}
          alt={record.fileName}
          width={50}
          height={70}
          style={{ objectFit: 'cover', borderRadius: 4 }}
        />
      ),
    },
    {
      title: '文件名',
      dataIndex: 'fileName',
      key: 'fileName',
      ellipsis: true,
    },
    {
      title: '尺寸',
      key: 'dimensions',
      width: 120,
      render: (_, record) => (
        record.width && record.height ? `${record.width} × ${record.height}` : '-'
      ),
    },
    {
      title: '文件大小',
      dataIndex: 'fileSize',
      key: 'fileSize',
      width: 100,
      render: (size) => formatFileSize(size),
    },
    {
      title: '上传方式',
      dataIndex: 'uploadSource',
      key: 'uploadSource',
      width: 100,
      render: (source) => (
        <Tag color={source === 'batch' ? 'blue' : 'green'}>
          {source === 'batch' ? '批量上传' : '单个上传'}
        </Tag>
      ),
    },
    {
      title: '使用状态',
      dataIndex: 'isUsed',
      key: 'isUsed',
      width: 100,
      render: (used) => (
        <Badge
          status={used ? 'success' : 'default'}
          text={used ? '已使用' : '未使用'}
        />
      ),
    },
    {
      title: '上传时间',
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 160,
      render: (time) => dayjs(time).format('YYYY-MM-DD HH:mm:ss'),
    },
    {
      title: '操作',
      key: 'actions',
      width: 200,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleReplace(record)}
          >
            替换
          </Button>
          <Button
            type="link"
            size="small"
            icon={record.isUsed ? <CloseCircleOutlined /> : <CheckCircleOutlined />}
            onClick={() => handleMarkAsUsed(record.id, !record.isUsed)}
          >
            {record.isUsed ? '标记未使用' : '标记已使用'}
          </Button>
          <Popconfirm
            title={record.isUsed ? '该封面正在使用中，无法删除' : '确认删除此封面？'}
            onConfirm={() => handleDelete(record.id)}
            disabled={record.isUsed}
            okText="确认"
            cancelText="取消"
          >
            <Button
              type="link"
              danger
              size="small"
              icon={<DeleteOutlined />}
              disabled={record.isUsed}
            >
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <Card>
      {/* 工具栏 */}
      <Row gutter={16} style={{ marginBottom: 16 }}>
        <Col>
          <Upload
            accept="image/*"
            showUploadList={false}
            beforeUpload={handleSingleUpload}
          >
            <Button type="primary" icon={<UploadOutlined />}>
              上传单个封面
            </Button>
          </Upload>
        </Col>
        <Col>
          <Button
            icon={<FileZipOutlined />}
            onClick={() => setBatchUploadVisible(true)}
          >
            批量上传（ZIP）
          </Button>
        </Col>
        <Col flex="auto" />
        <Col>
          <Select
            placeholder="使用状态"
            style={{ width: 150 }}
            allowClear
            value={filters.isUsed}
            onChange={(value) => setFilters({ ...filters, isUsed: value, page: 1 })}
          >
            <Option value={true}>已使用</Option>
            <Option value={false}>未使用</Option>
          </Select>
        </Col>
        <Col>
          <Select
            placeholder="上传方式"
            style={{ width: 150 }}
            allowClear
            value={filters.uploadSource}
            onChange={(value) => setFilters({ ...filters, uploadSource: value, page: 1 })}
          >
            <Option value="single">单个上传</Option>
            <Option value="batch">批量上传</Option>
          </Select>
        </Col>
      </Row>

      {/* 表格 */}
      <Table
        columns={columns}
        dataSource={covers}
        loading={loading}
        rowKey="id"
        pagination={{
          ...pagination,
          showSizeChanger: true,
          showTotal: (total) => `共 ${total} 条`,
          onChange: (page, pageSize) => {
            setFilters({ ...filters, page, size: pageSize });
          },
        }}
        scroll={{ x: 1200 }}
      />

      {/* 批量上传模态框 */}
      <BatchUploadModal
        visible={batchUploadVisible}
        onClose={() => setBatchUploadVisible(false)}
        onSuccess={() => {
          loadCovers();
        }}
      />

      {/* 替换封面模态框 */}
      <ReplaceCoverModal
        visible={replaceModalVisible}
        cover={selectedCover}
        onClose={() => {
          setReplaceModalVisible(false);
          setSelectedCover(null);
        }}
        onSuccess={() => {
          loadCovers();
        }}
      />
    </Card>
  );
};

export default CoverManagement;
