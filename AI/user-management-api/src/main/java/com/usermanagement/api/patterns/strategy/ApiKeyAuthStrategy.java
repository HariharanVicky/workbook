package com.usermanagement.api.patterns.strategy;

import com.usermanagement.api.models.User;
import com.usermanagement.api.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Strategy Pattern: API Key Authentication Strategy
 * Handles API key based authentication for service-to-service communication
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class ApiKeyAuthStrategy implements AuthenticationStrategy {
    
    private final UserRepository userRepository;
    
    @Override
    public User authenticate(String credentials) {
        try {
            // API key format: "apikey:key_value"
            if (!credentials.startsWith("apikey:")) {
                log.warn("Invalid API key format");
                return null;
            }
            
            String apiKey = credentials.substring(7); // Remove "apikey:" prefix
            
            // In a real implementation, you would validate against a stored API key
            // For demo purposes, we'll use a simple validation
            if (isValidApiKey(apiKey)) {
                // Find user associated with this API key
                Optional<User> user = userRepository.findByEmail("admin@example.com");
                if (user.isPresent()) {
                    log.info("API key authentication successful");
                    return user.get();
                }
            }
            
            log.warn("Invalid API key provided");
            return null;
        } catch (Exception e) {
            log.error("Error during API key authentication", e);
            return null;
        }
    }
    
    @Override
    public String getAuthenticationMethod() {
        return "API_KEY";
    }
    
    @Override
    public boolean isEnabled() {
        return true; // API key auth is enabled
    }
    
    private boolean isValidApiKey(String apiKey) {
        // Simple validation - in real implementation, check against database
        return apiKey != null && apiKey.length() >= 32 && apiKey.startsWith("sk_");
    }
} 