package com.bookstore.dto;

import com.bookstore.entity.Book;
import lombok.Data;
import java.util.List;

@Data
public class BookWithTagsDTO extends Book {
    private List<Long> tagIds;
}
