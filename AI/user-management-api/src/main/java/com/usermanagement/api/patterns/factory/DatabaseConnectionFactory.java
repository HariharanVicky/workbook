package com.usermanagement.api.patterns.factory;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Factory Pattern: Database Connection Factory
 * Creates different types of database connections based on configuration
 */
@Component
@Slf4j
public class DatabaseConnectionFactory {
    
    @Value("${spring.datasource.url}")
    private String databaseUrl;
    
    @Value("${spring.datasource.username}")
    private String username;
    
    @Value("${spring.datasource.password}")
    private String password;
    
    /**
     * Create a database connection based on the specified type
     * @param type The type of database connection to create
     * @return DatabaseConnection object
     * @throws SQLException if connection fails
     */
    public DatabaseConnection createConnection(DatabaseConnection.DatabaseType type) throws SQLException {
        log.info("Creating database connection for type: {}", type);
        
        switch (type) {
            case POSTGRESQL:
                return createPostgreSQLConnection();
            case MYSQL:
                return createMySQLConnection();
            case H2:
                return createH2Connection();
            case ORACLE:
                return createOracleConnection();
            default:
                throw new IllegalArgumentException("Unsupported database type: " + type);
        }
    }
    
    /**
     * Create a PostgreSQL connection
     */
    private DatabaseConnection createPostgreSQLConnection() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
            Connection connection = DriverManager.getConnection(databaseUrl, username, password);
            return new DatabaseConnection(connection, DatabaseConnection.DatabaseType.POSTGRESQL, databaseUrl);
        } catch (ClassNotFoundException e) {
            throw new SQLException("PostgreSQL driver not found", e);
        }
    }
    
    /**
     * Create a MySQL connection
     */
    private DatabaseConnection createMySQLConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String mysqlUrl = databaseUrl.replace("postgresql", "mysql");
            Connection connection = DriverManager.getConnection(mysqlUrl, username, password);
            return new DatabaseConnection(connection, DatabaseConnection.DatabaseType.MYSQL, mysqlUrl);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL driver not found", e);
        }
    }
    
    /**
     * Create an H2 connection
     */
    private DatabaseConnection createH2Connection() throws SQLException {
        try {
            Class.forName("org.h2.Driver");
            String h2Url = "jdbc:h2:mem:testdb";
            Connection connection = DriverManager.getConnection(h2Url, "sa", "");
            return new DatabaseConnection(connection, DatabaseConnection.DatabaseType.H2, h2Url);
        } catch (ClassNotFoundException e) {
            throw new SQLException("H2 driver not found", e);
        }
    }
    
    /**
     * Create an Oracle connection
     */
    private DatabaseConnection createOracleConnection() throws SQLException {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            String oracleUrl = "jdbc:oracle:thin:@localhost:1521:xe";
            Connection connection = DriverManager.getConnection(oracleUrl, username, password);
            return new DatabaseConnection(connection, DatabaseConnection.DatabaseType.ORACLE, oracleUrl);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Oracle driver not found", e);
        }
    }
    
    /**
     * Create a connection using the default database type (PostgreSQL)
     */
    public DatabaseConnection createDefaultConnection() throws SQLException {
        return createConnection(DatabaseConnection.DatabaseType.POSTGRESQL);
    }
} 