package com.usermanagement.api.features.analytics.dto;

import com.usermanagement.api.models.enums.Role;
import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class RoleAnalytics {
    private Map<Role, Double> roleDistribution;
    private int totalRoles;
    private Role mostCommonRole;
    private List<RoleGrowthTrend> roleGrowthTrends;
} 