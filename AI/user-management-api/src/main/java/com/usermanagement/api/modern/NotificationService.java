package com.usermanagement.api.modern;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Modernized Notification Service
 * Follows Single Responsibility Principle - only handles notifications
 * Follows Open/Closed Principle - easy to extend with new notification types
 */
@Service
@Slf4j
public class NotificationService {
    
    /**
     * Send welcome email notification
     * @param email Recipient email
     * @param userName User's name
     */
    public void sendWelcomeEmail(String email, String userName) {
        try {
            log.info("Sending welcome email to: {} for user: {}", email, userName);
            // In a real implementation, this would use a proper email service
            // For demo purposes, we just log the action
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", email, e);
            throw new NotificationException("Failed to send welcome email", e);
        }
    }
    
    /**
     * Send password change notification
     * @param email Recipient email
     */
    public void sendPasswordChangeNotification(String email) {
        try {
            log.info("Sending password change notification to: {}", email);
            // In a real implementation, this would use a proper email service
        } catch (Exception e) {
            log.error("Failed to send password change notification to: {}", email, e);
            throw new NotificationException("Failed to send password change notification", e);
        }
    }
    
    /**
     * Send account locked notification
     * @param email Recipient email
     */
    public void sendAccountLockedNotification(String email) {
        try {
            log.info("Sending account locked notification to: {}", email);
            // In a real implementation, this would use a proper email service
        } catch (Exception e) {
            log.error("Failed to send account locked notification to: {}", email, e);
            throw new NotificationException("Failed to send account locked notification", e);
        }
    }
    
    /**
     * Custom exception for notification failures
     */
    public static class NotificationException extends RuntimeException {
        public NotificationException(String message, Throwable cause) {
            super(message, cause);
        }
    }
} 