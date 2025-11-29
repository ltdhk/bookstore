package com.bookstore.service;

import com.bookstore.dto.ImportDataDTO;
import com.bookstore.dto.ImportResultDTO;
import org.springframework.web.multipart.MultipartFile;

public interface BookImportService {
    /**
     * Preview import data without saving
     * @param file Excel file
     * @return Import preview with validation results
     */
    ImportDataDTO previewImport(MultipartFile file) throws Exception;

    /**
     * Execute import and save to database
     * @param file Excel file
     * @param skipDuplicates Whether to skip duplicate books
     * @return Import result with statistics
     */
    ImportResultDTO executeImport(MultipartFile file, Boolean skipDuplicates) throws Exception;
}
