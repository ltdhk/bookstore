package com.bookstore.dto;

import com.bookstore.vo.BookVO;
import com.bookstore.vo.ChapterVO;
import lombok.Data;

import java.util.List;

/**
 * Combined DTO for reader page - reduces multiple API calls to one
 */
@Data
public class ReaderDataDTO {
    private BookVO book;
    private List<ChapterVO> chapters;
    private Boolean hasValidSubscription;
}
