import request from '../utils/request';

export const getBooks = (params: any) => {
  return request({
    url: '/books',
    method: 'get',
    params,
  });
};

export const getBook = (id: number) => {
  return request({
    url: `/books/${id}`,
    method: 'get',
  });
};

export const createBook = (data: any) => {
  return request({
    url: '/books',
    method: 'post',
    data,
  });
};

export const updateBook = (id: number, data: any) => {
  return request({
    url: `/books/${id}`,
    method: 'put',
    data,
  });
};

export const deleteBook = (id: number) => {
  return request({
    url: `/books/${id}`,
    method: 'delete',
  });
};
