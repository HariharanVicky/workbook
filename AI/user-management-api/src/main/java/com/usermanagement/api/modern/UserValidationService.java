package com.usermanagement.api.modern;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.regex.Pattern;

/**
 * Modernized User Validation Service
 * Follows Single Responsibility Principle - only handles validation
 */
@Service
@Slf4j
public class UserValidationService {
    
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");
    private static final int MIN_PASSWORD_LENGTH = 6;
    
    /**
     * Validate user email
     * @param email Email to validate
     * @return Validation result
     */
    public ValidationResult validateEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return ValidationResult.failure("Email is required");
        }
        
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            return ValidationResult.failure("Invalid email format");
        }
        
        return ValidationResult.success();
    }
    
    /**
     * Validate user password
     * @param password Password to validate
     * @return Validation result
     */
    public ValidationResult validatePassword(String password) {
        if (password == null || password.length() < MIN_PASSWORD_LENGTH) {
            return ValidationResult.failure("Password must be at least " + MIN_PASSWORD_LENGTH + " characters");
        }
        
        return ValidationResult.success();
    }
    
    /**
     * Validate user name
     * @param name Name to validate
     * @return Validation result
     */
    public ValidationResult validateName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return ValidationResult.failure("Name is required");
        }
        
        if (name.trim().length() < 2) {
            return ValidationResult.failure("Name must be at least 2 characters");
        }
        
        return ValidationResult.success();
    }
    
    /**
     * Validation result class
     */
    public static class ValidationResult {
        private final boolean valid;
        private final String errorMessage;
        
        private ValidationResult(boolean valid, String errorMessage) {
            this.valid = valid;
            this.errorMessage = errorMessage;
        }
        
        public static ValidationResult success() {
            return new ValidationResult(true, null);
        }
        
        public static ValidationResult failure(String errorMessage) {
            return new ValidationResult(false, errorMessage);
        }
        
        public boolean isValid() {
            return valid;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
    }
} 