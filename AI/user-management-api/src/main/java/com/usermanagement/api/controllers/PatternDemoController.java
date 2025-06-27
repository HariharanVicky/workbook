package com.usermanagement.api.controllers;

import com.usermanagement.api.models.User;
import com.usermanagement.api.patterns.observer.UserEvent;
import com.usermanagement.api.services.PatternDemoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controller demonstrating the three design patterns:
 * - Strategy Pattern (Authentication Strategies)
 * - Observer Pattern (User Event Notifications)
 * - Factory Pattern (Database Connection Factory)
 */
@RestController
@RequestMapping("/api/patterns")
@RequiredArgsConstructor
@Slf4j
public class PatternDemoController {
    
    private final PatternDemoService patternDemoService;
    
    /**
     * Demonstrate Strategy Pattern: Authenticate with different strategies
     */
    @PostMapping("/strategy/authenticate")
    public ResponseEntity<?> authenticateWithStrategy(
            @RequestParam String credentials,
            @RequestParam String strategyType) {
        try {
            User user = patternDemoService.authenticateWithStrategy(credentials, strategyType);
            return ResponseEntity.ok(Map.of(
                "message", "Authentication successful",
                "strategy", strategyType,
                "user", Map.of("email", user.getEmail(), "role", user.getRole())
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Authentication failed",
                "message", e.getMessage()
            ));
        }
    }
    
    /**
     * Get available authentication strategies
     */
    @GetMapping("/strategy/available")
    public ResponseEntity<List<String>> getAvailableStrategies() {
        List<String> strategies = patternDemoService.getAvailableAuthenticationStrategies();
        return ResponseEntity.ok(strategies);
    }
    
    /**
     * Demonstrate Observer Pattern: Trigger a user event
     */
    @PostMapping("/observer/trigger-event")
    public ResponseEntity<?> triggerUserEvent(
            @RequestParam String userEmail,
            @RequestParam String eventType,
            @RequestParam String description) {
        try {
            // Create a mock user for demonstration
            User mockUser = User.builder()
                    .email(userEmail)
                    .firstName("Demo")
                    .lastName("User")
                    .build();
            
            UserEvent.UserEventType eventTypeEnum = UserEvent.UserEventType.valueOf(eventType.toUpperCase());
            patternDemoService.triggerUserEvent(mockUser, eventTypeEnum, description);
            
            return ResponseEntity.ok(Map.of(
                "message", "Event triggered successfully",
                "eventType", eventType,
                "userEmail", userEmail,
                "listenerCount", patternDemoService.getEventListenerCount()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Failed to trigger event",
                "message", e.getMessage()
            ));
        }
    }
    
    /**
     * Demonstrate Factory Pattern: Test database connections
     */
    @GetMapping("/factory/test-connections")
    public ResponseEntity<Map<String, Object>> testDatabaseConnections() {
        try {
            Map<String, Object> result = patternDemoService.testDatabaseConnections();
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Database connection test failed",
                "message", e.getMessage()
            ));
        }
    }
    
    /**
     * Get current event listener count
     */
    @GetMapping("/observer/listener-count")
    public ResponseEntity<Integer> getEventListenerCount() {
        int count = patternDemoService.getEventListenerCount();
        return ResponseEntity.ok(count);
    }
} 