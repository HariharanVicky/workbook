package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EngagementMetrics {
    private int dailyActiveUsers;
    private int weeklyActiveUsers;
    private int monthlyActiveUsers;
    private double dailyEngagementRate;
    private double weeklyEngagementRate;
    private double monthlyEngagementRate;
} 