package com.usermanagement.api.patterns.observer;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Observer Pattern: Email Notification Listener
 * Sends email notifications when user events occur
 */
@Component
@Slf4j
public class EmailNotificationListener implements UserEventListener {
    
    @Override
    public void onUserEvent(UserEvent event) {
        switch (event.getType()) {
            case USER_REGISTERED:
                sendWelcomeEmail(event);
                break;
            case PASSWORD_CHANGED:
                sendPasswordChangeNotification(event);
                break;
            case ACCOUNT_LOCKED:
                sendAccountLockedNotification(event);
                break;
            case ACCOUNT_UNLOCKED:
                sendAccountUnlockedNotification(event);
                break;
            default:
                log.debug("No email notification needed for event: {}", event.getType());
        }
    }
    
    @Override
    public String getListenerName() {
        return "EmailNotificationListener";
    }
    
    private void sendWelcomeEmail(UserEvent event) {
        log.info("Sending welcome email to: {}", event.getUser().getEmail());
        // In a real implementation, this would send an actual email
        // For demo purposes, we just log the action
    }
    
    private void sendPasswordChangeNotification(UserEvent event) {
        log.info("Sending password change notification to: {}", event.getUser().getEmail());
        // In a real implementation, this would send an actual email
    }
    
    private void sendAccountLockedNotification(UserEvent event) {
        log.info("Sending account locked notification to: {}", event.getUser().getEmail());
        // In a real implementation, this would send an actual email
    }
    
    private void sendAccountUnlockedNotification(UserEvent event) {
        log.info("Sending account unlocked notification to: {}", event.getUser().getEmail());
        // In a real implementation, this would send an actual email
    }
} 