import React, { useEffect, useState } from 'react';
import {
  Table,
  Button,
  Modal,
  Form,
  Input,
  Select,
  Switch,
  message,
  Popconfirm,
  Space,
  Row,
  Col,
  Card,
  InputNumber,
  Upload,
} from 'antd';
import { SearchOutlined, LoadingOutlined, PlusOutlined, KeyOutlined } from '@ant-design/icons';
import type { RcFile } from 'antd/es/upload/interface';
import { useTranslation } from 'react-i18next';
import { getBooks, createBook, updateBook, deleteBook } from '../../api/book';
import { getCategories } from '../../api/category';
import { getChapters, createChapter, updateChapter, deleteChapter } from '../../api/chapter';
import { getActiveLanguages } from '../../api/language';
import { uploadFile } from '../../api/upload';
import { getActiveTags, getBookTags, updateBookTags } from '../../api/tag';
import {
  getBookPasscodes,
  createPasscode,
  updatePasscode,
  deletePasscode,
  getPasscodeStats,
  getPasscodeLogs,
  type BookPasscode,
  type PasscodeStats,
  type PasscodeUsageLog
} from '../../api/passcode';
import { getActiveDistributors } from '../../api/distributor';
import RichTextEditor from '../../components/RichTextEditor';

const { TextArea } = Input;

const BookManagement: React.FC = () => {
  const { t } = useTranslation();
  const [books, setBooks] = useState<any[]>([]);
  const [categories, setCategories] = useState<any[]>([]);
  const [languages, setLanguages] = useState<any[]>([]);
  const [tags, setTags] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [chapterModalVisible, setChapterModalVisible] = useState(false);
  const [chapterFormVisible, setChapterFormVisible] = useState(false);
  const [editingBook, setEditingBook] = useState<any | null>(null);
  const [currentBookId, setCurrentBookId] = useState<number | null>(null);
  const [chapters, setChapters] = useState<any[]>([]);
  const [editingChapter, setEditingChapter] = useState<any | null>(null);
  const [_selectedLanguage, setSelectedLanguage] = useState<string>('');
  const [uploadLoading, setUploadLoading] = useState(false);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [imageUrl, setImageUrl] = useState<string>('');
  const [form] = Form.useForm();
  const [chapterForm] = Form.useForm();
  const [searchForm] = Form.useForm();
  const [passcodeForm] = Form.useForm();

  // Passcode management state
  const [passcodeModalVisible, setPasscodeModalVisible] = useState(false);
  const [currentPasscodeBookId, setCurrentPasscodeBookId] = useState<number | null>(null);
  const [passcodes, setPasscodes] = useState<BookPasscode[]>([]);
  const [distributors, setDistributors] = useState<any[]>([]);
  const [editingPasscode, setEditingPasscode] = useState<BookPasscode | null>(null);
  const [passcodeFormVisible, setPasscodeFormVisible] = useState(false);
  const [statsModalVisible, setStatsModalVisible] = useState(false);
  const [logsModalVisible, setLogsModalVisible] = useState(false);
  const [currentStats, setCurrentStats] = useState<PasscodeStats | null>(null);
  const [currentLogs, setCurrentLogs] = useState<PasscodeUsageLog[]>([]);
  const [logsPage, setLogsPage] = useState(1);
  const [logsTotal, setLogsTotal] = useState(0);
  const [passcodeSubmitLoading, setPasscodeSubmitLoading] = useState(false);
  const [passcodeLoading, setPasscodeLoading] = useState(false);
  const [chapterLoading, setChapterLoading] = useState(false);

  // 搜索参数
  const [searchParams, setSearchParams] = useState({
    keyword: '',
    language: '',
    categoryId: undefined as number | undefined,
    isHot: undefined as boolean | undefined,
  });

  const fetchBooks = async (params = searchParams) => {
    setLoading(true);
    try {
      const res: any = await getBooks({
        page: 1,
        size: 100,
        ...params
      });
      setBooks(res.data?.records || []);
    } catch (error) {
      message.error(t('common.operationFailed'));
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async (language?: string) => {
    try {
      const res: any = await getCategories(language);
      setCategories(res.data || []);
    } catch (error) {
      message.error(t('common.operationFailed'));
    }
  };

  const fetchLanguages = async () => {
    try {
      const res: any = await getActiveLanguages();
      setLanguages(res.data || []);
    } catch (error) {
      message.error(t('common.operationFailed'));
    }
  };

  const fetchChapters = async (bookId: number) => {
    setChapterLoading(true);
    try {
      const res: any = await getChapters(bookId);
      setChapters(res.data || []);
    } catch (error) {
      message.error(t('common.operationFailed'));
    } finally {
      setChapterLoading(false);
    }
  };

  const fetchTags = async (language?: string) => {
    try {
      const res: any = await getActiveTags(language);
      setTags(res.data || []);
    } catch (error) {
      message.error(t('common.operationFailed'));
    }
  };

  const handleLanguageChange = async (language: string) => {
    setSelectedLanguage(language);
    form.setFieldsValue({ categoryId: undefined, tagIds: [] }); // 清空分类和标签选择
    await fetchCategories(language); // 根据语言加载分类
    await fetchTags(language); // 根据语言加载标签
  };

  useEffect(() => {
    fetchBooks();
    fetchCategories();
    fetchLanguages();
  }, []);

  const handleSearch = () => {
    const values = searchForm.getFieldsValue();
    setSearchParams(values);
    fetchBooks(values);
  };

  const handleResetSearch = () => {
    searchForm.resetFields();
    setSearchParams({
      keyword: '',
      language: '',
      categoryId: undefined,
      isHot: undefined,
    });
    fetchBooks({
      keyword: '',
      language: '',
      categoryId: undefined,
      isHot: undefined,
    });
  };

  const handleAdd = async () => {
    setEditingBook(null);
    form.resetFields();
    setImageUrl('');
    const defaultLang = languages[0]?.code || 'zh';
    form.setFieldsValue({ language: defaultLang, tagIds: [] });
    await fetchCategories(defaultLang); // 加载默认语言的分类
    await fetchTags(defaultLang); // 加载默认语言的标签
    setModalVisible(true);
  };

  const handleEdit = async (record: any) => {
    setEditingBook(record);
    form.setFieldsValue(record);
    setImageUrl(record.coverUrl || '');
    await fetchCategories(record.language); // 加载该书籍语言的分类
    await fetchTags(record.language); // 加载该书籍语言的标签

    // 加载书籍的标签
    try {
      const res: any = await getBookTags(record.id);
      form.setFieldsValue({ tagIds: res.data || [] });
    } catch (error) {
      console.error('获取书籍标签失败', error);
    }

    setModalVisible(true);
  };

  // 处理图片上传
  const handleUpload = async (file: RcFile) => {
    setUploadLoading(true);
    try {
      const res: any = await uploadFile(file, 'covers');
      const url = res.data;
      setImageUrl(url);
      form.setFieldsValue({ coverUrl: url });
      message.success(t('book.uploadSuccess'));
    } catch (error) {
      message.error(t('book.uploadFailed'));
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
        {t('book.uploadCover')}
      </div>
    </div>
  );

  const handleDelete = async (id: number) => {
    try {
      await deleteBook(id);
      message.success(t('common.deleteSuccess'));
      fetchBooks();
    } catch (error) {
      message.error(t('common.deleteFailed'));
    }
  };

  const handleSubmit = async () => {
    try {
      setSubmitLoading(true);
      const values = await form.validateFields();
      const { tagIds, ...bookData } = values;

      let bookId: number;
      if (editingBook) {
        await updateBook(editingBook.id, bookData);
        bookId = editingBook.id;
        message.success(t('common.updateSuccess'));
      } else {
        const res: any = await createBook(bookData);
        bookId = res.data.id;
        message.success(t('common.createSuccess'));
      }

      // 更新书籍标签关联
      if (tagIds && tagIds.length > 0) {
        try {
          await updateBookTags(bookId, tagIds);
        } catch (error) {
          console.error('更新标签失败', error);
        }
      } else {
        // 如果没有选择标签，清空该书籍的所有标签
        try {
          await updateBookTags(bookId, []);
        } catch (error) {
          console.error('清空标签失败', error);
        }
      }

      setModalVisible(false);
      fetchBooks();
    } catch (error) {
      if (error instanceof Error && error.message !== 'Validation failed') {
        message.error(t('common.operationFailed'));
      }
    } finally {
      setSubmitLoading(false);
    }
  };

  // 快速修改状态
  const handleStatusChange = async (bookId: number, newStatus: string) => {
    try {
      await updateBook(bookId, { status: newStatus });
      message.success(t('book.statusUpdateSuccess'));
      fetchBooks();
    } catch (error) {
      message.error(t('book.statusUpdateFailed'));
    }
  };

  // Passcode management functions
  const fetchDistributors = async () => {
    try {
      const res: any = await getActiveDistributors();
      // Handle both paginated and non-paginated responses
      const distributorList = res.data?.records || res.data || [];
      setDistributors(distributorList);
    } catch (error) {
      message.error(t('passcode.fetchDistributorsFailed'));
    }
  };

  const fetchPasscodes = async (bookId: number) => {
    setPasscodeLoading(true);
    try {
      const res: any = await getBookPasscodes(bookId);
      setPasscodes(res.data || []);
    } catch (error) {
      message.error(t('passcode.fetchPasscodesFailed'));
    } finally {
      setPasscodeLoading(false);
    }
  };

  const handleManagePasscodes = async (bookId: number) => {
    setCurrentPasscodeBookId(bookId);
    setPasscodes([]); // 清空旧数据
    setPasscodeLoading(true); // 立即显示loading
    setPasscodeModalVisible(true);
    await fetchDistributors();
    await fetchPasscodes(bookId);
  };

  const handleAddPasscode = () => {
    setEditingPasscode(null);
    passcodeForm.resetFields();
    setPasscodeFormVisible(true);
  };

  const handleEditPasscode = (passcode: BookPasscode) => {
    setEditingPasscode(passcode);
    passcodeForm.setFieldsValue({
      distributorId: passcode.distributorId,
      name: passcode.name,
      status: passcode.status,
      validFrom: passcode.validFrom ? passcode.validFrom : undefined,
      validTo: passcode.validTo ? passcode.validTo : undefined,
      passcode: passcode.passcode, // 显示现有口令但不可编辑
    });
    setPasscodeFormVisible(true);
  };

  const handleDeletePasscode = async (passcodeId: number) => {
    if (!currentPasscodeBookId) return;
    try {
      await deletePasscode(passcodeId);
      message.success(t('passcode.deleteSuccess'));
      await fetchPasscodes(currentPasscodeBookId);
    } catch (error) {
      message.error(t('common.deleteFailed'));
    }
  };

  const handlePasscodeSubmit = async () => {
    if (!currentPasscodeBookId) return;
    try {
      setPasscodeSubmitLoading(true);
      const values = await passcodeForm.validateFields();
      if (editingPasscode) {
        await updatePasscode(editingPasscode.id!, values);
        message.success(t('passcode.updateSuccess'));
      } else {
        await createPasscode(currentPasscodeBookId, values);
        message.success(t('passcode.createSuccess'));
      }
      setPasscodeFormVisible(false);
      await fetchPasscodes(currentPasscodeBookId);
    } catch (error) {
      if (error instanceof Error && error.message !== 'Validation failed') {
        message.error(t('passcode.operationFailed'));
      }
    } finally {
      setPasscodeSubmitLoading(false);
    }
  };

  const handleViewStats = async (passcodeId: number) => {
    try {
      const res: any = await getPasscodeStats(passcodeId);
      setCurrentStats(res.data);
      setStatsModalVisible(true);
    } catch (error) {
      message.error(t('passcode.fetchStatsFailed'));
    }
  };

  const handleViewLogs = async (passcodeId: number, page = 1) => {
    try {
      const res: any = await getPasscodeLogs(passcodeId, { page, size: 10 });
      setCurrentLogs(res.data?.records || []);
      setLogsTotal(res.data?.total || 0);
      setLogsPage(page);
      setLogsModalVisible(true);
    } catch (error) {
      message.error(t('passcode.fetchLogsFailed'));
    }
  };

  // 章节管理
  const handleManageChapters = async (bookId: number) => {
    setCurrentBookId(bookId);
    setChapters([]); // 清空旧数据
    setChapterLoading(true); // 立即显示loading
    setChapterModalVisible(true);
    await fetchChapters(bookId);
  };

  const handleAddChapter = () => {
    setEditingChapter(null);
    chapterForm.resetFields();
    setChapterFormVisible(true);
  };

  const handleEditChapter = (chapter: any) => {
    setEditingChapter(chapter);
    chapterForm.setFieldsValue(chapter);
    setChapterFormVisible(true);
  };

  const handleDeleteChapter = async (chapterId: number) => {
    if (!currentBookId) return;
    try {
      await deleteChapter(currentBookId, chapterId);
      message.success(t('common.deleteSuccess'));
      await fetchChapters(currentBookId);
    } catch (error) {
      message.error(t('common.deleteFailed'));
    }
  };

  const handleChapterSubmit = async () => {
    if (!currentBookId) return;
    try {
      const values = await chapterForm.validateFields();
      if (editingChapter) {
        await updateChapter(currentBookId, editingChapter.id, values);
        message.success(t('common.updateSuccess'));
      } else {
        await createChapter(currentBookId, values);
        message.success(t('common.createSuccess'));
      }
      setChapterFormVisible(false);
      await fetchChapters(currentBookId);
    } catch (error) {
      message.error(t('common.operationFailed'));
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: t('book.cover'),
      dataIndex: 'coverUrl',
      key: 'coverUrl',
      width: 80,
      render: (url: string) => url ? <img src={url} alt="cover" style={{ width: 50, height: 70, objectFit: 'cover' }} /> : '-',
    },
    {
      title: t('book.bookTitle'),
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: t('book.author'),
      dataIndex: 'author',
      key: 'author',
    },
    {
      title: t('book.language'),
      dataIndex: 'language',
      key: 'language',
      width: 80,
      render: (lang: string) => lang === 'zh' ? '中文' : 'English',
    },
    {
      title: t('book.category'),
      dataIndex: 'categoryId',
      key: 'categoryId',
      render: (categoryId: number) => {
        const category = categories.find(c => c.id === categoryId);
        return category?.name || '-';
      },
    },
    {
      title: t('book.status'),
      dataIndex: 'status',
      key: 'status',
      width: 120,
      render: (status: string, record: any) => {
        return (
          <Select
            value={status}
            onChange={(value) => handleStatusChange(record.id, value)}
            style={{ width: '100%' }}
            size="small"
          >
            <Select.Option value="draft">
              <span style={{ color: '#999' }}>{t('book.draft')}</span>
            </Select.Option>
            <Select.Option value="published">
              <span style={{ color: '#52c41a' }}>{t('book.published')}</span>
            </Select.Option>
            <Select.Option value="archived">
              <span style={{ color: '#ff4d4f' }}>{t('book.archived')}</span>
            </Select.Option>
          </Select>
        );
      },
    },
    {
      title: t('book.completionStatus'),
      dataIndex: 'completionStatus',
      key: 'completionStatus',
      width: 100,
      render: (completionStatus: string) => {
        const statusMap: Record<string, { text: string; color: string }> = {
          ongoing: { text: t('book.ongoing'), color: '#faad14' },
          completed: { text: t('book.completed'), color: '#722ed1' },
        };
        const config = statusMap[completionStatus] || { text: t('book.ongoing'), color: '#faad14' };
        return <span style={{ color: config.color }}>{config.text}</span>;
      },
    },
    {
      title: t('book.views'),
      dataIndex: 'views',
      key: 'views',
      width: 100,
      render: (views: number) => views || 0,
    },
    {
      title: t('book.likes'),
      dataIndex: 'likes',
      key: 'likes',
      width: 100,
      render: (likes: number) => likes || 0,
    },
    {
      title: t('book.requiresMembership'),
      dataIndex: 'requiresMembership',
      key: 'requiresMembership',
      width: 100,
      render: (val: boolean) => val ? t('common.yes') : t('common.no'),
    },
    {
      title: t('book.recommended'),
      dataIndex: 'isRecommended',
      key: 'isRecommended',
      width: 80,
      render: (val: boolean) => val ? t('common.yes') : t('common.no'),
    },
    {
      title: t('book.hot'),
      dataIndex: 'isHot',
      key: 'isHot',
      width: 80,
      render: (val: boolean) => val ? t('common.yes') : t('common.no'),
    },
    {
      title: t('common.action'),
      key: 'action',
      fixed: 'right' as const,
      width: 320,
      render: (_: any, record: any) => (
        <Space>
          <Button type="link" size="small" onClick={() => handleEdit(record)}>
            {t('common.edit')}
          </Button>
          <Button type="link" size="small" onClick={() => handleManageChapters(record.id)}>
            {t('book.chapterManagement')}
          </Button>
          <Button type="link" size="small" icon={<KeyOutlined />} onClick={() => handleManagePasscodes(record.id)}>
            {t('passcode.title')}
          </Button>
          <Popconfirm
            title={t('common.confirmDelete')}
            onConfirm={() => handleDelete(record.id)}
            okText={t('common.confirm')}
            cancelText={t('common.cancel')}
          >
            <Button type="link" size="small" danger>
              {t('common.delete')}
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const chapterColumns = [
    {
      title: t('chapter.orderNum'),
      dataIndex: 'orderNum',
      key: 'orderNum',
      width: 80,
    },
    {
      title: t('chapter.chapterTitle'),
      dataIndex: 'title',
      key: 'title',
    },
    {
      title: t('chapter.isFree'),
      dataIndex: 'isFree',
      key: 'isFree',
      width: 100,
      render: (val: boolean) => val ? t('common.yes') : t('common.no'),
    },
    {
      title: t('chapter.createdAt'),
      dataIndex: 'createdAt',
      key: 'createdAt',
      width: 180,
    },
    {
      title: t('common.action'),
      key: 'action',
      width: 150,
      render: (_: any, record: any) => (
        <Space>
          <Button type="link" size="small" onClick={() => handleEditChapter(record)}>
            {t('common.edit')}
          </Button>
          <Popconfirm
            title={t('common.confirmDelete')}
            onConfirm={() => handleDeleteChapter(record.id)}
            okText={t('common.confirm')}
            cancelText={t('common.cancel')}
          >
            <Button type="link" size="small" danger>
              {t('common.delete')}
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const passcodeColumns = [
    {
      title: t('passcode.passcode'),
      dataIndex: 'passcode',
      key: 'passcode',
      width: 120,
    },
    {
      title: t('passcode.passcodeName'),
      dataIndex: 'name',
      key: 'name',
      width: 150,
    },
    {
      title: t('passcode.distributor'),
      dataIndex: 'distributorName',
      key: 'distributorName',
      width: 120,
    },
    {
      title: t('passcode.usedCount'),
      dataIndex: 'usedCount',
      key: 'usedCount',
      width: 80,
    },
    {
      title: t('passcode.viewCount'),
      dataIndex: 'viewCount',
      key: 'viewCount',
      width: 100,
    },
    {
      title: t('passcode.status'),
      dataIndex: 'status',
      key: 'status',
      width: 80,
      render: (status: number) => (
        <span style={{ color: status === 1 ? '#52c41a' : '#ff4d4f' }}>
          {status === 1 ? t('passcode.enabled') : t('passcode.disabled')}
        </span>
      ),
    },
    {
      title: t('passcode.validPeriod'),
      key: 'validPeriod',
      width: 200,
      render: (_: any, record: BookPasscode) => {
        if (!record.validFrom && !record.validTo) return t('passcode.permanent');
        return `${record.validFrom || t('passcode.unlimited')} ~ ${record.validTo || t('passcode.unlimited')}`;
      },
    },
    {
      title: t('common.action'),
      key: 'action',
      fixed: 'right' as const,
      width: 250,
      render: (_: any, record: BookPasscode) => (
        <Space>
          <Button type="link" size="small" onClick={() => handleEditPasscode(record)}>
            {t('common.edit')}
          </Button>
          <Button type="link" size="small" onClick={() => handleViewStats(record.id!)}>
            {t('passcode.stats')}
          </Button>
          <Button type="link" size="small" onClick={() => handleViewLogs(record.id!)}>
            {t('passcode.logs')}
          </Button>
          <Popconfirm
            title={t('common.confirmDelete')}
            onConfirm={() => handleDeletePasscode(record.id!)}
            okText={t('common.confirm')}
            cancelText={t('common.cancel')}
          >
            <Button type="link" size="small" danger>
              {t('common.delete')}
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      {/* 搜索表单 */}
      <Card style={{ marginBottom: 16 }}>
        <Form form={searchForm} layout="inline">
          <Row gutter={16} style={{ width: '100%' }}>
            <Col span={6}>
              <Form.Item name="keyword" label={t('book.keyword')}>
                <Input placeholder={t('book.keywordPlaceholder')} />
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="language" label={t('book.language')}>
                <Select placeholder={t('book.selectLanguage')} allowClear>
                  {languages.map(lang => (
                    <Select.Option key={lang.code} value={lang.code}>
                      {lang.name}
                    </Select.Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="categoryId" label={t('book.category')}>
                <Select placeholder={t('book.selectCategory')} allowClear>
                  {categories.map(cat => (
                    <Select.Option key={cat.id} value={cat.id}>
                      {cat.name}
                    </Select.Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="isHot" label={t('book.hot')}>
                <Select placeholder={t('common.all')} allowClear>
                  <Select.Option value={true}>{t('common.yes')}</Select.Option>
                  <Select.Option value={false}>{t('common.no')}</Select.Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Space>
                <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
                  {t('common.search')}
                </Button>
                <Button onClick={handleResetSearch}>
                  {t('common.reset')}
                </Button>
              </Space>
            </Col>
          </Row>
        </Form>
      </Card>

      {/* 操作按钮 */}
      <div style={{ marginBottom: 16 }}>
        <Button type="primary" onClick={handleAdd}>
          {t('book.addBook')}
        </Button>
      </div>

      {/* 书籍列表 */}
      <Table
        loading={loading}
        dataSource={books}
        columns={columns}
        rowKey="id"
        scroll={{ x: 1400 }}
      />

      {/* 书籍信息编辑Modal */}
      <Modal
        title={editingBook ? t('book.editBook') : t('book.addBook')}
        open={modalVisible}
        onOk={handleSubmit}
        onCancel={() => {
          if (!submitLoading) {
            setModalVisible(false);
          }
        }}
        width={900}
        okText={t('common.confirm')}
        cancelText={t('common.cancel')}
        confirmLoading={submitLoading}
        maskClosable={!submitLoading}
        closable={!submitLoading}
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label={<span>{t('book.bookTitle')} <span style={{ color: 'red' }}>*</span></span>}
                name="title"
                rules={[{ required: true, message: t('book.inputTitle') }]}
              >
                <Input placeholder={t('book.inputTitle')} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label={<span>{t('book.author')} <span style={{ color: 'red' }}>*</span></span>}
                name="author"
                rules={[{ required: true, message: t('book.inputAuthor') }]}
              >
                <Input placeholder={t('book.inputAuthor')} />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            label={<span>{t('book.coverImage')} <span style={{ color: 'red' }}>*</span></span>}
            name="coverUrl"
            rules={[{ required: true, message: t('book.uploadCoverRequired') }]}
          >
            <Upload
              name="file"
              listType="picture-card"
              showUploadList={false}
              beforeUpload={handleUpload}
              accept="image/*"
            >
              {imageUrl ? (
                <img src={imageUrl} alt="cover" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              ) : (
                uploadButton
              )}
            </Upload>
            <div style={{ marginTop: 8, color: '#999', fontSize: '12px' }}>
              {t('book.uploadHint')}
            </div>
          </Form.Item>

          <Form.Item label={t('book.description')} name="description">
            <TextArea rows={4} placeholder={t('book.inputDescription')} />
          </Form.Item>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label={<span>{t('book.language')} <span style={{ color: 'red' }}>*</span></span>}
                name="language"
                initialValue={languages[0]?.code || 'zh'}
                rules={[{ required: true, message: t('book.selectLanguage') }]}
              >
                <Select onChange={handleLanguageChange} placeholder={t('book.selectLanguage')}>
                  {languages.map(lang => (
                    <Select.Option key={lang.code} value={lang.code}>
                      {lang.name}
                    </Select.Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item label={t('book.category')} name="categoryId">
                <Select placeholder={t('book.selectCategoryAfterLanguage')}>
                  {categories.map(cat => (
                    <Select.Option key={cat.id} value={cat.id}>
                      {cat.name}
                    </Select.Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item label={t('book.status')} name="status" initialValue="published">
                <Select>
                  <Select.Option value="draft">{t('book.draft')}</Select.Option>
                  <Select.Option value="published">{t('book.published')}</Select.Option>
                  <Select.Option value="archived">{t('book.archived')}</Select.Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item label={t('book.completionStatus')} name="completionStatus" initialValue="ongoing">
                <Select>
                  <Select.Option value="ongoing">{t('book.ongoing')}</Select.Option>
                  <Select.Option value="completed">{t('book.completed')}</Select.Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item label={t('book.likes')} name="likes" initialValue={0}>
                <InputNumber min={0} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item label={t('book.views')} name="views" initialValue={0}>
                <InputNumber min={0} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={8}>
              <Form.Item label={t('book.membersOnly')} name="requiresMembership" valuePropName="checked">
                <Switch />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item label={t('book.recommended')} name="isRecommended" valuePropName="checked">
                <Switch />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item label={t('book.hot')} name="isHot" valuePropName="checked">
                <Switch />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item label={t('book.tags')} name="tagIds">
            <Select
              mode="multiple"
              placeholder={t('book.selectTags')}
              style={{ width: '100%' }}
              allowClear
            >
              {tags.map(tag => (
                <Select.Option key={tag.id} value={tag.id}>
                  <span style={{ color: tag.color || '#1890ff' }}>{tag.name}</span>
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
        </Form>
      </Modal>

      {/* 章节管理Modal */}
      <Modal
        title={t('chapter.title')}
        open={chapterModalVisible}
        onCancel={() => setChapterModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setChapterModalVisible(false)}>
            {t('common.close')}
          </Button>
        ]}
        width={1000}
      >
        <div style={{ marginBottom: 16 }}>
          <Button type="primary" onClick={handleAddChapter}>
            {t('chapter.addChapter')}
          </Button>
        </div>
        <Table
          loading={chapterLoading}
          dataSource={chapters}
          columns={chapterColumns}
          rowKey="id"
          pagination={false}
        />
      </Modal>

      {/* 章节编辑Modal */}
      <Modal
        title={editingChapter ? t('chapter.editChapter') : t('chapter.addChapter')}
        open={chapterFormVisible}
        onOk={handleChapterSubmit}
        onCancel={() => setChapterFormVisible(false)}
        width={1000}
      >
        <Form form={chapterForm} layout="vertical">
          <Form.Item
            label={t('chapter.chapterTitle')}
            name="title"
            rules={[{ required: true, message: t('chapter.inputTitle') }]}
          >
            <Input />
          </Form.Item>
          <Form.Item label={t('chapter.orderNum')} name="orderNum">
            <InputNumber min={1} style={{ width: '100%' }} placeholder={t('chapter.orderNumPlaceholder')} />
          </Form.Item>
          <Form.Item label={t('chapter.isFree')} name="isFree" valuePropName="checked" initialValue={false}>
            <Switch />
          </Form.Item>
          <Form.Item
            label={t('chapter.content')}
            name="content"
            rules={[{ required: true, message: t('chapter.inputContent') }]}
          >
            <RichTextEditor
              value={chapterForm.getFieldValue('content')}
              onChange={(value) => chapterForm.setFieldsValue({ content: value })}
              placeholder={t('chapter.contentPlaceholder')}
            />
          </Form.Item>
        </Form>
      </Modal>

      {/* 口令管理Modal */}
      <Modal
        title={t('passcode.passcodeManagement')}
        open={passcodeModalVisible}
        onCancel={() => setPasscodeModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setPasscodeModalVisible(false)}>
            {t('common.close')}
          </Button>
        ]}
        width={1200}
      >
        <div style={{ marginBottom: 16 }}>
          <Button type="primary" onClick={handleAddPasscode}>
            {t('passcode.addPasscode')}
          </Button>
        </div>
        <Table
          loading={passcodeLoading}
          dataSource={passcodes}
          columns={passcodeColumns}
          rowKey="id"
          pagination={false}
          scroll={{ x: 1000 }}
        />
      </Modal>

      {/* 口令编辑Modal */}
      <Modal
        title={editingPasscode ? t('passcode.editPasscode') : t('passcode.addPasscode')}
        open={passcodeFormVisible}
        onOk={handlePasscodeSubmit}
        onCancel={() => {
          if (!passcodeSubmitLoading) {
            setPasscodeFormVisible(false);
          }
        }}
        confirmLoading={passcodeSubmitLoading}
        maskClosable={!passcodeSubmitLoading}
        closable={!passcodeSubmitLoading}
        width={600}
      >
        <Form form={passcodeForm} layout="vertical">
          <Form.Item
            label={t('passcode.distributor')}
            name="distributorId"
            rules={[{ required: true, message: t('passcode.pleaseSelectDistributor') }]}
          >
            <Select placeholder={t('passcode.selectDistributor')}>
              {distributors.map(dist => (
                <Select.Option key={dist.id} value={dist.id}>
                  {dist.name}
                </Select.Option>
              ))}
            </Select>
          </Form.Item>
          <Form.Item label={t('passcode.passcode')} name="passcode">
            <Input
              placeholder={t('passcode.passcodeAutoGenerate')}
              readOnly
              disabled
              style={{ backgroundColor: '#f5f5f5', cursor: 'not-allowed' }}
            />
          </Form.Item>
          <Form.Item label={t('passcode.passcodeName')} name="name">
            <Input placeholder={t('passcode.inputPasscodeName')} />
          </Form.Item>
          <Form.Item label={t('passcode.status')} name="status" initialValue={1}>
            <Select>
              <Select.Option value={1}>{t('passcode.enabled')}</Select.Option>
              <Select.Option value={0}>{t('passcode.disabled')}</Select.Option>
            </Select>
          </Form.Item>
          <Form.Item label={t('passcode.validFrom')} name="validFrom">
            <Input type="datetime-local" />
          </Form.Item>
          <Form.Item label={t('passcode.validTo')} name="validTo">
            <Input type="datetime-local" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 统计Modal */}
      <Modal
        title={t('passcode.passcodeStats')}
        open={statsModalVisible}
        onCancel={() => setStatsModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setStatsModalVisible(false)}>
            {t('common.close')}
          </Button>
        ]}
        width={600}
      >
        {currentStats && (
          <div style={{ padding: '20px 0' }}>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.passcode')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8 }}>
                      {currentStats.passcode}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.passcodeName')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8 }}>
                      {currentStats.name || '-'}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.usedCount')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8, color: '#1890ff' }}>
                      {currentStats.usedCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.viewCount')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8, color: '#52c41a' }}>
                      {currentStats.viewCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.orderCount')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8, color: '#faad14' }}>
                      {currentStats.orderCount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={12}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.totalAmount')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8, color: '#f5222d' }}>
                      ¥{currentStats.totalAmount}
                    </div>
                  </div>
                </Card>
              </Col>
              <Col span={24}>
                <Card>
                  <div style={{ textAlign: 'center' }}>
                    <div style={{ fontSize: 14, color: '#999' }}>{t('passcode.uniqueUsers')}</div>
                    <div style={{ fontSize: 24, fontWeight: 'bold', marginTop: 8, color: '#722ed1' }}>
                      {currentStats.uniqueUsers}
                    </div>
                  </div>
                </Card>
              </Col>
            </Row>
          </div>
        )}
      </Modal>

      {/* 使用记录Modal */}
      <Modal
        title={t('passcode.usageLogs')}
        open={logsModalVisible}
        onCancel={() => setLogsModalVisible(false)}
        footer={[
          <Button key="close" onClick={() => setLogsModalVisible(false)}>
            {t('common.close')}
          </Button>
        ]}
        width={1000}
      >
        <Table
          dataSource={currentLogs}
          rowKey="id"
          pagination={{
            current: logsPage,
            pageSize: 10,
            total: logsTotal,
            onChange: (page) => {
              const passcodeId = currentLogs[0]?.passcodeId;
              if (passcodeId) {
                handleViewLogs(passcodeId, page);
              }
            }
          }}
          columns={[
            {
              title: 'ID',
              dataIndex: 'id',
              key: 'id',
              width: 80,
            },
            {
              title: t('passcode.userId'),
              dataIndex: 'userId',
              key: 'userId',
              width: 100,
            },
            {
              title: t('passcode.actionType'),
              dataIndex: 'actionType',
              key: 'actionType',
              width: 100,
              render: (type: string) => (
                <span style={{ color: type === 'open' ? '#1890ff' : '#52c41a' }}>
                  {type === 'open' ? t('passcode.actionOpen') : t('passcode.actionView')}
                </span>
              ),
            },
            {
              title: t('passcode.ipAddress'),
              dataIndex: 'ipAddress',
              key: 'ipAddress',
              width: 150,
            },
            {
              title: t('passcode.deviceInfo'),
              dataIndex: 'deviceInfo',
              key: 'deviceInfo',
              ellipsis: true,
            },
            {
              title: t('passcode.time'),
              dataIndex: 'createdAt',
              key: 'createdAt',
              width: 180,
            },
          ]}
        />
      </Modal>
    </div>
  );
};

export default BookManagement;
