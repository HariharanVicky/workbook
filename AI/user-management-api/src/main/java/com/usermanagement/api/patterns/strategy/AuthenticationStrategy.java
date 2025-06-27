package com.usermanagement.api.patterns.strategy;

import com.usermanagement.api.models.User;

/**
 * Strategy Pattern: Authentication Strategy Interface
 * Defines different authentication methods for user management
 */
public interface AuthenticationStrategy {
    /**
     * Authenticate a user with the given credentials
     * @param credentials The authentication credentials
     * @return Authenticated user if successful, null otherwise
     */
    User authenticate(String credentials);
    
    /**
     * Get the authentication method name
     * @return Authentication method name
     */
    String getAuthenticationMethod();
    
    /**
     * Check if this authentication method is enabled
     * @return true if enabled, false otherwise
     */
    boolean isEnabled();
} 