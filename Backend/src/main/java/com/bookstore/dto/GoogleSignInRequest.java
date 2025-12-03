package com.bookstore.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class GoogleSignInRequest {
    @NotBlank(message = "ID token is required")
    private String idToken;

    private String serverAuthCode;
    private String email;
    private String displayName;
    private String photoUrl;
}
