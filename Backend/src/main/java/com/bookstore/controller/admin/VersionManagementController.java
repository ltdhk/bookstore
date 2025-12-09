package com.bookstore.controller.admin;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.bookstore.common.Result;
import com.bookstore.entity.AppVersion;
import com.bookstore.service.AppVersionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/versions")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class VersionManagementController {

    private final AppVersionService appVersionService;

    @GetMapping
    public Result<IPage<AppVersion>> getVersions(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String platform) {
        Page<AppVersion> pageParam = new Page<>(page, size);
        IPage<AppVersion> result = appVersionService.getVersionList(pageParam, platform);
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<AppVersion> getVersion(@PathVariable Long id) {
        AppVersion version = appVersionService.getById(id);
        return Result.success(version);
    }

    @PostMapping
    public Result<AppVersion> createVersion(@RequestBody AppVersion version) {
        appVersionService.save(version);
        return Result.success(version);
    }

    @PutMapping("/{id}")
    public Result<AppVersion> updateVersion(@PathVariable Long id, @RequestBody AppVersion version) {
        version.setId(id);
        appVersionService.updateById(version);
        return Result.success(version);
    }

    @DeleteMapping("/{id}")
    public Result<String> deleteVersion(@PathVariable Long id) {
        appVersionService.removeById(id);
        return Result.success("Deleted");
    }
}
