package com.bookstore.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.entity.BookPasscode;

public interface BookPasscodeService extends IService<BookPasscode> {

    /**
     * Generate a random passcode
     */
    String generatePasscode();

    /**
     * Validate passcode availability
     */
    boolean validatePasscode(String passcode, Long bookId);

    /**
     * Record passcode usage
     */
    void recordUsage(Long passcodeId, Long userId, String actionType, String ipAddress, String deviceInfo);

    /**
     * Increment view count
     */
    void incrementViewCount(Long passcodeId);

    /**
     * Increment used count
     */
    void incrementUsedCount(Long passcodeId);

    /**
     * Find valid passcode by code only (without bookId)
     * Used for passcode search in app
     */
    BookPasscode findValidPasscodeByCode(String passcode);
}
