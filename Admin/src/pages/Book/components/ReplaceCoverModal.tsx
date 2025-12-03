import React, { useState } from 'react';
import { Modal, Upload, Button, Space, message, Image } from 'antd';
import { UploadOutlined } from '@ant-design/icons';
import { replaceCover } from '../../../api/coverImage';
import type { CoverImage } from '../../../api/coverImage';

interface ReplaceCoverModalProps {
  visible: boolean;
  cover: CoverImage | null;
  onClose: () => void;
  onSuccess: () => void;
}

const ReplaceCoverModal: React.FC<ReplaceCoverModalProps> = ({ visible, cover, onClose, onSuccess }) => {
  const [newFile, setNewFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);

  const handleUpload = async () => {
    if (!newFile || !cover) {
      message.warning('请选择新的图片文件');
      return;
    }

    setUploading(true);
    try {
      await replaceCover(cover.id, newFile);
      message.success('封面替换成功');
      handleClose();
      onSuccess();
    } catch (error: any) {
      message.error(error.response?.data?.message || '替换失败');
    } finally {
      setUploading(false);
    }
  };

  const handleClose = () => {
    setNewFile(null);
    setPreviewUrl(null);
    onClose();
  };

  const handleFileChange = (file: File) => {
    setNewFile(file);

    // 生成预览 URL
    const reader = new FileReader();
    reader.onload = (e) => {
      setPreviewUrl(e.target?.result as string);
    };
    reader.readAsDataURL(file);
  };

  return (
    <Modal
      title="替换封面"
      open={visible}
      onCancel={handleClose}
      footer={[
        <Button key="cancel" onClick={handleClose} disabled={uploading}>
          取消
        </Button>,
        <Button
          key="submit"
          type="primary"
          onClick={handleUpload}
          disabled={!newFile || uploading}
          loading={uploading}
        >
          确定替换
        </Button>,
      ]}
      width={700}
    >
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <div style={{ display: 'flex', gap: 24, alignItems: 'flex-start' }}>
          {/* 旧图预览 */}
          <div style={{ flex: 1, textAlign: 'center' }}>
            <div style={{ marginBottom: 8, fontWeight: 'bold' }}>当前封面</div>
            {cover && (
              <>
                <Image
                  src={cover.fileUrl}
                  alt={cover.fileName}
                  style={{
                    maxWidth: '100%',
                    maxHeight: 300,
                    objectFit: 'contain',
                    border: '1px solid #d9d9d9',
                    borderRadius: 4,
                  }}
                />
                <div style={{ marginTop: 8, fontSize: 12, color: '#666' }}>
                  {cover.fileName}
                </div>
                {cover.width && cover.height && (
                  <div style={{ fontSize: 12, color: '#999' }}>
                    {cover.width} × {cover.height}
                  </div>
                )}
              </>
            )}
          </div>

          {/* 新图预览 */}
          <div style={{ flex: 1, textAlign: 'center' }}>
            <div style={{ marginBottom: 8, fontWeight: 'bold' }}>新封面</div>
            {previewUrl ? (
              <>
                <Image
                  src={previewUrl}
                  alt="新封面预览"
                  style={{
                    maxWidth: '100%',
                    maxHeight: 300,
                    objectFit: 'contain',
                    border: '1px solid #d9d9d9',
                    borderRadius: 4,
                  }}
                />
                <div style={{ marginTop: 8, fontSize: 12, color: '#666' }}>
                  {newFile?.name}
                </div>
              </>
            ) : (
              <div style={{
                height: 300,
                border: '1px dashed #d9d9d9',
                borderRadius: 4,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#999',
              }}>
                尚未选择新图片
              </div>
            )}
          </div>
        </div>

        <Upload
          accept="image/*"
          maxCount={1}
          showUploadList={false}
          beforeUpload={(file) => {
            // 检查文件类型
            if (!file.type.startsWith('image/')) {
              message.error('只支持图片文件');
              return false;
            }

            // 检查文件大小（5MB）
            if (file.size > 5 * 1024 * 1024) {
              message.error('图片大小不能超过 5MB');
              return false;
            }

            handleFileChange(file);
            return false;
          }}
          disabled={uploading}
        >
          <Button icon={<UploadOutlined />} block disabled={uploading}>
            选择新图片
          </Button>
        </Upload>
      </Space>
    </Modal>
  );
};

export default ReplaceCoverModal;
