package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Chapter;
import com.bookstore.repository.ChapterMapper;
import com.bookstore.service.ChapterService;
import com.bookstore.vo.ChapterVO;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChapterServiceImpl extends ServiceImpl<ChapterMapper, Chapter> implements ChapterService {

    @Override
    public List<ChapterVO> getChaptersByBookId(Long bookId) {
        List<Chapter> chapters = list(new LambdaQueryWrapper<Chapter>()
                .eq(Chapter::getBookId, bookId)
                .orderByAsc(Chapter::getOrderNum));
        return chapters.stream().map(this::convertToVO).collect(Collectors.toList());
    }

    @Override
    public ChapterVO getChapterDetails(Long id) {
        Chapter chapter = getById(id);
        if (chapter == null) {
            throw new RuntimeException("Chapter not found");
        }
        return convertToVO(chapter);
    }

    private ChapterVO convertToVO(Chapter chapter) {
        ChapterVO vo = new ChapterVO();
        BeanUtils.copyProperties(chapter, vo);
        return vo;
    }
}
