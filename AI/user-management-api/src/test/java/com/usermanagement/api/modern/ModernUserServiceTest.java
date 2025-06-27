package com.usermanagement.api.modern;

import com.usermanagement.api.exceptions.EmailAlreadyExistsException;
import com.usermanagement.api.exceptions.UserNotFoundException;
import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import com.usermanagement.api.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ModernUserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private UserValidationService validationService;

    @Mock
    private NotificationService notificationService;

    private ModernUserService modernUserService;

    @BeforeEach
    void setUp() {
        modernUserService = new ModernUserService(
                userRepository, 
                passwordEncoder, 
                validationService, 
                notificationService
        );
    }

    @Test
    void testCreateUser_Success() {
        // Given
        User user = createTestUser();
        User savedUser = createTestUser();
        savedUser.setId(1L);

        when(validationService.validateEmail(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(validationService.validatePassword(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(validationService.validateName(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);

        // When
        User result = modernUserService.createUser(user);

        // Then
        assertNotNull(result);
        assertEquals(1L, result.getId());
        verify(validationService).validateEmail(user.getEmail());
        verify(validationService).validatePassword(user.getPassword());
        verify(validationService, times(2)).validateName(anyString());
        verify(userRepository).existsByEmail(user.getEmail());
        verify(passwordEncoder).encode(user.getPassword());
        verify(userRepository).save(any(User.class));
        verify(notificationService).sendWelcomeEmail(user.getEmail(), user.getFirstName());
    }

    @Test
    void testCreateUser_EmailAlreadyExists() {
        // Given
        User user = createTestUser();
        when(validationService.validateEmail(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(validationService.validatePassword(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(validationService.validateName(anyString())).thenReturn(UserValidationService.ValidationResult.success());
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // When & Then
        assertThrows(EmailAlreadyExistsException.class, () -> modernUserService.createUser(user));
        verify(userRepository).existsByEmail(user.getEmail());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testCreateUser_InvalidEmail() {
        // Given
        User user = createTestUser();
        when(validationService.validateEmail(anyString())).thenReturn(UserValidationService.ValidationResult.failure("Invalid email"));

        // When & Then
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> modernUserService.createUser(user));
        assertEquals("Invalid email", exception.getMessage());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testFindByEmail_Success() {
        // Given
        String email = "test@example.com";
        User user = createTestUser();
        when(validationService.validateEmail(email)).thenReturn(UserValidationService.ValidationResult.success());
        when(userRepository.findByEmail(email)).thenReturn(Optional.of(user));

        // When
        User result = modernUserService.findByEmail(email);

        // Then
        assertNotNull(result);
        assertEquals(email, result.getEmail());
        verify(validationService).validateEmail(email);
        verify(userRepository).findByEmail(email);
    }

    @Test
    void testFindByEmail_UserNotFound() {
        // Given
        String email = "test@example.com";
        when(validationService.validateEmail(email)).thenReturn(UserValidationService.ValidationResult.success());
        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, () -> modernUserService.findByEmail(email));
        verify(validationService).validateEmail(email);
        verify(userRepository).findByEmail(email);
    }

    @Test
    void testUpdateUser_Success() {
        // Given
        Long userId = 1L;
        User existingUser = createTestUser();
        existingUser.setId(userId);
        User updateDetails = createTestUser();
        updateDetails.setFirstName("Updated");
        updateDetails.setLastName("Name");

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(validationService.validateName("Updated")).thenReturn(UserValidationService.ValidationResult.success());
        when(validationService.validateName("Name")).thenReturn(UserValidationService.ValidationResult.success());
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        User result = modernUserService.updateUser(userId, updateDetails);

        // Then
        assertNotNull(result);
        verify(userRepository).findById(userId);
        verify(validationService, times(2)).validateName(anyString());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void testUpdateUser_UserNotFound() {
        // Given
        Long userId = 1L;
        User updateDetails = createTestUser();
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, () -> modernUserService.updateUser(userId, updateDetails));
        verify(userRepository).findById(userId);
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void testDeleteUser_Success() {
        // Given
        Long userId = 1L;
        User user = createTestUser();
        user.setId(userId);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        // When
        modernUserService.deleteUser(userId);

        // Then
        verify(userRepository).findById(userId);
        verify(userRepository).delete(user);
    }

    @Test
    void testDeleteUser_UserNotFound() {
        // Given
        Long userId = 1L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, () -> modernUserService.deleteUser(userId));
        verify(userRepository).findById(userId);
        verify(userRepository, never()).delete(any(User.class));
    }

    @Test
    void testGetAllUsers_Success() {
        // Given
        List<User> users = Arrays.asList(createTestUser(), createTestUser());
        when(userRepository.findAll()).thenReturn(users);

        // When
        List<User> result = modernUserService.getAllUsers();

        // Then
        assertNotNull(result);
        assertEquals(2, result.size());
        result.forEach(user -> assertNull(user.getPassword())); // Passwords should be removed
        verify(userRepository).findAll();
    }

    private User createTestUser() {
        return User.builder()
                .email("test@example.com")
                .password("password123")
                .firstName("John")
                .lastName("Doe")
                .role(Role.USER)
                .build();
    }
} 