import request from '../utils/request';

export interface BookImportDTO {
  title: string;
  author?: string;
  coverUrl?: string;
  description?: string;
  categoryId?: number;
  language: string;
  status?: string;
  completionStatus?: string;
  requiresMembership?: string;
  isRecommended?: string;
  isHot?: string;
  tagIds?: string;
}

export interface ChapterImportDTO {
  bookTitle: string;
  chapterTitle: string;
  content: string;
  isFree?: string;
  orderNum?: number;
}

export interface ImportDataDTO {
  books: BookImportDTO[];
  chapters: ChapterImportDTO[];
}

export interface ValidationError {
  field: string;
  message: string;
  rowNumber?: number;
  sheetName?: string;
}

export interface ImportResultDTO {
  success: boolean;
  message: string;
  importedBooks: number;
  importedChapters: number;
  skippedBooks: number;
  errors: ValidationError[];
  warnings: ValidationError[];
}

// Download Excel template
export const downloadTemplate = () => {
  return request.get('/admin/books/import/template', {
    responseType: 'blob',
  });
};

// Preview import data (validation only, no save)
export const previewImport = (file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<ImportDataDTO>('/admin/books/import/preview', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 60000, // 60 seconds for preview
  });
};

// Execute import (save to database)
export const executeImport = (file: File, skipDuplicates: boolean = false) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('skipDuplicates', String(skipDuplicates));
  return request.post<ImportResultDTO>('/admin/books/import/execute', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
    timeout: 180000, // 3 minutes for execution
  });
};
