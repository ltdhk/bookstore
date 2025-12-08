package com.bookstore.dto;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StatusReferenceDTO {
    @ExcelProperty("状态值")
    private String value;

    @ExcelProperty("说明")
    private String description;
}
