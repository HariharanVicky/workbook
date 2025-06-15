package com.usermanagement.api.services;

import com.usermanagement.api.models.User;
import com.usermanagement.api.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthenticationServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private AuthenticationService authenticationService;

    private User testUser;
    private Authentication authentication;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setPassword("password123");
        testUser.setFirstName("John");
        testUser.setLastName("Doe");

        authentication = new UsernamePasswordAuthenticationToken(
                testUser.getEmail(),
                testUser.getPassword()
        );
    }

    @Test
    void whenAuthenticate_thenReturnJwtToken() {
        // Given
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(java.util.Optional.of(testUser));
        when(jwtService.generateToken(testUser)).thenReturn("jwt-token");

        // When
        String token = authenticationService.authenticate(new com.usermanagement.api.dto.AuthenticationRequest(testUser.getEmail(), testUser.getPassword()));

        // Then
        assertThat(token).isNotNull();
        assertThat(token).isEqualTo("jwt-token");
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtService).generateToken(testUser);
    }

    @Test
    void whenValidateToken_thenReturnTrue() {
        // Given
        String token = "valid-jwt-token";
        when(jwtService.validateToken(token)).thenReturn(true);

        // When
        boolean isValid = authenticationService.validateToken(token);

        // Then
        assertThat(isValid).isTrue();
        verify(jwtService).validateToken(token);
    }

    @Test
    void whenValidateToken_thenReturnFalse() {
        // Given
        String token = "invalid-jwt-token";
        when(jwtService.validateToken(token)).thenReturn(false);

        // When
        boolean isValid = authenticationService.validateToken(token);

        // Then
        assertThat(isValid).isFalse();
        verify(jwtService).validateToken(token);
    }
} 