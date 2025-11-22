import { create } from 'zustand';

interface UserState {
  token: string | null;
  setToken: (token: string) => void;
  logout: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  token: localStorage.getItem('admin_token'),
  setToken: (token: string) => {
    localStorage.setItem('admin_token', token);
    set({ token });
  },
  logout: () => {
    localStorage.removeItem('admin_token');
    set({ token: null });
  },
}));
