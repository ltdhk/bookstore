package com.bookstore.exception;

import com.bookstore.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public Result<String> handleRuntimeException(RuntimeException e) {
        log.error("Runtime Exception: ", e);
        return Result.error(e.getMessage());
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public Result<String> handleNoResourceFoundException(NoResourceFoundException e) {
        // Common requests for non-existent static resources (favicon.ico, robots.txt, etc.)
        // Log at debug level to reduce noise
        String resourcePath = e.getMessage();
        if (resourcePath != null &&
            (resourcePath.contains("favicon.ico") ||
             resourcePath.contains("security.txt") ||
             resourcePath.contains("robots.txt") ||
             resourcePath.equals("No static resource ."))) {
            log.debug("Static resource not found (expected): {}", resourcePath);
        } else {
            log.warn("Static resource not found: {}", resourcePath);
        }
        return Result.error("Resource not found");
    }

    @ExceptionHandler(Exception.class)
    public Result<String> handleException(Exception e) {
        log.error("System Exception: ", e);
        return Result.error("System Error, please contact admin.");
    }
}
