package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Comprehensive user analytics dashboard data
 */
@Data
@Builder
public class UserAnalyticsDashboard {
    
    private OverviewMetrics overviewMetrics;
    private GrowthTrendData growthTrendData;
    private RoleAnalytics roleAnalytics;
    private ActivityMetrics activityMetrics;
    private GeographicDistribution geographicDistribution;
    private EngagementMetrics engagementMetrics;
    private RetentionAnalysis retentionAnalysis;
    private PerformanceMetrics performanceMetrics;
    private LocalDateTime lastUpdated;
} 