package com.bookstore.service;

import com.bookstore.dto.GoogleSignInRequest;
import com.bookstore.vo.UserVO;

public interface GoogleSignInService {
    UserVO signInWithGoogle(GoogleSignInRequest request);
}
