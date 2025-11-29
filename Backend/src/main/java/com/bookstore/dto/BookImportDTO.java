package com.bookstore.dto;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

@Data
public class BookImportDTO {
    @ExcelProperty("书名")
    private String title;

    @ExcelProperty("作者")
    private String author;

    @ExcelProperty("封面URL")
    private String coverUrl;

    @ExcelProperty("简介")
    private String description;

    @ExcelProperty("分类ID")
    private Long categoryId;

    @ExcelProperty("语言")
    private String language;

    @ExcelProperty("状态")
    private String status;

    @ExcelProperty("完结状态")
    private String completionStatus;

    @ExcelProperty("需要会员")
    private String requiresMembership;

    @ExcelProperty("推荐")
    private String isRecommended;

    @ExcelProperty("热门")
    private String isHot;

    @ExcelProperty("标签ID")
    private String tagIds;
}
