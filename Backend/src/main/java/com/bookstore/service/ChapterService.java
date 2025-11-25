package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.entity.Chapter;
import com.bookstore.vo.ChapterVO;

import java.util.List;

public interface ChapterService extends IService<Chapter> {
    List<ChapterVO> getChaptersByBookId(Long bookId);
    List<ChapterVO> getChaptersByBookId(Long bookId, Boolean includeFirstChapter);
    List<ChapterVO> getChaptersByBookId(Long bookId, Boolean includeFirstChapter, Long userId);
    ChapterVO getChapterDetails(Long id);
    ChapterVO getChapterDetails(Long id, Long userId);
}
