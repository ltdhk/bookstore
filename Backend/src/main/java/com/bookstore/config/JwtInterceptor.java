package com.bookstore.config;

import com.bookstore.util.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Allow OPTIONS requests
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            if (jwtUtils.validateToken(token)) {
                String role = jwtUtils.getRoleFromToken(token);
                String uri = request.getRequestURI();

                if (uri.startsWith("/api/admin") && !"admin".equals(role)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"code\": 403, \"message\": \"Forbidden\", \"data\": null}");
                    return false;
                }
                
                // Optional: Prevent admins from accessing user APIs if strict separation is needed
                // if (uri.startsWith("/api/v1") && "admin".equals(role)) { ... }

                // Store user info in request attribute for controller access
                request.setAttribute("userId", jwtUtils.getUserIdFromToken(token));
                request.setAttribute("username", jwtUtils.getUsernameFromToken(token));
                request.setAttribute("role", role);
                return true;
            }
        }

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.getWriter().write("{\"code\": 401, \"message\": \"Unauthorized\", \"data\": null}");
        return false;
    }
}
