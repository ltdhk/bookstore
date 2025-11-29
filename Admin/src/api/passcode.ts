import request from '../utils/request';

export interface BookPasscode {
  id?: number;
  bookId?: number;
  bookTitle?: string;
  distributorId: number;
  distributorName?: string;
  passcode?: string;
  name?: string;
  maxUsage?: number;
  usedCount?: number;
  viewCount?: number;
  status?: number;
  validFrom?: string;
  validTo?: string;
  createdAt?: string;
  updatedAt?: string;
  orderCount?: number;
  totalAmount?: number;
}

export interface PasscodeStats {
  passcodeId: number;
  passcode: string;
  name?: string;
  usedCount: number;
  viewCount: number;
  orderCount: number;
  totalAmount: number;
  uniqueUsers: number;
}

export interface PasscodeUsageLog {
  id: number;
  passcodeId: number;
  userId?: number;
  bookId: number;
  distributorId: number;
  actionType: string;
  ipAddress?: string;
  deviceInfo?: string;
  createdAt: string;
}

// Get all passcodes with pagination and search
export const getAllPasscodes = (params: {
  page?: number;
  size?: number;
  passcode?: string;
  distributorId?: number;
}) => {
  return request.get('/admin/passcodes', { params });
};

// Get passcodes for a book
export const getBookPasscodes = (bookId: number) => {
  return request.get(`/admin/books/${bookId}/passcodes`);
};

// Create a passcode for a book
export const createPasscode = (bookId: number, data: BookPasscode) => {
  return request.post(`/admin/books/${bookId}/passcodes`, data);
};

// Update a passcode
export const updatePasscode = (id: number, data: Partial<BookPasscode>) => {
  return request.put(`/admin/passcodes/${id}`, data);
};

// Delete a passcode
export const deletePasscode = (id: number) => {
  return request.delete(`/admin/passcodes/${id}`);
};

// Get passcode statistics
export const getPasscodeStats = (id: number) => {
  return request.get(`/admin/passcodes/${id}/stats`);
};

// Get passcode usage logs
export const getPasscodeLogs = (id: number, params?: { page?: number; size?: number }) => {
  return request.get(`/admin/passcodes/${id}/logs`, { params });
};

// Validate passcode (for frontend users)
export const validatePasscode = (passcode: string, bookId: number) => {
  return request.post('/v1/passcodes/validate', { passcode, bookId });
};
