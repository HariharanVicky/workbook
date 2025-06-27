package com.usermanagement.api.utils;

import com.usermanagement.api.models.enums.Role;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Result class for user data analysis
 */
@Data
@Builder
public class UserAnalysisResult {
    
    private int totalUsers;
    private int activeUsers;
    private int inactiveUsers;
    private Map<Role, Double> roleDistribution;
    private List<String> topEmailDomains;
    private Map<String, Long> creationByMonth;
    private int recentUsers;
    private double averageNameLength;
    private List<String> potentialIssues;
    private LocalDateTime processingTimestamp;
    
    /**
     * Create an empty analysis result
     */
    public static UserAnalysisResult empty() {
        return UserAnalysisResult.builder()
                .totalUsers(0)
                .activeUsers(0)
                .inactiveUsers(0)
                .recentUsers(0)
                .averageNameLength(0.0)
                .processingTimestamp(LocalDateTime.now())
                .build();
    }
} 