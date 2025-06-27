package com.usermanagement.api.patterns.strategy;

import com.usermanagement.api.models.User;
import com.usermanagement.api.services.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Strategy Pattern: Email/Password Authentication Strategy
 * Handles traditional email and password authentication
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class EmailPasswordAuthStrategy implements AuthenticationStrategy {
    
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    public User authenticate(String credentials) {
        try {
            // Parse credentials (format: "email:password")
            String[] parts = credentials.split(":");
            if (parts.length != 2) {
                log.warn("Invalid credentials format for email/password authentication");
                return null;
            }
            
            String email = parts[0];
            String password = parts[1];
            
            // Find user by email
            User user = userService.findByEmail(email);
            
            // Verify password
            if (passwordEncoder.matches(password, user.getPassword())) {
                log.info("User authenticated successfully: {}", email);
                return user;
            } else {
                log.warn("Invalid password for user: {}", email);
                return null;
            }
        } catch (Exception e) {
            log.error("Error during email/password authentication", e);
            return null;
        }
    }
    
    @Override
    public String getAuthenticationMethod() {
        return "EMAIL_PASSWORD";
    }
    
    @Override
    public boolean isEnabled() {
        return true; // Email/password is always enabled
    }
} 