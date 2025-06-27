package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

@Data
@Builder
public class RetentionAnalysis {
    private Map<String, Double> retentionRates;
    private double averageRetentionRate;
    private double churnRate;
} 