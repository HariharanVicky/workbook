package com.usermanagement.api.features.analytics.dto;

import com.usermanagement.api.models.enums.Role;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RoleGrowthTrend {
    private Role role;
    private String period;
    private int userCount;
    private double growthRate;
} 