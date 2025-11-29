package com.bookstore.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ValidationError {
    private String field;
    private String message;
    private Integer rowNumber;
    private String sheetName;

    public ValidationError(String field, String message) {
        this.field = field;
        this.message = message;
    }

    public ValidationError(String field, String message, Integer rowNumber) {
        this.field = field;
        this.message = message;
        this.rowNumber = rowNumber;
    }
}
