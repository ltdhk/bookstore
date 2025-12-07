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
        // Generate a passcode starting with "KL" followed by 4 random digits (0000-9999)
        String passcode;
        Random random = new Random();
        int maxAttempts = 10000; // Prevent infinite loop
        int attempts = 0;

        do {
            // Generate 4-digit number with leading zeros (0000-9999)
            int randomNum = random.nextInt(10000);
            String randomPart = String.format("%04d", randomNum);
            passcode = "KL" + randomPart;
            attempts++;

            if (attempts >= maxAttempts) {
                throw new RuntimeException("无法生成唯一的口令，所有可用的口令已被使用");
            }
        } while (passcodeExists(passcode));

        return passcode;
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

        // Check valid period
        LocalDateTime now = LocalDateTime.now();
        if (bookPasscode.getValidFrom() != null && now.isBefore(bookPasscode.getValidFrom())) {
            return false;
        }
        if (bookPasscode.getValidTo() != null && now.isAfter(bookPasscode.getValidTo())) {
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

        // Check valid period
        LocalDateTime now = LocalDateTime.now();
        if (bookPasscode.getValidFrom() != null && now.isBefore(bookPasscode.getValidFrom())) {
            return null;
        }
        if (bookPasscode.getValidTo() != null && now.isAfter(bookPasscode.getValidTo())) {
            return null;
        }

        return bookPasscode;
    }
}
