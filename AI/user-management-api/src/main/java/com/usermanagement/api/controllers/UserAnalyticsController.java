package com.usermanagement.api.controllers;

import com.usermanagement.api.features.analytics.UserAnalyticsService;
import com.usermanagement.api.features.analytics.dto.AnalyticsExport;
import com.usermanagement.api.features.analytics.dto.UserAnalyticsDashboard;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * User Analytics Controller - AI-Generated Real-World Feature
 * 
 * This controller exposes comprehensive user analytics endpoints including:
 * - Dashboard analytics
 * - Growth trends
 * - Role-based analytics
 * - Activity metrics
 * - Geographic distribution
 * - Engagement metrics
 * - Retention analysis
 * - Performance metrics
 * - Data export functionality
 */
@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
@Slf4j
public class UserAnalyticsController {
    
    private final UserAnalyticsService analyticsService;
    
    /**
     * Get comprehensive analytics dashboard
     * Requires ADMIN role for access
     */
    @GetMapping("/dashboard")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserAnalyticsDashboard> getDashboard() {
        log.info("Retrieving user analytics dashboard");
        
        try {
            UserAnalyticsDashboard dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard);
        } catch (Exception e) {
            log.error("Error retrieving analytics dashboard", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get user growth trends
     * Requires ADMIN role for access
     */
    @GetMapping("/growth-trends")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getGrowthTrends() {
        log.info("Retrieving user growth trends");
        
        try {
            var trends = analyticsService.getGrowthTrends();
            return ResponseEntity.ok(trends);
        } catch (Exception e) {
            log.error("Error retrieving growth trends", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get analytics overview metrics
     * Requires ADMIN role for access
     */
    @GetMapping("/overview")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getOverview() {
        log.info("Retrieving analytics overview");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getOverviewMetrics());
        } catch (Exception e) {
            log.error("Error retrieving analytics overview", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get role-based analytics
     * Requires ADMIN role for access
     */
    @GetMapping("/roles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getRoleAnalytics() {
        log.info("Retrieving role-based analytics");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getRoleAnalytics());
        } catch (Exception e) {
            log.error("Error retrieving role analytics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get activity metrics
     * Requires ADMIN role for access
     */
    @GetMapping("/activity")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getActivityMetrics() {
        log.info("Retrieving activity metrics");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getActivityMetrics());
        } catch (Exception e) {
            log.error("Error retrieving activity metrics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get geographic distribution
     * Requires ADMIN role for access
     */
    @GetMapping("/geographic")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getGeographicDistribution() {
        log.info("Retrieving geographic distribution");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getGeographicDistribution());
        } catch (Exception e) {
            log.error("Error retrieving geographic distribution", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get engagement metrics
     * Requires ADMIN role for access
     */
    @GetMapping("/engagement")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getEngagementMetrics() {
        log.info("Retrieving engagement metrics");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getEngagementMetrics());
        } catch (Exception e) {
            log.error("Error retrieving engagement metrics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get retention analysis
     * Requires ADMIN role for access
     */
    @GetMapping("/retention")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getRetentionAnalysis() {
        log.info("Retrieving retention analysis");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getRetentionAnalysis());
        } catch (Exception e) {
            log.error("Error retrieving retention analysis", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get performance metrics
     * Requires ADMIN role for access
     */
    @GetMapping("/performance")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getPerformanceMetrics() {
        log.info("Retrieving performance metrics");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            return ResponseEntity.ok(dashboard.getPerformanceMetrics());
        } catch (Exception e) {
            log.error("Error retrieving performance metrics", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Export analytics data
     * Requires ADMIN role for access
     */
    @PostMapping("/export")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> exportAnalytics(@RequestParam String format) {
        log.info("Exporting analytics data in format: {}", format);
        
        try {
            AnalyticsExport export = analyticsService.exportAnalyticsData(format);
            return ResponseEntity.ok(export);
        } catch (Exception e) {
            log.error("Error exporting analytics data", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Get analytics summary for quick overview
     * Requires ADMIN role for access
     */
    @GetMapping("/summary")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getAnalyticsSummary() {
        log.info("Retrieving analytics summary");
        
        try {
            var dashboard = analyticsService.getDashboardAnalytics();
            
            Map<String, Object> summary = Map.of(
                "totalUsers", dashboard.getOverviewMetrics().getTotalUsers(),
                "activeUsers", dashboard.getOverviewMetrics().getActiveUsers(),
                "growthRate", dashboard.getOverviewMetrics().getGrowthRateThisMonth(),
                "lastUpdated", LocalDateTime.now()
            );
            
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            log.error("Error retrieving analytics summary", e);
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * Health check for analytics service
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        return ResponseEntity.ok(Map.of("status", "healthy", "service", "user-analytics"));
    }
} 