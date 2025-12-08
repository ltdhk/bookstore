package com.bookstore.config;

import com.bookstore.util.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Arrays;
import java.util.List;

@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtils jwtUtils;

    // 分销商可访问的 API 路径前缀
    private static final List<String> DISTRIBUTOR_ALLOWED_PATHS = Arrays.asList(
        "/api/admin/auth/user-info",
        "/api/admin/auth/logout",
        "/api/admin/auth/verify",
        "/api/admin/dashboard",
        "/api/admin/books",
        "/api/admin/subscription",
        "/api/admin/categories",
        "/api/admin/tags",
        "/api/admin/languages",
        "/api/admin/covers",
        "/api/admin/passcodes"  // 口令管理（书籍内的口令功能）
    );

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Allow OPTIONS requests
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String uri = request.getRequestURI();

        // Check if this is an optional auth path (public but benefits from user context)
        boolean isOptionalAuthPath = uri.startsWith("/api/v1/books");

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            if (jwtUtils.validateToken(token)) {
                String role = jwtUtils.getRoleFromToken(token);
                Long userId = jwtUtils.getUserIdFromToken(token);

                // 处理 admin 路由的权限检查
                if (uri.startsWith("/api/admin")) {
                    if ("admin".equals(role)) {
                        // 管理员可以访问所有 admin 路由
                    } else if ("distributor".equals(role)) {
                        // 分销商只能访问特定路径
                        boolean allowed = DISTRIBUTOR_ALLOWED_PATHS.stream()
                                .anyMatch(uri::startsWith);
                        if (!allowed) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"code\": 403, \"message\": \"没有权限访问此功能\", \"data\": null}");
                            return false;
                        }
                        // 将 distributorId 存入 request attribute，供后续使用
                        request.setAttribute("distributorId", userId);
                    } else {
                        // 其他角色不能访问 admin 路由
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"code\": 403, \"message\": \"Forbidden\", \"data\": null}");
                        return false;
                    }
                }

                // Store user info in request attribute for controller access
                request.setAttribute("userId", userId);
                request.setAttribute("username", jwtUtils.getUsernameFromToken(token));
                request.setAttribute("role", role);
                return true;
            }
        }

        // For optional auth paths, allow access without token (userId will be null)
        if (isOptionalAuthPath) {
            return true;
        }

        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"code\": 401, \"message\": \"Unauthorized\", \"data\": null}");
        return false;
    }
}
