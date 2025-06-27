package com.usermanagement.api.patterns.observer;

/**
 * Observer Pattern: User Event Listener Interface
 * Defines the contract for objects that want to be notified of user events
 */
public interface UserEventListener {
    /**
     * Handle a user event
     * @param event The user event that occurred
     */
    void onUserEvent(UserEvent event);
    
    /**
     * Get the listener name for identification
     * @return Listener name
     */
    String getListenerName();
} 