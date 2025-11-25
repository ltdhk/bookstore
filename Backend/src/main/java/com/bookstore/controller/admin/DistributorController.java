package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.Distributor;
import com.bookstore.service.DistributorService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/distributors")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DistributorController {

    private final DistributorService distributorService;

    @GetMapping
    public Result<IPage<Distributor>> getDistributors(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String name) {
        Page<Distributor> pageParam = new Page<>(page, size);
        QueryWrapper<Distributor> queryWrapper = new QueryWrapper<>();
        if (StringUtils.hasText(name)) {
            queryWrapper.like("name", name);
        }
        IPage<Distributor> result = distributorService.page(pageParam, queryWrapper);
        return Result.success(result);
    }

    @PostMapping
    public Result<Distributor> createDistributor(@RequestBody Distributor distributor) {
        // Check if username already exists
        QueryWrapper<Distributor> usernameQuery = new QueryWrapper<>();
        usernameQuery.eq("username", distributor.getUsername());
        long usernameCount = distributorService.count(usernameQuery);
        if (usernameCount > 0) {
            return Result.error("Username already exists");
        }

        // Check if code already exists
        QueryWrapper<Distributor> codeQuery = new QueryWrapper<>();
        codeQuery.eq("code", distributor.getCode());
        long codeCount = distributorService.count(codeQuery);
        if (codeCount > 0) {
            return Result.error("Distribution code already exists");
        }

        distributorService.save(distributor);
        return Result.success(distributor);
    }

    @PutMapping("/{id}")
    public Result<Distributor> updateDistributor(@PathVariable Long id, @RequestBody Distributor distributor) {
        distributor.setId(id);
        Distributor existing = distributorService.getById(id);

        if (existing == null) {
            return Result.error("Distributor not found");
        }

        // Check if username is being updated and if it already exists
        if (StringUtils.hasText(distributor.getUsername())) {
            // Only check for duplicates if username is being changed
            if (existing.getUsername() == null || !distributor.getUsername().equals(existing.getUsername())) {
                QueryWrapper<Distributor> usernameQuery = new QueryWrapper<>();
                usernameQuery.eq("username", distributor.getUsername());
                usernameQuery.ne("id", id);
                long usernameCount = distributorService.count(usernameQuery);
                if (usernameCount > 0) {
                    return Result.error("Username already exists");
                }
            }
        }

        // Check if code is being updated and if it already exists
        if (StringUtils.hasText(distributor.getCode())) {
            // Only check for duplicates if code is being changed
            if (existing.getCode() == null || !distributor.getCode().equals(existing.getCode())) {
                QueryWrapper<Distributor> codeQuery = new QueryWrapper<>();
                codeQuery.eq("code", distributor.getCode());
                codeQuery.ne("id", id);
                long codeCount = distributorService.count(codeQuery);
                if (codeCount > 0) {
                    return Result.error("Distribution code already exists");
                }
            }
        }

        distributorService.updateById(distributor);
        return Result.success(distributor);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteDistributor(@PathVariable Long id) {
        distributorService.removeById(id);
        return Result.success("Deleted");
    }

    @GetMapping("/{id}/stats")
    public Result<java.util.Map<String, Object>> getStats(@PathVariable Long id) {
        // Mock stats for now
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        stats.put("clicks", (int)(Math.random() * 1000));
        stats.put("conversions", (int)(Math.random() * 100));
        stats.put("income", new java.math.BigDecimal(Math.random() * 5000).setScale(2, java.math.RoundingMode.HALF_UP));
        return Result.success(stats);
    }
}
