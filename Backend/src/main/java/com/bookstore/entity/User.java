package com.bookstore.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("users")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;
    private String password;
    private String nickname;
    private String email;
    private String phone;
    private String avatar;
    private Integer coins;
    private Integer bonus;
    private Boolean isSvip;

    // Subscription status fields
    private String subscriptionStatus; // none, active, expired, cancelled
    private LocalDateTime subscriptionEndDate;
    private String subscriptionPlanType; // monthly, quarterly, yearly

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableLogic
    private Integer deleted;
}
