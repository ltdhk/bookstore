package com.bookstore.vo;

import lombok.Data;

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
}
