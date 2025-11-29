package com.bookstore.util;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.read.listener.ReadListener;
import com.bookstore.dto.BookImportDTO;
import com.bookstore.dto.ChapterImportDTO;
import com.bookstore.dto.ImportDataDTO;
import com.bookstore.dto.ValidationError;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
public class ExcelParser {

    public static ImportDataDTO parseExcel(MultipartFile file) throws IOException {
        ImportDataDTO data = new ImportDataDTO();
        List<ValidationError> errors = new ArrayList<>();

        try {
            // Parse Sheet 1: Books
            List<BookImportDTO> books = new ArrayList<>();
            EasyExcel.read(file.getInputStream(), BookImportDTO.class, new ReadListener<BookImportDTO>() {
                @Override
                public void invoke(BookImportDTO bookDTO, AnalysisContext context) {
                    books.add(bookDTO);
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    log.info("Parsed {} books from Excel", books.size());
                }
            }).sheet(0).doRead();
            data.setBooks(books);

            // Parse Sheet 2: Chapters
            List<ChapterImportDTO> chapters = new ArrayList<>();
            EasyExcel.read(file.getInputStream(), ChapterImportDTO.class, new ReadListener<ChapterImportDTO>() {
                @Override
                public void invoke(ChapterImportDTO chapterDTO, AnalysisContext context) {
                    chapters.add(chapterDTO);
                }

                @Override
                public void doAfterAllAnalysed(AnalysisContext context) {
                    log.info("Parsed {} chapters from Excel", chapters.size());
                }
            }).sheet(1).doRead();
            data.setChapters(chapters);

        } catch (Exception e) {
            log.error("Failed to parse Excel file", e);
            throw new IOException("Excel文件解析失败: " + e.getMessage(), e);
        }

        return data;
    }

    public static List<ValidationError> validateFileFormat(MultipartFile file) {
        List<ValidationError> errors = new ArrayList<>();

        if (file == null || file.isEmpty()) {
            errors.add(new ValidationError("file", "文件不能为空"));
            return errors;
        }

        // Validate file extension
        String filename = file.getOriginalFilename();
        if (filename == null || (!filename.endsWith(".xlsx") && !filename.endsWith(".xls"))) {
            errors.add(new ValidationError("file", "文件格式必须为 .xlsx 或 .xls"));
        }

        // Validate file size (100MB)
        if (file.getSize() > 100 * 1024 * 1024) {
            errors.add(new ValidationError("file", "文件大小不能超过 100MB"));
        }

        // Validate MIME type
        String contentType = file.getContentType();
        if (contentType != null &&
                !contentType.equals("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") &&
                !contentType.equals("application/vnd.ms-excel")) {
            errors.add(new ValidationError("file", "文件类型不正确，请上传Excel文件"));
        }

        return errors;
    }
}
