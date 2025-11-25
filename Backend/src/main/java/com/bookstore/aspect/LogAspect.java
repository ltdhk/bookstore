package com.bookstore.aspect;

import com.bookstore.entity.OperationLog;
import com.bookstore.repository.OperationLogRepository;
import com.bookstore.util.JwtUtils;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.Arrays;

@Aspect
@Component
@RequiredArgsConstructor
public class LogAspect {

    private final OperationLogRepository logRepository;
    private final JwtUtils jwtUtils;

    // Intercept POST, PUT, DELETE methods in admin controllers
    @Pointcut("execution(* com.bookstore.controller.admin..*(..)) && (@annotation(org.springframework.web.bind.annotation.PostMapping) || @annotation(org.springframework.web.bind.annotation.PutMapping) || @annotation(org.springframework.web.bind.annotation.DeleteMapping))")
    public void adminLog() {}

    @AfterReturning(pointcut = "adminLog()", returning = "result")
    public void saveLog(JoinPoint joinPoint, Object result) {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) return;
            HttpServletRequest request = attributes.getRequest();

            OperationLog log = new OperationLog();
            
            // Get User Info from Token
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
                try {
                    Long userId = jwtUtils.getUserIdFromToken(token);
                    log.setAdminId(userId);
                    log.setUsername("Admin-" + userId); 
                } catch (Exception e) {
                    log.setUsername("Unknown");
                }
            }

            log.setAction(request.getMethod());
            log.setTarget(request.getRequestURI());
            log.setIp(request.getRemoteAddr());
            log.setParams(Arrays.toString(joinPoint.getArgs()));
            log.setCreateTime(LocalDateTime.now());

            logRepository.insert(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
