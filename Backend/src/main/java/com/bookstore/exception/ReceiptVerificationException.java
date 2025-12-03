package com.bookstore.exception;

/**
 * Receipt verification exception
 * Thrown when receipt verification fails
 */
public class ReceiptVerificationException extends RuntimeException {
    public ReceiptVerificationException(String message) {
        super(message);
    }

    public ReceiptVerificationException(String message, Throwable cause) {
        super(message, cause);
    }
}
