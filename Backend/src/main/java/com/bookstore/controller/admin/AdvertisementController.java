package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Advertisement;
import com.bookstore.repository.AdvertisementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/admin/advertisements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdvertisementController {

    private final AdvertisementRepository advertisementRepository;

    /**
     * Get advertisements list with pagination
     */
    @GetMapping
    public Result<IPage<Advertisement>> getAdvertisements(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) Boolean isActive) {
        try {
            Page<Advertisement> pageParam = new Page<>(page, size);
            QueryWrapper<Advertisement> queryWrapper = new QueryWrapper<>();

            if (position != null && !position.isEmpty()) {
                queryWrapper.eq("position", position);
            }

            if (isActive != null) {
                queryWrapper.eq("is_active", isActive);
            }

            queryWrapper.orderByAsc("sort_order");
            queryWrapper.orderByDesc("created_at");

            IPage<Advertisement> result = advertisementRepository.selectPage(pageParam, queryWrapper);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("Failed to get advertisements: " + e.getMessage());
        }
    }

    /**
     * Get advertisement by ID
     */
    @GetMapping("/{id}")
    public Result<Advertisement> getAdvertisement(@PathVariable Long id) {
        try {
            Advertisement advertisement = advertisementRepository.selectById(id);
            if (advertisement == null) {
                return Result.error("Advertisement not found");
            }
            return Result.success(advertisement);
        } catch (Exception e) {
            return Result.error("Failed to get advertisement: " + e.getMessage());
        }
    }

    /**
     * Create advertisement
     */
    @PostMapping
    public Result<Advertisement> createAdvertisement(@RequestBody Advertisement advertisement) {
        try {
            advertisement.setCreatedAt(LocalDateTime.now());
            advertisement.setUpdatedAt(LocalDateTime.now());

            if (advertisement.getIsActive() == null) {
                advertisement.setIsActive(true);
            }

            if (advertisement.getSortOrder() == null) {
                advertisement.setSortOrder(0);
            }

            if (advertisement.getPosition() == null || advertisement.getPosition().isEmpty()) {
                advertisement.setPosition("home_banner");
            }

            advertisementRepository.insert(advertisement);
            return Result.success(advertisement);
        } catch (Exception e) {
            return Result.error("Failed to create advertisement: " + e.getMessage());
        }
    }

    /**
     * Update advertisement
     */
    @PutMapping("/{id}")
    public Result<Advertisement> updateAdvertisement(
            @PathVariable Long id,
            @RequestBody Advertisement advertisement) {
        try {
            Advertisement existing = advertisementRepository.selectById(id);
            if (existing == null) {
                return Result.error("Advertisement not found");
            }

            advertisement.setId(id);
            advertisement.setUpdatedAt(LocalDateTime.now());
            advertisement.setCreatedAt(existing.getCreatedAt()); // Preserve creation time

            advertisementRepository.updateById(advertisement);
            return Result.success(advertisement);
        } catch (Exception e) {
            return Result.error("Failed to update advertisement: " + e.getMessage());
        }
    }

    /**
     * Delete advertisement
     */
    @DeleteMapping("/{id}")
    public Result<String> deleteAdvertisement(@PathVariable Long id) {
        try {
            Advertisement advertisement = advertisementRepository.selectById(id);
            if (advertisement == null) {
                return Result.error("Advertisement not found");
            }

            advertisementRepository.deleteById(id);
            return Result.success("Advertisement deleted successfully");
        } catch (Exception e) {
            return Result.error("Failed to delete advertisement: " + e.getMessage());
        }
    }

    /**
     * Toggle advertisement active status
     */
    @PutMapping("/{id}/toggle")
    public Result<String> toggleAdvertisementStatus(@PathVariable Long id) {
        try {
            Advertisement advertisement = advertisementRepository.selectById(id);
            if (advertisement == null) {
                return Result.error("Advertisement not found");
            }

            advertisement.setIsActive(!advertisement.getIsActive());
            advertisement.setUpdatedAt(LocalDateTime.now());
            advertisementRepository.updateById(advertisement);

            return Result.success("Advertisement status updated successfully");
        } catch (Exception e) {
            return Result.error("Failed to update advertisement status: " + e.getMessage());
        }
    }

    /**
     * Get active advertisements for client (public API)
     */
    @GetMapping("/active")
    public Result<List<Advertisement>> getActiveAdvertisements(
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
            return Result.error("Failed to get active advertisements: " + e.getMessage());
        }
    }
}
