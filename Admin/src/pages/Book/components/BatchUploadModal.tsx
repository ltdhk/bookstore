import React, { useState } from 'react';
import { Modal, Upload, Button, Alert, Space, Statistic, Card, message } from 'antd';
import { FileZipOutlined, CheckCircleOutlined, CloseCircleOutlined, UploadOutlined } from '@ant-design/icons';
import { uploadBatchCovers, BatchUploadResult } from '../../../api/coverImage';

interface BatchUploadModalProps {
  visible: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

const BatchUploadModal: React.FC<BatchUploadModalProps> = ({ visible, onClose, onSuccess }) => {
  const [zipFile, setZipFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [result, setResult] = useState<BatchUploadResult | null>(null);

  const handleUpload = async () => {
    if (!zipFile) {
      message.warning('请选择 ZIP 文件');
      return;
    }

    setUploading(true);
    try {
      const res: any = await uploadBatchCovers(zipFile);
      const data = res.data?.data || res.data;
      setResult(data);

      if (data.failureCount === 0) {
        message.success(`成功上传 ${data.successCount} 张封面图片`);
      } else {
        message.warning(`上传完成：成功 ${data.successCount} 张，失败 ${data.failureCount} 张`);
      }

      onSuccess();
    } catch (error: any) {
      message.error(error.response?.data?.message || '批量上传失败');
    } finally {
      setUploading(false);
    }
  };

  const handleClose = () => {
    setZipFile(null);
    setResult(null);
    onClose();
  };

  return (
    <Modal
      title="批量上传封面（ZIP）"
      open={visible}
      onCancel={handleClose}
      footer={null}
      width={800}
    >
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <Alert
          message="上传说明"
          description={
            <ul style={{ marginBottom: 0, paddingLeft: 20 }}>
              <li>准备一个 ZIP 文件，图片需放在 ZIP 文件的根目录（不支持子文件夹）</li>
              <li>每个 ZIP 文件最多包含 100 张图片</li>
              <li>单张图片大小不超过 5MB</li>
              <li>支持的格式：JPG、JPEG、PNG、WebP</li>
              <li>推荐尺寸：600×800 或更高</li>
            </ul>
          }
          type="info"
          showIcon
        />

        <Upload.Dragger
          accept=".zip"
          maxCount={1}
          beforeUpload={(file) => {
            // 检查文件类型
            if (!file.name.endsWith('.zip')) {
              message.error('只支持 .zip 格式的文件');
              return false;
            }

            // 检查文件大小（100MB）
            if (file.size > 100 * 1024 * 1024) {
              message.error('ZIP 文件不能超过 100MB');
              return false;
            }

            setZipFile(file);
            setResult(null); // 清除之前的结果
            return false; // 阻止自动上传
          }}
          onRemove={() => {
            setZipFile(null);
            setResult(null);
          }}
          disabled={uploading}
        >
          <p className="ant-upload-drag-icon">
            <FileZipOutlined style={{ fontSize: 48, color: '#1890ff' }} />
          </p>
          <p className="ant-upload-text">点击或拖拽 ZIP 文件到此处</p>
          <p className="ant-upload-hint">
            支持单次上传一个 ZIP 文件
          </p>
        </Upload.Dragger>

        <Button
          type="primary"
          onClick={handleUpload}
          disabled={!zipFile || uploading}
          loading={uploading}
          block
          icon={<UploadOutlined />}
        >
          {uploading ? '正在上传...' : '开始上传'}
        </Button>

        {result && (
          <Card>
            <Space direction="vertical" size="middle" style={{ width: '100%' }}>
              <div style={{ display: 'flex', gap: 16 }}>
                <Statistic
                  title="总文件数"
                  value={result.totalFiles}
                  suffix="张"
                />
                <Statistic
                  title="成功"
                  value={result.successCount}
                  suffix="张"
                  valueStyle={{ color: '#3f8600' }}
                  prefix={<CheckCircleOutlined />}
                />
                <Statistic
                  title="失败"
                  value={result.failureCount}
                  suffix="张"
                  valueStyle={{ color: result.failureCount > 0 ? '#cf1322' : undefined }}
                  prefix={result.failureCount > 0 ? <CloseCircleOutlined /> : undefined}
                />
              </div>

              {result.errors.length > 0 && (
                <Alert
                  message="错误详情"
                  description={
                    <ul style={{ marginBottom: 0, paddingLeft: 20, maxHeight: 200, overflow: 'auto' }}>
                      {result.errors.map((err, idx) => (
                        <li key={idx}>{err}</li>
                      ))}
                    </ul>
                  }
                  type="error"
                  showIcon
                />
              )}
            </Space>
          </Card>
        )}
      </Space>
    </Modal>
  );
};

export default BatchUploadModal;
