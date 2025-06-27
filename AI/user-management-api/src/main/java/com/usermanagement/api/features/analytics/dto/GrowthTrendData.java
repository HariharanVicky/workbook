package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GrowthTrendData {
    private String period;
    private int newUsers;
    private int totalUsers;
    private double growthRate;
} 