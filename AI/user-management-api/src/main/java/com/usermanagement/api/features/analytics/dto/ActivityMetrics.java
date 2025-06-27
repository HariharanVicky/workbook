package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ActivityMetrics {
    private int totalUsers;
    private int activeUsers;
    private int inactiveUsers;
    private int recentlyActiveUsers;
    private double activityRate;
    private double weeklyActivityRate;
} 