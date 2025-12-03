package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bookstore.config.AppleSignInConfig;
import com.bookstore.dto.AppleSignInRequest;
import com.bookstore.entity.User;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.AppleSignInService;
import com.bookstore.util.JwtUtils;
import com.bookstore.vo.UserVO;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.UUID;

@Slf4j
@Service
public class AppleSignInServiceImpl implements AppleSignInService {

    private static final String APPLE_KEYS_URL = "https://appleid.apple.com/auth/keys";
    private static final String APPLE_ISSUER = "https://appleid.apple.com";

    @Autowired
    private AppleSignInConfig appleConfig;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public UserVO signInWithApple(AppleSignInRequest request) {
        // 1. Verify the identity token and extract claims
        AppleTokenClaims claims = verifyIdentityToken(request.getIdentityToken());

        // 2. Find existing user by Apple user ID
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getAppleUserId, claims.sub));

        if (user == null) {
            // 3. Try to find by email and link accounts
            String email = claims.email != null ? claims.email : request.getEmail();
            if (email != null && !email.isEmpty()) {
                user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                        .eq(User::getEmail, email));
                if (user != null) {
                    // Link Apple ID to existing account
                    user.setAppleUserId(claims.sub);
                    userMapper.updateById(user);
                    log.info("Linked Apple ID to existing user: {}", user.getId());
                }
            }
        }

        if (user == null) {
            // 4. Create new user
            user = createUserFromApple(claims, request);
        }

        // 5. Generate JWT and return UserVO
        return convertToVO(user);
    }

    private AppleTokenClaims verifyIdentityToken(String identityToken) {
        try {
            // Fetch Apple's public keys
            JWKSet jwkSet = JWKSet.load(new URL(APPLE_KEYS_URL));

            // Create JWT processor
            ConfigurableJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>();
            JWSKeySelector<SecurityContext> keySelector = new JWSVerificationKeySelector<>(
                    JWSAlgorithm.RS256,
                    new ImmutableJWKSet<>(jwkSet)
            );
            jwtProcessor.setJWSKeySelector(keySelector);

            // Process and verify the token
            JWTClaimsSet claimsSet = jwtProcessor.process(identityToken, null);

            // Validate issuer
            if (!APPLE_ISSUER.equals(claimsSet.getIssuer())) {
                throw new RuntimeException("Invalid token issuer");
            }

            // Validate audience (should be your client ID)
            if (!claimsSet.getAudience().contains(appleConfig.getClientId())) {
                log.warn("Token audience {} does not match client ID {}",
                        claimsSet.getAudience(), appleConfig.getClientId());
                // For development, we might want to be more lenient
                // throw new RuntimeException("Invalid token audience");
            }

            // Check expiration
            if (claimsSet.getExpirationTime().getTime() < System.currentTimeMillis()) {
                throw new RuntimeException("Token has expired");
            }

            // Extract claims
            AppleTokenClaims claims = new AppleTokenClaims();
            claims.sub = claimsSet.getSubject();
            claims.email = claimsSet.getStringClaim("email");
            claims.emailVerified = claimsSet.getBooleanClaim("email_verified");
            claims.isPrivateEmail = claimsSet.getBooleanClaim("is_private_email");

            log.info("Apple token verified successfully for user: {}", claims.sub);
            return claims;

        } catch (Exception e) {
            log.error("Failed to verify Apple identity token", e);
            throw new RuntimeException("Invalid Apple identity token: " + e.getMessage());
        }
    }

    private User createUserFromApple(AppleTokenClaims claims, AppleSignInRequest request) {
        User user = new User();

        // Use Apple user ID as a unique identifier
        user.setAppleUserId(claims.sub);

        // Generate unique username from Apple user ID
        String shortId = claims.sub.length() > 8 ? claims.sub.substring(0, 8) : claims.sub;
        user.setUsername("apple_" + shortId + "_" + System.currentTimeMillis());

        // Set email from token or request
        String email = claims.email != null ? claims.email : request.getEmail();
        user.setEmail(email);

        // Set password to a random value (user won't use password login)
        user.setPassword(UUID.randomUUID().toString());

        // Set nickname from request or generate default
        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setNickname(request.getFullName());
        } else {
            user.setNickname("User_" + System.currentTimeMillis());
        }

        // Set default avatar
        user.setAvatar("https://api.dicebear.com/7.x/avataaars/svg?seed=" + claims.sub);

        // Initialize user with default values
        user.setCoins(0);
        user.setBonus(0);
        user.setIsSvip(false);

        userMapper.insert(user);
        log.info("Created new user from Apple Sign In: {}", user.getId());

        return user;
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setToken(jwtUtils.generateToken(user.getId(), user.getUsername()));
        return vo;
    }

    /**
     * Internal class to hold Apple token claims
     */
    private static class AppleTokenClaims {
        String sub;           // Apple user ID (unique, stable)
        String email;         // User's email (may be private relay)
        Boolean emailVerified;
        Boolean isPrivateEmail;
    }
}
