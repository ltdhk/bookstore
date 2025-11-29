package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.dto.BookPasscodeDTO;
import com.bookstore.dto.PasscodeStatsDTO;
import com.bookstore.entity.*;
import com.bookstore.repository.BookPasscodeRepository;
import com.bookstore.repository.OrderRepository;
import com.bookstore.repository.PasscodeUsageLogRepository;
import com.bookstore.service.BookPasscodeService;
import com.bookstore.service.BookService;
import com.bookstore.service.DistributorService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookPasscodeController {

    private final BookPasscodeService passcodeService;
    private final BookPasscodeRepository passcodeRepository;
    private final BookService bookService;
    private final DistributorService distributorService;
    private final PasscodeUsageLogRepository usageLogRepository;
    private final OrderRepository orderRepository;

    /**
     * Get all passcodes with pagination and search (optimized with JOIN query)
     */
    @GetMapping("/passcodes")
    public Result<IPage<BookPasscodeDTO>> getAllPasscodes(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String passcode,
            @RequestParam(required = false) Long distributorId) {

        // Calculate offset for pagination
        int offset = (page - 1) * size;

        // Use optimized JOIN query - one SQL query instead of N+1
        List<BookPasscodeDTO> dtoList = passcodeRepository.selectPasscodesWithDetails(
                passcode,
                distributorId,
                size,
                offset
        );

        // Get total count
        long total = passcodeRepository.countPasscodes(passcode, distributorId);

        // Create result page
        IPage<BookPasscodeDTO> resultPage = new Page<>(page, size, total);
        resultPage.setRecords(dtoList);

        return Result.success(resultPage);
    }

    /**
     * Get passcodes for a specific book
     */
    @GetMapping("/books/{bookId}/passcodes")
    public Result<List<BookPasscodeDTO>> getBookPasscodes(@PathVariable Long bookId) {
        QueryWrapper<BookPasscode> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("book_id", bookId);
        queryWrapper.eq("deleted", 0);
        queryWrapper.orderByDesc("created_at");

        List<BookPasscode> passcodes = passcodeService.list(queryWrapper);
        List<BookPasscodeDTO> dtoList = convertToDTO(passcodes);

        return Result.success(dtoList);
    }

    /**
     * Create a passcode for a book
     */
    @PostMapping("/books/{bookId}/passcodes")
    public Result<BookPasscodeDTO> createPasscode(@PathVariable Long bookId, @RequestBody BookPasscode passcode) {
        // Validate book exists
        Book book = bookService.getById(bookId);
        if (book == null) {
            return Result.error("Book not found");
        }

        // Validate distributor exists
        Distributor distributor = distributorService.getById(passcode.getDistributorId());
        if (distributor == null) {
            return Result.error("Distributor not found");
        }

        // Set book ID
        passcode.setBookId(bookId);

        // Always generate passcode automatically (ignore user input)
        passcode.setPasscode(passcodeService.generatePasscode());

        // Set default values
        if (passcode.getStatus() == null) {
            passcode.setStatus(1);
        }
        if (passcode.getUsedCount() == null) {
            passcode.setUsedCount(0);
        }
        if (passcode.getViewCount() == null) {
            passcode.setViewCount(0L);
        }
        passcode.setDeleted(false);
        passcode.setCreatedAt(LocalDateTime.now());
        passcode.setUpdatedAt(LocalDateTime.now());

        passcodeService.save(passcode);

        // Convert to DTO
        BookPasscodeDTO dto = new BookPasscodeDTO();
        BeanUtils.copyProperties(passcode, dto);
        dto.setBookTitle(book.getTitle());
        dto.setDistributorName(distributor.getName());

        return Result.success(dto);
    }

    /**
     * Update a passcode
     */
    @PutMapping("/passcodes/{id}")
    public Result<BookPasscodeDTO> updatePasscode(@PathVariable Long id, @RequestBody BookPasscode passcode) {
        BookPasscode existing = passcodeService.getById(id);
        if (existing == null || existing.getDeleted()) {
            return Result.error("Passcode not found");
        }

        // Don't allow changing the passcode itself
        passcode.setPasscode(existing.getPasscode());

        passcode.setId(id);
        passcode.setUpdatedAt(LocalDateTime.now());
        passcodeService.updateById(passcode);

        // Get updated data
        BookPasscode updated = passcodeService.getById(id);
        List<BookPasscodeDTO> dtoList = convertToDTO(List.of(updated));

        return Result.success(dtoList.isEmpty() ? null : dtoList.get(0));
    }

    /**
     * Delete a passcode (soft delete)
     */
    @DeleteMapping("/passcodes/{id}")
    public Result<String> deletePasscode(@PathVariable Long id) {
        BookPasscode passcode = passcodeService.getById(id);
        if (passcode == null || passcode.getDeleted()) {
            return Result.error("Passcode not found");
        }

        passcode.setDeleted(true);
        passcode.setUpdatedAt(LocalDateTime.now());
        passcodeService.updateById(passcode);

        return Result.success("Deleted successfully");
    }

    /**
     * Get passcode statistics
     */
    @GetMapping("/passcodes/{id}/stats")
    public Result<PasscodeStatsDTO> getPasscodeStats(@PathVariable Long id) {
        BookPasscode passcode = passcodeService.getById(id);
        if (passcode == null || passcode.getDeleted()) {
            return Result.error("Passcode not found");
        }

        PasscodeStatsDTO stats = new PasscodeStatsDTO();
        stats.setPasscodeId(id);
        stats.setPasscode(passcode.getPasscode());
        stats.setName(passcode.getName());
        stats.setUsedCount(passcode.getUsedCount());
        stats.setViewCount(passcode.getViewCount());

        // Get order statistics
        QueryWrapper<Order> orderQuery = new QueryWrapper<>();
        orderQuery.eq("source_passcode_id", id);
        orderQuery.eq("status", "Paid");
        List<Order> orders = orderRepository.selectList(orderQuery);

        stats.setOrderCount((long) orders.size());
        BigDecimal totalAmount = orders.stream()
                .map(Order::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        stats.setTotalAmount(totalAmount);

        // Get unique users count
        QueryWrapper<PasscodeUsageLog> logQuery = new QueryWrapper<>();
        logQuery.eq("passcode_id", id);
        logQuery.isNotNull("user_id");
        logQuery.select("DISTINCT user_id");
        stats.setUniqueUsers((long) usageLogRepository.selectList(logQuery).stream()
                .map(PasscodeUsageLog::getUserId)
                .distinct()
                .count());

        return Result.success(stats);
    }

    /**
     * Get passcode usage logs
     */
    @GetMapping("/passcodes/{id}/logs")
    public Result<IPage<PasscodeUsageLog>> getPasscodeLogs(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {

        Page<PasscodeUsageLog> pageParam = new Page<>(page, size);
        QueryWrapper<PasscodeUsageLog> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("passcode_id", id);
        queryWrapper.orderByDesc("created_at");

        IPage<PasscodeUsageLog> result = usageLogRepository.selectPage(pageParam, queryWrapper);
        return Result.success(result);
    }

    /**
     * Convert entity list to DTO list
     */
    private List<BookPasscodeDTO> convertToDTO(List<BookPasscode> passcodes) {
        if (passcodes == null || passcodes.isEmpty()) {
            return new ArrayList<>();
        }

        return passcodes.stream().map(passcode -> {
            BookPasscodeDTO dto = new BookPasscodeDTO();
            BeanUtils.copyProperties(passcode, dto);

            // Get book title
            Book book = bookService.getById(passcode.getBookId());
            if (book != null) {
                dto.setBookTitle(book.getTitle());
            }

            // Get distributor name
            Distributor distributor = distributorService.getById(passcode.getDistributorId());
            if (distributor != null) {
                dto.setDistributorName(distributor.getName());
            }

            return dto;
        }).collect(Collectors.toList());
    }
}
