package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.bookstore.dto.VersionCheckDTO;
import com.bookstore.entity.AppVersion;
import com.bookstore.repository.AppVersionMapper;
import com.bookstore.service.AppVersionService;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl extends ServiceImpl<AppVersionMapper, AppVersion> implements AppVersionService {

    @Override
    public VersionCheckDTO checkVersion(String platform, Integer currentVersionCode) {
        VersionCheckDTO result = new VersionCheckDTO();

        // Get the latest version for the platform
        AppVersion latestVersion = baseMapper.selectLatestByPlatform(platform);

        if (latestVersion == null) {
            // No version record found
            result.setHasUpdate(false);
            result.setForceUpdate(false);
            return result;
        }

        // Check if there's an update
        boolean hasUpdate = latestVersion.getVersionCode() > currentVersionCode;
        result.setHasUpdate(hasUpdate);

        if (hasUpdate) {
            result.setLatestVersion(latestVersion.getVersionName());
            result.setLatestVersionCode(latestVersion.getVersionCode());
            result.setUpdateUrl(latestVersion.getUpdateUrl());
            result.setReleaseNotes(latestVersion.getReleaseNotes());

            // Determine if force update is required
            // Force update if: current version < minSupportedVersion OR latest version has forceUpdate=true
            boolean forceUpdate = false;
            if (latestVersion.getMinSupportedVersion() != null && currentVersionCode < latestVersion.getMinSupportedVersion()) {
                forceUpdate = true;
            }
            if (Boolean.TRUE.equals(latestVersion.getForceUpdate())) {
                forceUpdate = true;
            }
            result.setForceUpdate(forceUpdate);
        } else {
            result.setForceUpdate(false);
        }

        return result;
    }

    @Override
    public IPage<AppVersion> getVersionList(Page<AppVersion> page, String platform) {
        LambdaQueryWrapper<AppVersion> queryWrapper = new LambdaQueryWrapper<>();

        if (platform != null && !platform.isEmpty()) {
            queryWrapper.eq(AppVersion::getPlatform, platform);
        }

        queryWrapper.orderByDesc(AppVersion::getVersionCode);

        return page(page, queryWrapper);
    }
}
