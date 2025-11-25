package com.bookstore.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.bookstore.common.Result;
import com.bookstore.entity.Advertisement;
import com.bookstore.repository.AdvertisementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Client-facing Advertisement Controller
 * For mobile app to fetch active advertisements
 */
@RestController
@RequestMapping("/api/advertisements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ClientAdvertisementController {

    private final AdvertisementRepository advertisementRepository;

    /**
     * Get active advertisements for client
     * @param position Optional position filter (e.g., "home_banner")
     * @return List of active advertisements
     */
    @GetMapping
    public Result<List<Advertisement>> getAdvertisements(
            @RequestParam(required = false) String position) {
        try {
            QueryWrapper<Advertisement> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("is_active", true);

            if (position != null && !position.isEmpty()) {
                queryWrapper.eq("position", position);
            }

            queryWrapper.orderByAsc("sort_order");
            queryWrapper.orderByDesc("created_at");

            List<Advertisement> advertisements = advertisementRepository.selectList(queryWrapper);
            return Result.success(advertisements);
        } catch (Exception e) {
            return Result.error("Failed to get advertisements: " + e.getMessage());
        }
    }
}
