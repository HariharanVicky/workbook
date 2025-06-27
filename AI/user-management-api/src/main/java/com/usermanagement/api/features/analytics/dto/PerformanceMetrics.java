package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PerformanceMetrics {
    private int totalUsers;
    private long queryResponseTime;
    private double cacheHitRate;
    private double averageResponseTime;
} 