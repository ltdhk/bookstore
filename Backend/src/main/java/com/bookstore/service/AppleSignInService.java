package com.bookstore.service;

import com.bookstore.dto.AppleSignInRequest;
import com.bookstore.vo.UserVO;

public interface AppleSignInService {
    /**
     * Verify Apple identity token and sign in or register the user.
     * If email matches an existing user, the Apple ID will be linked to that account.
     *
     * @param request Apple sign in request containing identity token
     * @return UserVO with JWT token
     */
    UserVO signInWithApple(AppleSignInRequest request);
}
