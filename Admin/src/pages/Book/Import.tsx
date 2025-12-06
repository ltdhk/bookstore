import React, { useState } from 'react';
import {
  Steps,
  Upload,
  Button,
  Table,
  Result,
  Alert,
  Card,
  Space,
  Progress,
  Checkbox,
  message,
  Typography,
} from 'antd';
import {
  UploadOutlined,
  DownloadOutlined,
} from '@ant-design/icons';
import type { UploadFile, UploadProps } from 'antd';
import {
  downloadTemplate,
  previewImport,
  executeImport,
  type ImportDataDTO,
  type ImportResultDTO,
} from '../../api/bookImport';

const { Step } = Steps;
const { Title, Text } = Typography;

const BookImport: React.FC = () => {
  const [currentStep, setCurrentStep] = useState(0);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [previewData, setPreviewData] = useState<ImportDataDTO | null>(null);
  const [importResult, setImportResult] = useState<ImportResultDTO | null>(null);
  const [importing, setImporting] = useState(false);
  const [skipDuplicates, setSkipDuplicates] = useState(false);

  // Download Excel template
  const handleDownloadTemplate = async () => {
    try {
      const response: any = await downloadTemplate();
      const blob = new Blob([response], {
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = '书籍导入模板.xlsx';
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
      message.success('模板下载成功');
    } catch (error) {
      message.error('模板下载失败');
    }
  };

  // Upload props
  const uploadProps: UploadProps = {
    accept: '.xlsx,.xls',
    maxCount: 1,
    beforeUpload: () => false, // Prevent auto upload
    onChange: (info) => {
      setFileList(info.fileList);
    },
    fileList,
  };

  // Step 1: Preview import data
  const handlePreview = async () => {
    if (fileList.length === 0) {
      message.error('请先选择文件');
      return;
    }

    setImporting(true);
    try {
      const file = fileList[0].originFileObj as File;
      const response: any = await previewImport(file);

      // Backend returns Result<ImportDataDTO>, so actual data is in response.data.data
      const data = response.data?.data || response.data;

      console.log('Preview response:', response.data);
      console.log('Preview data:', data);

      setPreviewData(data);
      setCurrentStep(1);
      message.success('文件解析成功');
    } catch (error: any) {
      console.error('Preview error:', error);
      message.error(error.response?.data?.message || '文件解析失败');
    } finally {
      setImporting(false);
    }
  };

  // Step 2: Execute import
  const handleExecuteImport = async () => {
    if (fileList.length === 0) {
      message.error('请先选择文件');
      return;
    }

    setImporting(true);
    setCurrentStep(2);

    try {
      const file = fileList[0].originFileObj as File;
      const response: any = await executeImport(file, skipDuplicates);

      // Backend returns Result<ImportResultDTO>, so actual data is in response.data.data
      const result = response.data?.data || response.data;

      console.log('Import response:', response.data);
      console.log('Import result:', result);

      setImportResult(result);
      setCurrentStep(3);

      if (result?.success) {
        message.success('导入成功');
      } else {
        message.error('导入失败，请检查错误信息');
      }
    } catch (error: any) {
      console.error('Import error:', error);
      message.error(error.response?.data?.message || '导入失败');
      setCurrentStep(1); // Go back to preview
    } finally {
      setImporting(false);
    }
  };

  // Reset to initial state
  const handleReset = () => {
    setCurrentStep(0);
    setFileList([]);
    setPreviewData(null);
    setImportResult(null);
    setSkipDuplicates(false);
  };

  // Book columns for preview table
  const bookColumns = [
    { title: '书名', dataIndex: 'title', key: 'title', width: 150 },
    { title: '作者', dataIndex: 'author', key: 'author', width: 100 },
    { title: '语言', dataIndex: 'language', key: 'language', width: 80 },
    { title: '分类ID', dataIndex: 'categoryId', key: 'categoryId', width: 80 },
    { title: '状态', dataIndex: 'status', key: 'status', width: 100 },
    { title: '完结状态', dataIndex: 'completionStatus', key: 'completionStatus', width: 100 },
    { title: '标签ID', dataIndex: 'tagIds', key: 'tagIds', width: 120 },
  ];

  // Chapter columns for preview table
  const chapterColumns = [
    { title: '书名', dataIndex: 'bookTitle', key: 'bookTitle', width: 150 },
    { title: '章节标题', dataIndex: 'chapterTitle', key: 'chapterTitle', width: 200 },
    { title: '是否免费', dataIndex: 'isFree', key: 'isFree', width: 100 },
    { title: '章节序号', dataIndex: 'orderNum', key: 'orderNum', width: 100 },
    {
      title: '内容预览',
      dataIndex: 'content',
      key: 'content',
      width: 200,
      render: (text: string) => (
        <Text ellipsis={{ tooltip: text }}>{text?.substring(0, 50)}...</Text>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Card>
        <Title level={2}>批量导入书籍</Title>

        <Steps current={currentStep} style={{ marginBottom: 24 }}>
          <Step title="上传文件" description="选择Excel文件" />
          <Step title="预览数据" description="验证数据格式" />
          <Step title="执行导入" description="导入到数据库" />
          <Step title="完成" description="查看导入结果" />
        </Steps>

        {/* Step 0: Upload File */}
        {currentStep === 0 && (
          <Space direction="vertical" size="large" style={{ width: '100%' }}>
            <Alert
              message="使用说明"
              description={
                <>
                  <p>1. 点击下载模板按钮，获取Excel导入模板</p>
                  <p>2. 在模板中填写书籍和章节数据</p>
                  <p>3. 封面URL可以留空（使用默认封面）或填写HTTP URL</p>
                  <p>4. 上传填写好的Excel文件</p>
                  <p>5. 单次最多导入50本书，单本最多500章</p>
                </>
              }
              type="info"
              showIcon
            />

            <Button
              type="primary"
              icon={<DownloadOutlined />}
              onClick={handleDownloadTemplate}
            >
              下载Excel模板
            </Button>

            <Upload.Dragger {...uploadProps}>
              <p className="ant-upload-drag-icon">
                <UploadOutlined />
              </p>
              <p className="ant-upload-text">点击或拖拽Excel文件到此区域</p>
              <p className="ant-upload-hint">支持 .xlsx, .xls 格式，文件大小不超过 100MB</p>
            </Upload.Dragger>

            <Button
              type="primary"
              onClick={handlePreview}
              disabled={fileList.length === 0}
              loading={importing}
              block
            >
              下一步：预览数据
            </Button>
          </Space>
        )}

        {/* Step 1: Preview Data */}
        {currentStep === 1 && previewData && (
          <Space direction="vertical" size="large" style={{ width: '100%' }}>
            <Alert
              message={`解析成功：共 ${previewData.books.length} 本书，${previewData.chapters.length} 个章节`}
              type="success"
              showIcon
            />

            <div>
              <Title level={4}>书籍列表 ({previewData.books.length})</Title>
              <Table
                dataSource={previewData.books}
                columns={bookColumns}
                pagination={{ pageSize: 10 }}
                scroll={{ x: 1000 }}
                size="small"
                rowKey={(_record, index) => index?.toString() || '0'}
              />
            </div>

            <div>
              <Title level={4}>章节列表 ({previewData.chapters.length})</Title>
              <Table
                dataSource={previewData.chapters}
                columns={chapterColumns}
                pagination={{ pageSize: 10 }}
                scroll={{ x: 1000 }}
                size="small"
                rowKey={(_record, index) => index?.toString() || '0'}
              />
            </div>

            <Checkbox
              checked={skipDuplicates}
              onChange={(e) => setSkipDuplicates(e.target.checked)}
            >
              跳过重复书名（根据书名判断）
            </Checkbox>

            <Space>
              <Button onClick={() => setCurrentStep(0)}>上一步</Button>
              <Button type="primary" onClick={handleExecuteImport} loading={importing}>
                下一步：执行导入
              </Button>
            </Space>
          </Space>
        )}

        {/* Step 2: Importing */}
        {currentStep === 2 && (
          <Space direction="vertical" size="large" style={{ width: '100%', textAlign: 'center' }}>
            <Title level={4}>正在导入...</Title>
            <Progress type="circle" percent={importing ? undefined : 100} status="active" />
            <Text>请勿关闭页面，正在处理中...</Text>
          </Space>
        )}

        {/* Step 3: Complete */}
        {currentStep === 3 && importResult && (
          <Space direction="vertical" size="large" style={{ width: '100%' }}>
            {importResult.success ? (
              <Result
                status="success"
                title="导入成功！"
                subTitle={`成功导入 ${importResult.importedBooks} 本书，${importResult.importedChapters} 个章节${
                  importResult.skippedBooks > 0
                    ? `，跳过 ${importResult.skippedBooks} 本重复书籍`
                    : ''
                }`}
                extra={[
                  <Button type="primary" onClick={handleReset} key="reset">
                    继续导入
                  </Button>,
                  <Button onClick={() => (window.location.href = '/books')} key="view">
                    查看书籍列表
                  </Button>,
                ]}
              />
            ) : (
              <Result
                status="error"
                title="导入失败"
                subTitle={importResult.message}
                extra={[
                  <Button type="primary" onClick={() => setCurrentStep(0)} key="retry">
                    重新导入
                  </Button>,
                ]}
              >
                {importResult.errors && importResult.errors.length > 0 && (
                  <div style={{ textAlign: 'left' }}>
                    <Title level={5}>错误详情：</Title>
                    <Alert
                      message="验证错误"
                      description={
                        <ul>
                          {importResult.errors.map((error, index) => (
                            <li key={index}>
                              {error.sheetName && `[${error.sheetName}] `}
                              {error.rowNumber && `第${error.rowNumber}行 `}
                              {error.field}: {error.message}
                            </li>
                          ))}
                        </ul>
                      }
                      type="error"
                      showIcon
                    />
                  </div>
                )}
              </Result>
            )}
          </Space>
        )}
      </Card>
    </div>
  );
};

export default BookImport;
