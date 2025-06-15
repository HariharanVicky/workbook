package com.usermanagement.api.services;

import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.*;

class JwtServiceTest {

    private JwtService jwtService;
    private User testUser;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secretKey", "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970");
        ReflectionTestUtils.setField(jwtService, "jwtExpiration", 86400000L); // 24 hours

        testUser = User.builder()
                .email("test@example.com")
                .password("password123")
                .role(Role.USER)
                .build();
    }

    @Test
    void whenGenerateToken_thenTokenIsValid() {
        String token = jwtService.generateToken(testUser);
        assertNotNull(token);
        assertTrue(jwtService.validateToken(token, testUser.getEmail()));
    }

    @Test
    void whenGenerateToken_thenUsernameIsCorrect() {
        String token = jwtService.generateToken(testUser);
        String extractedUsername = jwtService.extractUsername(token);
        assertEquals(testUser.getEmail(), extractedUsername);
    }

    @Test
    void whenTokenIsExpired_thenValidationFails() {
        org.springframework.test.util.ReflectionTestUtils.setField(jwtService, "jwtExpiration", -1000L); // Set expiration to past
        String token = jwtService.generateToken(testUser);
        boolean isValid = jwtService.validateToken(token);
        assertFalse(isValid);
    }
} 