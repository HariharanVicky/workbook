package com.usermanagement.api.patterns.factory;

import lombok.Data;

import java.sql.Connection;
import java.time.LocalDateTime;

/**
 * Factory Pattern: Database Connection
 * Represents a database connection with metadata
 */
@Data
public class DatabaseConnection {
    private final Connection connection;
    private final DatabaseType type;
    private final String url;
    private final LocalDateTime createdAt;
    private boolean isActive;
    
    public DatabaseConnection(Connection connection, DatabaseType type, String url) {
        this.connection = connection;
        this.type = type;
        this.url = url;
        this.createdAt = LocalDateTime.now();
        this.isActive = true;
    }
    
    public enum DatabaseType {
        POSTGRESQL,
        MYSQL,
        H2,
        ORACLE
    }
    
    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                this.isActive = false;
            }
        } catch (Exception e) {
            // Log error but don't throw
        }
    }
} 