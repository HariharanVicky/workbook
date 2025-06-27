package com.usermanagement.api.features.analytics.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DomainData {
    private String domain;
    private int userCount;
    private double percentage;
} 