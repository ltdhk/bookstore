import request from '../utils/request';

export interface Tag {
  id?: number;
  name: string;
  language: string;
  color?: string;
  sortOrder?: number;
  isActive?: boolean;
  createdAt?: string;
  updatedAt?: string;
}

// 获取所有标签
export const getAllTags = (language?: string) => {
  return request.get('/admin/tags', { params: { language } });
};

// 获取激活的标签
export const getActiveTags = (language?: string) => {
  return request.get('/admin/tags/active', { params: { language } });
};

// 创建标签
export const createTag = (data: Tag) => {
  return request.post('/admin/tags', data);
};

// 更新标签
export const updateTag = (id: number, data: Tag) => {
  return request.put(`/admin/tags/${id}`, data);
};

// 删除标签
export const deleteTag = (id: number) => {
  return request.delete(`/admin/tags/${id}`);
};

// 获取书籍的标签
export const getBookTags = (bookId: number) => {
  return request.get(`/admin/books/${bookId}/tags`);
};

// 更新书籍的标签
export const updateBookTags = (bookId: number, tagIds: number[]) => {
  return request.post(`/admin/books/${bookId}/tags`, tagIds);
};
