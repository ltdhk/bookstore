import request from '../utils/request';

export interface Category {
  id?: number;
  name: string;
  language?: string;
  sortOrder?: number;
  createdAt?: string;
}

export const getCategories = (language?: string) => {
  return request.get('/admin/categories', {
    params: language ? { language } : undefined
  });
};

export const createCategory = (data: Category) => {
  return request.post('/admin/categories', data);
};

export const updateCategory = (id: number, data: Category) => {
  return request.put(`/admin/categories/${id}`, data);
};

export const deleteCategory = (id: number) => {
  return request.delete(`/admin/categories/${id}`);
};
