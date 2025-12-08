package com.bookstore.dto;

import lombok.Data;
import java.util.List;

@Data
public class UserInfoDTO {
    private String role;
    private String username;
    private String displayName;
    private Long distributorId;
    private List<String> permissions;
}
