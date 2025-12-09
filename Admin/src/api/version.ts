import request from '../utils/request';

export type AppVersion = {
  id?: number;
  versionCode: number;
  versionName: string;
  platform: 'ios' | 'android';
  forceUpdate: boolean;
  minSupportedVersion: number;
  updateUrl: string;
  releaseNotes: string;
  createdAt?: string;
  updatedAt?: string;
};

export type VersionListParams = {
  page?: number;
  size?: number;
  platform?: string;
};

// Get version list
export const getVersions = (params: VersionListParams) => {
  return request({
    url: '/admin/versions',
    method: 'get',
    params,
  });
};

// Get single version
export const getVersion = (id: number) => {
  return request({
    url: `/admin/versions/${id}`,
    method: 'get',
  });
};

// Create version
export const createVersion = (data: AppVersion) => {
  return request({
    url: '/admin/versions',
    method: 'post',
    data,
  });
};

// Update version
export const updateVersion = (id: number, data: AppVersion) => {
  return request({
    url: `/admin/versions/${id}`,
    method: 'put',
    data,
  });
};

// Delete version
export const deleteVersion = (id: number) => {
  return request({
    url: `/admin/versions/${id}`,
    method: 'delete',
  });
};
