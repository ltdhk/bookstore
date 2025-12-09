package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.entity.BookPasscode;
import com.bookstore.entity.PasscodeUsageLog;
import com.bookstore.repository.BookPasscodeRepository;
import com.bookstore.repository.PasscodeUsageLogRepository;
import com.bookstore.service.BookPasscodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class BookPasscodeServiceImpl extends ServiceImpl<BookPasscodeRepository, BookPasscode> implements BookPasscodeService {

    private final PasscodeUsageLogRepository usageLogRepository;

    @Override
    public String generatePasscode() {
        // Generate a 4-digit passcode first, fallback to 5-digit if all 4-digit codes are used
        String passcode;
        Random random = new Random();

        // First, try to generate a 4-digit passcode (1000-9999)
        int fourDigitAttempts = 0;
        int maxFourDigitAttempts = 9000; // Total 4-digit codes available: 1000-9999

        do {
            int randomNum = 1000 + random.nextInt(9000);
            passcode = String.valueOf(randomNum);
            fourDigitAttempts++;

            if (!passcodeExists(passcode)) {
                return passcode;
            }
        } while (fourDigitAttempts < maxFourDigitAttempts);

        // All 4-digit codes used, generate 5-digit passcode (10000-99999)
        int fiveDigitAttempts = 0;
        int maxFiveDigitAttempts = 90000;

        do {
            int randomNum = 10000 + random.nextInt(90000);
            passcode = String.valueOf(randomNum);
            fiveDigitAttempts++;

            if (!passcodeExists(passcode)) {
                return passcode;
            }
        } while (fiveDigitAttempts < maxFiveDigitAttempts);

        throw new RuntimeException("无法生成唯一的口令，所有可用的口令已被使用");
    }

    private boolean passcodeExists(String passcode) {
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode", passcode);
        return count(queryWrapper) > 0;
    }

    @Override
    public boolean validatePasscode(String passcode, Long bookId) {
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode", passcode);
        queryWrapper.eq("book_id", bookId);
        queryWrapper.eq("status", 1);
        queryWrapper.eq("deleted", 0);

        BookPasscode bookPasscode = getOne(queryWrapper);

        if (bookPasscode == null) {
            return false;
        }

        // Check valid period (compare by date only, ignore time)
        LocalDateTime now = LocalDateTime.now();
        if (bookPasscode.getValidFrom() != null && now.toLocalDate().isBefore(bookPasscode.getValidFrom().toLocalDate())) {
            return false;
        }
        if (bookPasscode.getValidTo() != null && now.toLocalDate().isAfter(bookPasscode.getValidTo().toLocalDate())) {
            return false;
        }

        return true;
    }

    @Override
    @Transactional
    public void recordUsage(Long passcodeId, Long userId, String actionType, String ipAddress, String deviceInfo) {
        BookPasscode passcode = getById(passcodeId);
        if (passcode == null) {
            return;
        }

        // Create usage log
        PasscodeUsageLog log = new PasscodeUsageLog();
        log.setPasscodeId(passcodeId);
        log.setUserId(userId);
        log.setBookId(passcode.getBookId());
        log.setDistributorId(passcode.getDistributorId());
        log.setActionType(actionType);
        log.setIpAddress(ipAddress);
        log.setDeviceInfo(deviceInfo);
        log.setCreatedAt(LocalDateTime.now());

        usageLogRepository.insert(log);
    }

    @Override
    public void incrementViewCount(Long passcodeId) {
        BookPasscode passcode = getById(passcodeId);
        if (passcode != null) {
            passcode.setViewCount(passcode.getViewCount() + 1);
            updateById(passcode);
        }
    }

    @Override
    public void incrementUsedCount(Long passcodeId) {
        BookPasscode passcode = getById(passcodeId);
        if (passcode != null) {
            passcode.setUsedCount(passcode.getUsedCount() + 1);
            updateById(passcode);
        }
    }

    @Override
    public BookPasscode findValidPasscodeByCode(String passcode) {
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode", passcode);
        queryWrapper.eq("status", 1);
        queryWrapper.eq("deleted", 0);

        BookPasscode bookPasscode = getOne(queryWrapper);
        if (bookPasscode == null) {
            return null;
        }

        // Check valid period (compare by date only, ignore time)
        LocalDateTime now = LocalDateTime.now();
        if (bookPasscode.getValidFrom() != null && now.toLocalDate().isBefore(bookPasscode.getValidFrom().toLocalDate())) {
            return null;
        }
        if (bookPasscode.getValidTo() != null && now.toLocalDate().isAfter(bookPasscode.getValidTo().toLocalDate())) {
            return null;
        }

        return bookPasscode;
    }
}
