package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("app_versions")
public class AppVersion {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Integer versionCode;
    private String versionName;
    private String platform;
    private Boolean forceUpdate;
    private Integer minSupportedVersion;
    private String updateUrl;
    private String releaseNotes;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
