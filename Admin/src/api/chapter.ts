import request from '../utils/request';

export const getChapters = (bookId: number) => {
  return request({
    url: `/admin/books/${bookId}/chapters`,
    method: 'get',
  });
};

export const getChapter = (bookId: number, id: number) => {
  return request({
    url: `/admin/books/${bookId}/chapters/${id}`,
    method: 'get',
  });
};

export const createChapter = (bookId: number, data: any) => {
  return request({
    url: `/admin/books/${bookId}/chapters`,
    method: 'post',
    data,
  });
};

export const updateChapter = (bookId: number, id: number, data: any) => {
  return request({
    url: `/admin/books/${bookId}/chapters/${id}`,
    method: 'put',
    data,
  });
};

export const deleteChapter = (bookId: number, id: number) => {
  return request({
    url: `/admin/books/${bookId}/chapters/${id}`,
    method: 'delete',
  });
};
