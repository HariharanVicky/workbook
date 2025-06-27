package com.usermanagement.api.patterns.observer;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Observer Pattern: User Event Manager
 * Manages user event listeners and notifies them when events occur
 */
@Component
@Slf4j
public class UserEventManager {
    
    private final List<UserEventListener> listeners = new CopyOnWriteArrayList<>();
    
    /**
     * Add a listener to be notified of user events
     * @param listener The listener to add
     */
    public void addListener(UserEventListener listener) {
        listeners.add(listener);
        log.info("Added user event listener: {}", listener.getListenerName());
    }
    
    /**
     * Remove a listener from notifications
     * @param listener The listener to remove
     */
    public void removeListener(UserEventListener listener) {
        listeners.remove(listener);
        log.info("Removed user event listener: {}", listener.getListenerName());
    }
    
    /**
     * Notify all listeners of a user event
     * @param event The user event to notify about
     */
    public void notifyListeners(UserEvent event) {
        log.info("Notifying {} listeners of event: {}", listeners.size(), event.getType());
        
        for (UserEventListener listener : listeners) {
            try {
                listener.onUserEvent(event);
            } catch (Exception e) {
                log.error("Error notifying listener {} of event {}", 
                         listener.getListenerName(), event.getType(), e);
            }
        }
    }
    
    /**
     * Get the current number of listeners
     * @return Number of active listeners
     */
    public int getListenerCount() {
        return listeners.size();
    }
} 