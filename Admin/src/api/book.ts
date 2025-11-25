import request from '../utils/request';

export const getBooks = (params: any) => {
  return request({
    url: '/admin/books',
    method: 'get',
    params,
  });
};

export const getBook = (id: number) => {
  return request({
    url: `/admin/books/${id}`,
    method: 'get',
  });
};

export const createBook = (data: any) => {
  return request({
    url: '/admin/books',
    method: 'post',
    data,
  });
};

export const updateBook = (id: number, data: any) => {
  return request({
    url: `/admin/books/${id}`,
    method: 'put',
    data,
  });
};

export const deleteBook = (id: number) => {
  return request({
    url: `/admin/books/${id}`,
    method: 'delete',
  });
};

// Book Content APIs
export const getBookContents = (bookId: number) => {
  return request({
    url: `/admin/books/${bookId}/contents`,
    method: 'get',
  });
};

export const saveBookContent = (bookId: number, data: any) => {
  return request({
    url: `/admin/books/${bookId}/contents`,
    method: 'post',
    data,
  });
};
