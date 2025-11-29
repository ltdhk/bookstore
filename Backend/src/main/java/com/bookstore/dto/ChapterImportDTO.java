package com.bookstore.dto;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

@Data
public class ChapterImportDTO {
    @ExcelProperty("书名")
    private String bookTitle;

    @ExcelProperty("章节标题")
    private String chapterTitle;

    @ExcelProperty("章节内容")
    private String content;

    @ExcelProperty("是否免费")
    private String isFree;

    @ExcelProperty("章节序号")
    private Integer orderNum;
}
