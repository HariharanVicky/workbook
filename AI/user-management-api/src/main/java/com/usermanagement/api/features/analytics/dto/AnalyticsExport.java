package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AnalyticsExport {
    private String format;
    private UserAnalyticsDashboard data;
    private LocalDateTime exportedAt;
} 