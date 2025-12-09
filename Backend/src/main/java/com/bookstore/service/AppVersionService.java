package com.bookstore.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.bookstore.dto.VersionCheckDTO;
import com.bookstore.entity.AppVersion;

public interface AppVersionService extends IService<AppVersion> {

    /**
     * Check if there's a new version available
     * @param platform ios or android
     * @param currentVersionCode the client's current version code
     * @return version check result
     */
    VersionCheckDTO checkVersion(String platform, Integer currentVersionCode);

    /**
     * Get paginated list of all versions
     */
    IPage<AppVersion> getVersionList(Page<AppVersion> page, String platform);
}
