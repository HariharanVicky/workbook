package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OverviewMetrics {
    private int totalUsers;
    private int activeUsers;
    private int newUsersThisMonth;
    private double growthRateThisMonth;
} 