package com.usermanagement.api.patterns.observer;

import com.usermanagement.api.models.User;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * Observer Pattern: User Event
 * Represents different events that can occur in the user management system
 */
@Data
public class UserEvent {
    private final UserEventType type;
    private final User user;
    private final LocalDateTime timestamp;
    private final String description;
    
    public UserEvent(UserEventType type, User user, String description) {
        this.type = type;
        this.user = user;
        this.timestamp = LocalDateTime.now();
        this.description = description;
    }
    
    public enum UserEventType {
        USER_REGISTERED,
        USER_LOGGED_IN,
        USER_LOGGED_OUT,
        USER_UPDATED,
        USER_DELETED,
        PASSWORD_CHANGED,
        ACCOUNT_LOCKED,
        ACCOUNT_UNLOCKED
    }
} 