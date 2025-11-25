import request from '../utils/request';

/**
 * 上传文件到S3
 * @param file 文件对象
 * @param folder 文件夹名称（可选，默认为covers）
 * @returns 文件的公开访问URL
 */
export const uploadFile = (file: File, folder: string = 'covers') => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('folder', folder);

  return request({
    url: '/admin/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

/**
 * 删除S3上的文件
 * @param fileUrl 文件URL
 * @returns 删除结果
 */
export const deleteFile = (fileUrl: string) => {
  return request({
    url: '/admin/upload',
    method: 'delete',
    params: { fileUrl },
  });
};
