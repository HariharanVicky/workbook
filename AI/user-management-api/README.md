# User Management API

A secure and scalable RESTful API for user management built with Spring Boot, featuring JWT authentication, role-based access control, and comprehensive test coverage.

## Features

- User registration and authentication
- JWT-based security
- User profile management
- Role-based access control
- Comprehensive test coverage (>90%)
- API documentation with Swagger/OpenAPI
- Database migrations with Flyway
- Performance testing with JMeter

## Technology Stack

- Java 17
- Spring Boot 3.x
- PostgreSQL
- JUnit 5 & Mockito
- Spring Security & JWT
- Flyway
- Maven
- JaCoCo
- Checkstyle & PMD
- SpringDoc OpenAPI

## Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- PostgreSQL 12 or higher
- JMeter 5.6 or higher (for performance testing)

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd user-management-api
   ```

2. Configure PostgreSQL:
   - Create a new database named `user_management`
   - Update `application.properties` with your database credentials

3. Build the project:
   ```bash
   mvn clean install
   ```

4. Run the application:
   ```bash
   mvn spring-boot:run
   ```

The application will start on `http://localhost:8080`

## API Documentation

Once the application is running, you can access the API documentation at:
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## Security Configuration

The API uses JWT (JSON Web Token) for authentication. The security configuration includes:

- Password encryption using BCrypt
- JWT token generation and validation
- Role-based access control
- CORS configuration
- Security headers

### Authentication Flow

1. Register a new user: `POST /api/auth/register`
2. Login: `POST /api/auth/login`
3. Use the returned JWT token in subsequent requests:
   ```
   Authorization: Bearer <token>
   ```

## Testing

### Unit Tests
```bash
mvn test
```

### Integration Tests
```bash
mvn verify
```

### Performance Tests
1. Open JMeter
2. Load the test plan: `src/test/jmeter/user-management-api-test-plan.jmx`
3. Run the test plan

### Code Quality
```bash
# Run Checkstyle
mvn checkstyle:check

# Run PMD
mvn pmd:check
```

## Test Coverage

The project maintains >90% test coverage. To view the coverage report:
```bash
mvn verify
```
Then open: `target/site/jacoco/index.html`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login and get JWT token

### User Management
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update current user profile
- `DELETE /api/users/me` - Delete current user account

## Error Handling

The API uses standard HTTP status codes and returns detailed error messages:

```json
{
    "timestamp": "2024-03-14T12:00:00.000+00:00",
    "status": 400,
    "error": "Bad Request",
    "message": "Detailed error message",
    "path": "/api/endpoint"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please contact:
- Email: support@example.com
- Website: https://example.com/support 