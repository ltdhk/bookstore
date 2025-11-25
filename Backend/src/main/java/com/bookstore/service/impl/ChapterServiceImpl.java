package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.Chapter;
import com.bookstore.repository.ChapterMapper;
import com.bookstore.service.ChapterService;
import com.bookstore.service.SubscriptionService;
import com.bookstore.vo.ChapterVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChapterServiceImpl extends ServiceImpl<ChapterMapper, Chapter> implements ChapterService {

    @Autowired
    private SubscriptionService subscriptionService;

    @Override
    public List<ChapterVO> getChaptersByBookId(Long bookId) {
        return getChaptersByBookId(bookId, false, null);
    }

    @Override
    public List<ChapterVO> getChaptersByBookId(Long bookId, Boolean includeFirstChapter) {
        return getChaptersByBookId(bookId, includeFirstChapter, null);
    }

    @Override
    public List<ChapterVO> getChaptersByBookId(Long bookId, Boolean includeFirstChapter, Long userId) {
        List<Chapter> chapters = list(new LambdaQueryWrapper<Chapter>()
                .eq(Chapter::getBookId, bookId)
                .orderByAsc(Chapter::getOrderNum));

        // Check if user has valid subscription
        boolean hasValidSubscription = userId != null && subscriptionService.isSubscriptionValid(userId);

        if (includeFirstChapter != null && includeFirstChapter && !chapters.isEmpty()) {
            // Convert chapters to VOs and include content for the first chapter
            List<ChapterVO> chapterVOs = chapters.stream()
                    .map(chapter -> {
                        ChapterVO vo = convertToVO(chapter);
                        // Set canAccess based on isFree or subscription status
                        vo.setCanAccess(Boolean.TRUE.equals(chapter.getIsFree()) || hasValidSubscription);
                        // Only include content for the first chapter
                        if (chapter.getOrderNum() == 1 || (chapters.get(0).getId().equals(chapter.getId()))) {
                            // Content is already included in convertToVO
                            return vo;
                        } else {
                            // Remove content for other chapters
                            vo.setContent(null);
                            return vo;
                        }
                    })
                    .collect(Collectors.toList());
            return chapterVOs;
        } else {
            // No content for any chapter (old behavior)
            return chapters.stream()
                    .map(chapter -> {
                        ChapterVO vo = convertToVO(chapter);
                        vo.setContent(null);
                        // Set canAccess based on isFree or subscription status
                        vo.setCanAccess(Boolean.TRUE.equals(chapter.getIsFree()) || hasValidSubscription);
                        return vo;
                    })
                    .collect(Collectors.toList());
        }
    }

    @Override
    public ChapterVO getChapterDetails(Long id) {
        return getChapterDetails(id, null);
    }

    @Override
    public ChapterVO getChapterDetails(Long id, Long userId) {
        Chapter chapter = getById(id);
        if (chapter == null) {
            throw new RuntimeException("Chapter not found");
        }

        // Check if user can access this chapter
        boolean isFree = Boolean.TRUE.equals(chapter.getIsFree());
        boolean hasValidSubscription = userId != null && subscriptionService.isSubscriptionValid(userId);

        if (!isFree && !hasValidSubscription) {
            // Non-SVIP user trying to access paid chapter
            throw new RuntimeException("SUBSCRIPTION_REQUIRED");
        }

        ChapterVO vo = convertToVO(chapter);
        vo.setCanAccess(true);
        return vo;
    }

    private ChapterVO convertToVO(Chapter chapter) {
        ChapterVO vo = new ChapterVO();
        BeanUtils.copyProperties(chapter, vo);
        return vo;
    }
}
