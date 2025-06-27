package com.usermanagement.api.patterns.strategy;

import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import com.usermanagement.api.services.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthenticationStrategyTest {

    @Mock
    private UserService userService;

    @Mock
    private PasswordEncoder passwordEncoder;

    private EmailPasswordAuthStrategy emailPasswordAuthStrategy;
    private ApiKeyAuthStrategy apiKeyAuthStrategy;

    @BeforeEach
    void setUp() {
        emailPasswordAuthStrategy = new EmailPasswordAuthStrategy(userService, passwordEncoder);
        apiKeyAuthStrategy = new ApiKeyAuthStrategy(null); // Repository not needed for this test
    }

    @Test
    void testEmailPasswordAuthStrategy_ValidCredentials() {
        // Given
        User mockUser = User.builder()
                .id(1L)
                .email("test@example.com")
                .password("encodedPassword")
                .firstName("John")
                .lastName("Doe")
                .role(Role.USER)
                .build();

        when(userService.findByEmail("test@example.com")).thenReturn(mockUser);
        when(passwordEncoder.matches("password123", "encodedPassword")).thenReturn(true);

        // When
        User result = emailPasswordAuthStrategy.authenticate("test@example.com:password123");

        // Then
        assertNotNull(result);
        assertEquals("test@example.com", result.getEmail());
        assertEquals("EMAIL_PASSWORD", emailPasswordAuthStrategy.getAuthenticationMethod());
        assertTrue(emailPasswordAuthStrategy.isEnabled());
    }

    @Test
    void testEmailPasswordAuthStrategy_InvalidCredentials() {
        // Given
        when(userService.findByEmail("test@example.com")).thenReturn(null);

        // When
        User result = emailPasswordAuthStrategy.authenticate("test@example.com:wrongpassword");

        // Then
        assertNull(result);
    }

    @Test
    void testEmailPasswordAuthStrategy_InvalidFormat() {
        // When
        User result = emailPasswordAuthStrategy.authenticate("invalid-format");

        // Then
        assertNull(result);
    }

    @Test
    void testApiKeyAuthStrategy_ValidApiKey() {
        // When
        User result = apiKeyAuthStrategy.authenticate("apikey:sk_12345678901234567890123456789012");

        // Then
        assertNotNull(result);
        assertEquals("API_KEY", apiKeyAuthStrategy.getAuthenticationMethod());
        assertTrue(apiKeyAuthStrategy.isEnabled());
    }

    @Test
    void testApiKeyAuthStrategy_InvalidApiKey() {
        // When
        User result = apiKeyAuthStrategy.authenticate("apikey:invalid_key");

        // Then
        assertNull(result);
    }

    @Test
    void testApiKeyAuthStrategy_WrongFormat() {
        // When
        User result = apiKeyAuthStrategy.authenticate("wrong:format");

        // Then
        assertNull(result);
    }
} 