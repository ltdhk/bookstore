package com.bookstore.vo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserVO {
    private Long id;
    private String username;
    private String nickname;
    private String avatar;
    private Integer coins;
    private Integer bonus;
    private Boolean isSvip;
    private String token;

    // Subscription fields
    private String subscriptionStatus;
    private LocalDateTime subscriptionEndDate;
    private String subscriptionPlanType;
}
