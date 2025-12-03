package com.bookstore.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AppleSignInRequest {
    /**
     * Apple identity token (JWT) from Sign in with Apple
     */
    @NotBlank(message = "Identity token is required")
    private String identityToken;

    /**
     * Authorization code for server-to-server verification (optional)
     */
    private String authorizationCode;

    /**
     * User's email (may be null after first login, or a private relay email)
     */
    private String email;

    /**
     * User's full name (combined given + family name, may be null after first login)
     */
    private String fullName;

    /**
     * Nonce for replay attack prevention
     */
    private String nonce;
}
