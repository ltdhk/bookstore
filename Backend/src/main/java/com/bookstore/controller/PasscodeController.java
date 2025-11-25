package com.bookstore.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.Book;
import com.bookstore.entity.BookPasscode;
import com.bookstore.service.BookPasscodeService;
import com.bookstore.service.BookService;
import com.bookstore.vo.BookVO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/passcodes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PasscodeController {

    private final BookPasscodeService passcodeService;
    private final BookService bookService;

    /**
     * Search book by passcode only (without bookId)
     * Used for passcode search in app search box
     */
    @PostMapping("/search")
    public Result<PasscodeSearchResponse> searchByPasscode(@RequestBody PasscodeSearchRequest request) {
        // Find valid passcode by code only
        BookPasscode passcode = passcodeService.findValidPasscodeByCode(request.getPasscode());

        if (passcode == null) {
            PasscodeSearchResponse response = new PasscodeSearchResponse();
            response.setValid(false);
            response.setMessage("Invalid passcode or passcode has expired");
            return Result.success(response);
        }

        // Get book details
        Book book = bookService.getById(passcode.getBookId());
        if (book == null) {
            PasscodeSearchResponse response = new PasscodeSearchResponse();
            response.setValid(false);
            response.setMessage("Book not found");
            return Result.success(response);
        }

        // Convert to BookVO
        BookVO bookVO = new BookVO();
        BeanUtils.copyProperties(book, bookVO);

        // Build response
        PasscodeSearchResponse response = new PasscodeSearchResponse();
        response.setValid(true);
        response.setPasscodeId(passcode.getId());
        response.setDistributorId(passcode.getDistributorId());
        response.setBookId(passcode.getBookId());
        response.setBook(bookVO);

        return Result.success(response);
    }

    /**
     * Validate passcode
     */
    @PostMapping("/validate")
    public Result<PasscodeValidationResponse> validatePasscode(@RequestBody PasscodeValidateRequest request) {
        boolean isValid = passcodeService.validatePasscode(request.getPasscode(), request.getBookId());

        if (!isValid) {
            return Result.error("Invalid passcode or passcode has expired");
        }

        // Get passcode details
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode", request.getPasscode());
        queryWrapper.eq("book_id", request.getBookId());
        queryWrapper.eq("deleted", 0);
        BookPasscode passcode = passcodeService.getOne(queryWrapper);

        PasscodeValidationResponse response = new PasscodeValidationResponse();
        response.setValid(true);
        response.setPasscodeId(passcode.getId());
        response.setDistributorId(passcode.getDistributorId());
        response.setBookId(passcode.getBookId());

        return Result.success(response);
    }

    /**
     * Track passcode action
     * actionType: use - passcode validated, open - book opened for reading, sub - subscription via passcode
     */
    @PostMapping("/track")
    public Result<String> trackPasscodeAction(@RequestBody PasscodeTrackRequest request, HttpServletRequest httpRequest) {
        // Find passcode by ID
        BookPasscode passcode = passcodeService.getById(request.getPasscodeId());
        if (passcode == null || passcode.getDeleted()) {
            return Result.error("Passcode not found");
        }

        // Validate action type
        String actionType = request.getActionType();
        if (actionType == null || (!actionType.equals("use") && !actionType.equals("open") && !actionType.equals("sub"))) {
            return Result.error("Invalid action type. Must be 'use', 'open', or 'sub'");
        }

        // Record usage log
        String ipAddress = getClientIp(httpRequest);
        String deviceInfo = httpRequest.getHeader("User-Agent");
        passcodeService.recordUsage(passcode.getId(), request.getUserId(), actionType, ipAddress, deviceInfo);

        // Update counters based on action type
        if ("use".equals(actionType)) {
            // Increment used count when passcode is validated/used
            passcodeService.incrementUsedCount(passcode.getId());
        } else if ("open".equals(actionType)) {
            // Increment view count when book is opened for reading
            passcodeService.incrementViewCount(passcode.getId());
        }
        // 'sub' action is recorded in log but doesn't increment counters (order already tracks this)

        return Result.success("Action tracked successfully");
    }

    /**
     * @deprecated Use /track endpoint instead
     * Use passcode to open a book
     */
    @PostMapping("/use")
    public Result<String> usePasscode(@RequestBody PasscodeUseRequest request, HttpServletRequest httpRequest) {
        // Validate passcode
        boolean isValid = passcodeService.validatePasscode(request.getPasscode(), request.getBookId());
        if (!isValid) {
            return Result.error("Invalid passcode or passcode has expired");
        }

        // Get passcode
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode", request.getPasscode());
        queryWrapper.eq("book_id", request.getBookId());
        queryWrapper.eq("deleted", 0);
        BookPasscode passcode = passcodeService.getOne(queryWrapper);

        if (passcode == null) {
            return Result.error("Passcode not found");
        }

        // Record usage
        String ipAddress = getClientIp(httpRequest);
        String deviceInfo = httpRequest.getHeader("User-Agent");
        passcodeService.recordUsage(passcode.getId(), request.getUserId(), "open", ipAddress, deviceInfo);

        // Increment used count
        passcodeService.incrementUsedCount(passcode.getId());

        return Result.success("Passcode used successfully");
    }

    /**
     * @deprecated Use /track endpoint instead
     * Log view action (when user views a chapter via passcode)
     */
    @PostMapping("/log-view")
    public Result<String> logView(@RequestBody PasscodeLogViewRequest request, HttpServletRequest httpRequest) {
        // Get passcode by ID
        BookPasscode passcode = passcodeService.getById(request.getPasscodeId());
        if (passcode == null || passcode.getDeleted()) {
            return Result.error("Passcode not found");
        }

        // Record view
        String ipAddress = getClientIp(httpRequest);
        String deviceInfo = httpRequest.getHeader("User-Agent");
        passcodeService.recordUsage(request.getPasscodeId(), request.getUserId(), "view", ipAddress, deviceInfo);

        // Increment view count
        passcodeService.incrementViewCount(request.getPasscodeId());

        return Result.success("View logged successfully");
    }

    /**
     * Get client IP address
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }

    @Data
    static class PasscodeValidateRequest {
        private String passcode;
        private Long bookId;
    }

    @Data
    static class PasscodeValidationResponse {
        private Boolean valid;
        private Long passcodeId;
        private Long distributorId;
        private Long bookId;
    }

    @Data
    static class PasscodeUseRequest {
        private String passcode;
        private Long bookId;
        private Long userId;
    }

    @Data
    static class PasscodeLogViewRequest {
        private Long passcodeId;
        private Long userId;
    }

    @Data
    static class PasscodeSearchRequest {
        private String passcode;
    }

    @Data
    static class PasscodeSearchResponse {
        private Boolean valid;
        private Long passcodeId;
        private Long distributorId;
        private Long bookId;
        private BookVO book;
        private String message;
    }

    @Data
    static class PasscodeTrackRequest {
        private Long passcodeId;
        private Long userId;
        private String actionType; // use, open, sub
    }
}
