import request from '../utils/request';

/**
 * 封面图片接口
 */
export interface CoverImage {
  id: number;
  fileName: string;
  fileUrl: string;
  fileSize: number;
  width?: number;
  height?: number;
  uploadSource: 'single' | 'batch';
  batchId?: string;
  isUsed: boolean;
  createdAt: string;
}

/**
 * 封面查询参数
 */
export interface CoverImageQuery {
  page?: number;
  size?: number;
  isUsed?: boolean;
  uploadSource?: string;
  keyword?: string;
}

/**
 * 批量上传结果
 */
export interface BatchUploadResult {
  batchId: string;
  totalFiles: number;
  successCount: number;
  failureCount: number;
  uploadedImages: CoverImage[];
  errors: string[];
}

/**
 * 获取封面列表（分页）
 */
export const getCoverImages = (params: CoverImageQuery) => {
  return request({
    url: '/admin/covers',
    method: 'get',
    params,
  });
};

/**
 * 获取单个封面详情
 */
export const getCoverImage = (id: number) => {
  return request({
    url: `/admin/covers/${id}`,
    method: 'get',
  });
};

/**
 * 上传单个封面
 */
export const uploadSingleCover = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/admin/covers/upload/single',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

/**
 * ZIP 批量上传
 */
export const uploadBatchCovers = (zipFile: File) => {
  const formData = new FormData();
  formData.append('file', zipFile);
  return request({
    url: '/admin/covers/upload/batch',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 300000, // 5 分钟超时
  });
};

/**
 * 替换封面
 */
export const replaceCover = (id: number, newFile: File) => {
  const formData = new FormData();
  formData.append('file', newFile);
  return request({
    url: `/admin/covers/${id}/replace`,
    method: 'put',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

/**
 * 删除封面
 */
export const deleteCover = (id: number) => {
  return request({
    url: `/admin/covers/${id}`,
    method: 'delete',
  });
};

/**
 * 标记使用状态
 */
export const markCoverAsUsed = (id: number, used: boolean) => {
  return request({
    url: `/admin/covers/${id}/mark-used`,
    method: 'put',
    params: { used },
  });
};

/**
 * 获取未使用的封面
 */
export const getUnusedCover = () => {
  return request({
    url: '/admin/covers/unused/random',
    method: 'get',
  });
};
