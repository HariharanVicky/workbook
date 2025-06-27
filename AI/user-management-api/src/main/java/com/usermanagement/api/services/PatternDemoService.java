package com.usermanagement.api.services;

import com.usermanagement.api.models.User;
import com.usermanagement.api.patterns.factory.DatabaseConnection;
import com.usermanagement.api.patterns.factory.DatabaseConnectionFactory;
import com.usermanagement.api.patterns.observer.UserEvent;
import com.usermanagement.api.patterns.observer.UserEventManager;
import com.usermanagement.api.patterns.strategy.AuthenticationStrategy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Service demonstrating the usage of all three design patterns:
 * - Strategy Pattern (Authentication Strategies)
 * - Observer Pattern (User Event Notifications)
 * - Factory Pattern (Database Connection Factory)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PatternDemoService {
    
    private final UserEventManager userEventManager;
    private final DatabaseConnectionFactory databaseConnectionFactory;
    private final List<AuthenticationStrategy> authenticationStrategies;
    
    /**
     * Demonstrate Strategy Pattern: Try different authentication methods
     */
    public User authenticateWithStrategy(String credentials, String strategyType) {
        log.info("Attempting authentication with strategy: {}", strategyType);
        
        AuthenticationStrategy strategy = authenticationStrategies.stream()
                .filter(s -> s.getAuthenticationMethod().equals(strategyType))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Unknown authentication strategy: " + strategyType));
        
        if (!strategy.isEnabled()) {
            throw new IllegalStateException("Authentication strategy is disabled: " + strategyType);
        }
        
        User user = strategy.authenticate(credentials);
        if (user != null) {
            // Demonstrate Observer Pattern: Notify listeners of login event
            UserEvent loginEvent = new UserEvent(UserEvent.UserEventType.USER_LOGGED_IN, user, "User logged in successfully");
            userEventManager.notifyListeners(loginEvent);
        }
        
        return user;
    }
    
    /**
     * Demonstrate Observer Pattern: Trigger user events
     */
    public void triggerUserEvent(User user, UserEvent.UserEventType eventType, String description) {
        log.info("Triggering user event: {} for user: {}", eventType, user.getEmail());
        
        UserEvent event = new UserEvent(eventType, user, description);
        userEventManager.notifyListeners(event);
    }
    
    /**
     * Demonstrate Factory Pattern: Create different database connections
     */
    public Map<String, Object> testDatabaseConnections() {
        log.info("Testing database connection factory");
        
        try {
            // Test PostgreSQL connection
            DatabaseConnection postgresConnection = databaseConnectionFactory.createConnection(DatabaseConnection.DatabaseType.POSTGRESQL);
            log.info("PostgreSQL connection created: {}", postgresConnection.getUrl());
            
            // Test H2 connection
            DatabaseConnection h2Connection = databaseConnectionFactory.createConnection(DatabaseConnection.DatabaseType.H2);
            log.info("H2 connection created: {}", h2Connection.getUrl());
            
            // Close connections
            postgresConnection.close();
            h2Connection.close();
            
            return Map.of(
                "postgresql", Map.of("url", postgresConnection.getUrl(), "active", postgresConnection.isActive()),
                "h2", Map.of("url", h2Connection.getUrl(), "active", h2Connection.isActive()),
                "listenerCount", userEventManager.getListenerCount()
            );
            
        } catch (SQLException e) {
            log.error("Error creating database connections", e);
            throw new RuntimeException("Database connection test failed", e);
        }
    }
    
    /**
     * Get available authentication strategies
     */
    public List<String> getAvailableAuthenticationStrategies() {
        return authenticationStrategies.stream()
                .filter(AuthenticationStrategy::isEnabled)
                .map(AuthenticationStrategy::getAuthenticationMethod)
                .toList();
    }
    
    /**
     * Get current event listener count
     */
    public int getEventListenerCount() {
        return userEventManager.getListenerCount();
    }
} 