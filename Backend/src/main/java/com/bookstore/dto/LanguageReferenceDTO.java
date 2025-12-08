package com.bookstore.dto;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LanguageReferenceDTO {
    @ExcelProperty("语言代码")
    private String code;

    @ExcelProperty("语言名称")
    private String name;
}
