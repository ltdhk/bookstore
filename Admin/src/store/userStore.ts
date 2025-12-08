import { create } from 'zustand';

export type UserRole = 'admin' | 'distributor' | null;

export interface UserInfo {
  username: string;
  displayName: string;
}

export interface AuthResponse {
  token: string;
  role: UserRole;
  distributorId?: number;
  distributorName?: string;
}

export interface UserInfoResponse {
  role: UserRole;
  username: string;
  displayName: string;
  distributorId?: number;
  permissions: string[];
}

interface UserState {
  token: string | null;
  role: UserRole;
  distributorId: number | null;
  userInfo: UserInfo | null;
  permissions: string[];

  setToken: (token: string) => void;
  setAuth: (data: AuthResponse) => void;
  setUserInfo: (data: UserInfoResponse) => void;
  hasPermission: (permission: string) => boolean;
  logout: () => void;
}

// 从 localStorage 恢复状态
const getInitialState = () => {
  const token = localStorage.getItem('admin_token');
  const role = localStorage.getItem('admin_role') as UserRole;
  const distributorId = localStorage.getItem('admin_distributor_id');
  const userInfoStr = localStorage.getItem('admin_user_info');
  const permissionsStr = localStorage.getItem('admin_permissions');

  return {
    token,
    role: role || null,
    distributorId: distributorId ? parseInt(distributorId, 10) : null,
    userInfo: userInfoStr ? JSON.parse(userInfoStr) : null,
    permissions: permissionsStr ? JSON.parse(permissionsStr) : [],
  };
};

export const useUserStore = create<UserState>((set, get) => ({
  ...getInitialState(),

  setToken: (token: string) => {
    localStorage.setItem('admin_token', token);
    set({ token });
  },

  setAuth: (data: AuthResponse) => {
    localStorage.setItem('admin_token', data.token);
    localStorage.setItem('admin_role', data.role || '');
    if (data.distributorId) {
      localStorage.setItem('admin_distributor_id', String(data.distributorId));
    }
    if (data.distributorName) {
      const userInfo = { username: '', displayName: data.distributorName };
      localStorage.setItem('admin_user_info', JSON.stringify(userInfo));
      set({
        token: data.token,
        role: data.role,
        distributorId: data.distributorId || null,
        userInfo,
      });
    } else {
      set({
        token: data.token,
        role: data.role,
        distributorId: data.distributorId || null,
      });
    }
  },

  setUserInfo: (data: UserInfoResponse) => {
    const userInfo = { username: data.username, displayName: data.displayName };
    localStorage.setItem('admin_user_info', JSON.stringify(userInfo));
    localStorage.setItem('admin_permissions', JSON.stringify(data.permissions));
    localStorage.setItem('admin_role', data.role || '');
    if (data.distributorId) {
      localStorage.setItem('admin_distributor_id', String(data.distributorId));
    }
    set({
      role: data.role,
      distributorId: data.distributorId || null,
      userInfo,
      permissions: data.permissions,
    });
  },

  hasPermission: (permission: string) => {
    const { permissions } = get();
    // 管理员拥有所有权限
    if (permissions.includes('*')) {
      return true;
    }
    return permissions.includes(permission);
  },

  logout: () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_role');
    localStorage.removeItem('admin_distributor_id');
    localStorage.removeItem('admin_user_info');
    localStorage.removeItem('admin_permissions');
    set({
      token: null,
      role: null,
      distributorId: null,
      userInfo: null,
      permissions: [],
    });
  },
}));
