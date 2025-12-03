package com.bookstore.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.bookstore.config.GoogleSignInConfig;
import com.bookstore.dto.GoogleSignInRequest;
import com.bookstore.entity.User;
import com.bookstore.repository.UserMapper;
import com.bookstore.service.GoogleSignInService;
import com.bookstore.util.JwtUtils;
import com.bookstore.vo.UserVO;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.UUID;

@Slf4j
@Service
public class GoogleSignInServiceImpl implements GoogleSignInService {

    @Autowired
    private GoogleSignInConfig googleConfig;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public UserVO signInWithGoogle(GoogleSignInRequest request) {
        // 1. Verify the ID token and extract claims
        GoogleTokenClaims claims = verifyIdToken(request.getIdToken());

        // 2. Find existing user by Google user ID
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getGoogleUserId, claims.sub));

        if (user == null) {
            // 3. Try to find by email and link accounts
            String email = claims.email != null ? claims.email : request.getEmail();
            if (email != null && !email.isEmpty()) {
                user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                        .eq(User::getEmail, email));
                if (user != null) {
                    user.setGoogleUserId(claims.sub);
                    userMapper.updateById(user);
                    log.info("Linked Google ID to existing user: {}", user.getId());
                }
            }
        }

        if (user == null) {
            // 4. Create new user
            user = createUserFromGoogle(claims, request);
        }

        // 5. Generate JWT and return UserVO
        return convertToVO(user);
    }

    private GoogleTokenClaims verifyIdToken(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
                    .setAudience(Arrays.asList(
                            googleConfig.getWebClientId(),
                            googleConfig.getAndroidClientId(),
                            googleConfig.getIosClientId()))
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken == null) {
                throw new RuntimeException("Invalid Google ID token");
            }

            GoogleIdToken.Payload payload = idToken.getPayload();

            GoogleTokenClaims claims = new GoogleTokenClaims();
            claims.sub = payload.getSubject();
            claims.email = payload.getEmail();
            claims.emailVerified = payload.getEmailVerified();
            claims.name = (String) payload.get("name");
            claims.pictureUrl = (String) payload.get("picture");

            log.info("Google token verified successfully for user: {}", claims.sub);
            return claims;

        } catch (Exception e) {
            log.error("Failed to verify Google ID token", e);
            throw new RuntimeException("Invalid Google ID token: " + e.getMessage());
        }
    }

    private User createUserFromGoogle(GoogleTokenClaims claims, GoogleSignInRequest request) {
        User user = new User();
        user.setGoogleUserId(claims.sub);

        // Set email
        String email = claims.email != null ? claims.email : request.getEmail();
        user.setEmail(email);

        // Use email as username, or generate if email is null
        if (email != null && !email.isEmpty()) {
            user.setUsername(email);
        } else {
            // Fallback if email is somehow null
            String shortId = claims.sub.length() > 8 ? claims.sub.substring(0, 8) : claims.sub;
            user.setUsername("google_" + shortId + "_" + System.currentTimeMillis());
        }

        // Random password (not used for Google login)
        user.setPassword(UUID.randomUUID().toString());

        // Set nickname from Google profile or generate one
        String nickname = claims.name != null ? claims.name :
                         (request.getDisplayName() != null ? request.getDisplayName() :
                         "User_" + System.currentTimeMillis());
        user.setNickname(nickname);

        // Set avatar from Google or use default
        String avatar = claims.pictureUrl != null ? claims.pictureUrl :
                       (request.getPhotoUrl() != null ? request.getPhotoUrl() :
                       "https://api.dicebear.com/7.x/avataaars/svg?seed=" + claims.sub);
        user.setAvatar(avatar);

        // Initialize user data
        user.setCoins(0);
        user.setBonus(0);
        user.setIsSvip(false);

        userMapper.insert(user);
        log.info("Created new user from Google Sign In: {}", user.getId());
        return user;
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        vo.setToken(jwtUtils.generateToken(user.getId(), user.getUsername()));
        return vo;
    }

    /**
     * Internal class to hold Google token claims
     */
    private static class GoogleTokenClaims {
        String sub;
        String email;
        Boolean emailVerified;
        String name;
        String pictureUrl;
    }
}
