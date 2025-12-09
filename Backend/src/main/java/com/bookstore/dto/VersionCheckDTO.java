package com.bookstore.dto;

import lombok.Data;

@Data
public class VersionCheckDTO {
    private Boolean hasUpdate;
    private Boolean forceUpdate;
    private String latestVersion;
    private Integer latestVersionCode;
    private String updateUrl;
    private String releaseNotes;
}
