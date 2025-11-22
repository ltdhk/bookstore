package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.entity.Chapter;
import com.bookstore.vo.ChapterVO;

import java.util.List;

public interface ChapterService extends IService<Chapter> {
    List<ChapterVO> getChaptersByBookId(Long bookId);
    ChapterVO getChapterDetails(Long id);
}
