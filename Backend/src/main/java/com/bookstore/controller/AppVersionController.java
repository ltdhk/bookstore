package com.bookstore.controller;

import com.bookstore.common.Result;
import com.bookstore.dto.VersionCheckDTO;
import com.bookstore.service.AppVersionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/version")
public class AppVersionController {

    @Autowired
    private AppVersionService appVersionService;

    /**
     * Check if there's a new version available
     * @param platform ios or android
     * @param versionCode the client's current version code (e.g., 10203 for version 1.2.3)
     * @return version check result
     */
    @GetMapping("/check")
    public Result<VersionCheckDTO> checkVersion(
            @RequestParam String platform,
            @RequestParam Integer versionCode) {
        return Result.success(appVersionService.checkVersion(platform, versionCode));
    }
}
