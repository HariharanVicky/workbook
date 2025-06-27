package com.usermanagement.api.utils;

import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * User Data Processor - Moderately complex function for cross-language translation
 * This function demonstrates various programming concepts:
 * - Stream processing
 * - Lambda expressions
 * - Optional handling
 * - Exception handling
 * - Data transformation
 * - Sorting and filtering
 * - String manipulation
 * - Date/time processing
 */
@Component
@Slf4j
public class UserDataProcessor {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final int MIN_AGE = 18;
    private static final int MAX_AGE = 100;
    
    /**
     * Process and analyze user data with various operations
     * This is the function that will be translated to Python
     * 
     * @param users List of users to process
     * @param filters Optional filters to apply
     * @return Processed user statistics and analysis
     */
    public UserAnalysisResult processUserData(List<User> users, Map<String, Object> filters) {
        try {
            log.info("Starting user data processing for {} users", users.size());
            
            // Validate input
            if (users == null || users.isEmpty()) {
                log.warn("No users provided for processing");
                return UserAnalysisResult.empty();
            }
            
            // Apply filters if provided
            List<User> filteredUsers = applyFilters(users, filters);
            log.info("Applied filters, {} users remaining", filteredUsers.size());
            
            // Calculate basic statistics
            int totalUsers = filteredUsers.size();
            long activeUsers = filteredUsers.stream()
                    .filter(User::isEnabled)
                    .count();
            
            // Group users by role
            Map<Role, List<User>> usersByRole = filteredUsers.stream()
                    .collect(Collectors.groupingBy(User::getRole));
            
            // Calculate role distribution
            Map<Role, Double> roleDistribution = usersByRole.entrySet().stream()
                    .collect(Collectors.toMap(
                            Map.Entry::getKey,
                            entry -> (double) entry.getValue().size() / totalUsers * 100
                    ));
            
            // Find most common email domains
            Map<String, Long> emailDomains = filteredUsers.stream()
                    .map(user -> extractEmailDomain(user.getEmail()))
                    .filter(Objects::nonNull)
                    .collect(Collectors.groupingBy(
                            domain -> domain,
                            Collectors.counting()
                    ));
            
            List<String> topDomains = emailDomains.entrySet().stream()
                    .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                    .limit(5)
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());
            
            // Analyze user creation patterns
            Map<String, Long> creationByMonth = filteredUsers.stream()
                    .map(user -> formatCreationMonth(user.getCreatedAt()))
                    .filter(Objects::nonNull)
                    .collect(Collectors.groupingBy(
                            month -> month,
                            Collectors.counting()
                    ));
            
            // Find recent active users (created in last 30 days)
            LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
            long recentUsers = filteredUsers.stream()
                    .filter(user -> user.getCreatedAt() != null && user.getCreatedAt().isAfter(thirtyDaysAgo))
                    .count();
            
            // Calculate average name length
            double avgNameLength = filteredUsers.stream()
                    .mapToDouble(user -> calculateNameLength(user))
                    .average()
                    .orElse(0.0);
            
            // Find users with potential issues
            List<String> potentialIssues = identifyPotentialIssues(filteredUsers);
            
            // Create analysis result
            UserAnalysisResult result = UserAnalysisResult.builder()
                    .totalUsers(totalUsers)
                    .activeUsers((int) activeUsers)
                    .inactiveUsers((int) (totalUsers - activeUsers))
                    .roleDistribution(roleDistribution)
                    .topEmailDomains(topDomains)
                    .creationByMonth(creationByMonth)
                    .recentUsers((int) recentUsers)
                    .averageNameLength(avgNameLength)
                    .potentialIssues(potentialIssues)
                    .processingTimestamp(LocalDateTime.now())
                    .build();
            
            log.info("User data processing completed successfully");
            return result;
            
        } catch (Exception e) {
            log.error("Error processing user data", e);
            throw new UserDataProcessingException("Failed to process user data", e);
        }
    }
    
    /**
     * Apply filters to user list
     */
    private List<User> applyFilters(List<User> users, Map<String, Object> filters) {
        if (filters == null || filters.isEmpty()) {
            return users;
        }
        
        return users.stream()
                .filter(user -> {
                    // Filter by role
                    if (filters.containsKey("role")) {
                        Role filterRole = (Role) filters.get("role");
                        if (!user.getRole().equals(filterRole)) {
                            return false;
                        }
                    }
                    
                    // Filter by active status
                    if (filters.containsKey("active")) {
                        boolean activeFilter = (Boolean) filters.get("active");
                        if (user.isEnabled() != activeFilter) {
                            return false;
                        }
                    }
                    
                    // Filter by email domain
                    if (filters.containsKey("emailDomain")) {
                        String domainFilter = (String) filters.get("emailDomain");
                        String userDomain = extractEmailDomain(user.getEmail());
                        if (!domainFilter.equalsIgnoreCase(userDomain)) {
                            return false;
                        }
                    }
                    
                    return true;
                })
                .collect(Collectors.toList());
    }
    
    /**
     * Extract domain from email address
     */
    private String extractEmailDomain(String email) {
        if (email == null || !email.contains("@")) {
            return null;
        }
        return email.substring(email.indexOf("@") + 1).toLowerCase();
    }
    
    /**
     * Format creation date to month-year
     */
    private String formatCreationMonth(LocalDateTime createdAt) {
        if (createdAt == null) {
            return null;
        }
        return createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM"));
    }
    
    /**
     * Calculate total name length
     */
    private int calculateNameLength(User user) {
        String firstName = user.getFirstName() != null ? user.getFirstName() : "";
        String lastName = user.getLastName() != null ? user.getLastName() : "";
        return firstName.length() + lastName.length();
    }
    
    /**
     * Identify potential issues with users
     */
    private List<String> identifyPotentialIssues(List<User> users) {
        List<String> issues = new ArrayList<>();
        
        // Check for users without names
        long usersWithoutNames = users.stream()
                .filter(user -> (user.getFirstName() == null || user.getFirstName().trim().isEmpty()) ||
                               (user.getLastName() == null || user.getLastName().trim().isEmpty()))
                .count();
        
        if (usersWithoutNames > 0) {
            issues.add(String.format("%d users have incomplete names", usersWithoutNames));
        }
        
        // Check for users with very short names
        long usersWithShortNames = users.stream()
                .filter(user -> calculateNameLength(user) < 4)
                .count();
        
        if (usersWithShortNames > 0) {
            issues.add(String.format("%d users have very short names", usersWithShortNames));
        }
        
        // Check for inactive users
        long inactiveUsers = users.stream()
                .filter(user -> !user.isEnabled())
                .count();
        
        if (inactiveUsers > users.size() * 0.1) { // More than 10% inactive
            issues.add(String.format("High number of inactive users: %d (%.1f%%)", 
                    inactiveUsers, (double) inactiveUsers / users.size() * 100));
        }
        
        return issues;
    }
    
    /**
     * Custom exception for user data processing errors
     */
    public static class UserDataProcessingException extends RuntimeException {
        public UserDataProcessingException(String message, Throwable cause) {
            super(message, cause);
        }
    }
} 