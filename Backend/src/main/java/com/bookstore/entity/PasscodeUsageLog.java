package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("passcode_usage_logs")
public class PasscodeUsageLog {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long passcodeId;

    private Long userId;

    private Long bookId;

    private Long distributorId;

    private String actionType; // open: Open Book, view: View Chapter

    private String ipAddress;

    private String deviceInfo;

    private LocalDateTime createdAt;
}
