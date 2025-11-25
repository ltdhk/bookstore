import request from '../utils/request';

export interface Language {
  id?: number;
  code: string;
  name: string;
  isActive?: boolean;
  sortOrder?: number;
  createdAt?: string;
}

export const getLanguages = () => {
  return request.get('/admin/languages');
};

export const getActiveLanguages = () => {
  return request.get('/admin/languages/active');
};

export const createLanguage = (data: Language) => {
  return request.post('/admin/languages', data);
};

export const updateLanguage = (id: number, data: Language) => {
  return request.put(`/admin/languages/${id}`, data);
};

export const deleteLanguage = (id: number) => {
  return request.delete(`/admin/languages/${id}`);
};
