package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GeographicDistribution {
    private List<DomainData> topDomains;
    private int totalDomains;
    private String mostCommonDomain;
} 