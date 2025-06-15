package com.usermanagement.api.services;

import com.usermanagement.api.exceptions.EmailAlreadyExistsException;
import com.usermanagement.api.exceptions.UserNotFoundException;
import com.usermanagement.api.models.User;
import com.usermanagement.api.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@example.com");
        testUser.setPassword("password123");
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
    }

    @Test
    void whenRegisterUser_thenUserIsSaved() {
        // Given
        when(userRepository.existsByEmail(testUser.getEmail())).thenReturn(false);
        when(passwordEncoder.encode(testUser.getPassword())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User registeredUser = userService.registerUser(testUser);

        // Then
        assertThat(registeredUser).isNotNull();
        assertThat(registeredUser.getEmail()).isEqualTo(testUser.getEmail());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void whenRegisterUserWithExistingEmail_thenThrowException() {
        // Given
        when(userRepository.existsByEmail(testUser.getEmail())).thenReturn(true);

        // When/Then
        assertThatThrownBy(() -> userService.registerUser(testUser))
                .isInstanceOf(EmailAlreadyExistsException.class)
                .hasMessageContaining("Email already exists");
    }

    @Test
    void whenFindByEmail_thenReturnUser() {
        // Given
        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.of(testUser));

        // When
        User foundUser = userService.findByEmail(testUser.getEmail());

        // Then
        assertThat(foundUser).isNotNull();
        assertThat(foundUser.getEmail()).isEqualTo(testUser.getEmail());
    }

    @Test
    void whenFindByEmailWithNonExistentEmail_thenThrowException() {
        // Given
        when(userRepository.findByEmail(testUser.getEmail())).thenReturn(Optional.empty());

        // When/Then
        assertThatThrownBy(() -> userService.findByEmail(testUser.getEmail()))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessageContaining("User not found");
    }

    @Test
    void whenUpdateUser_thenUserIsUpdated() {
        // Given
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User updatedUser = userService.updateUser(testUser.getId(), testUser);

        // Then
        assertThat(updatedUser).isNotNull();
        verify(userRepository).save(any(User.class));
    }

    @Test
    void whenUpdateNonExistentUser_thenThrowException() {
        // Given
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.empty());

        // When/Then
        assertThatThrownBy(() -> userService.updateUser(testUser.getId(), testUser))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessageContaining("User not found");
    }

    @Test
    void whenDeleteUser_thenUserIsDeleted() {
        // Given
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        doNothing().when(userRepository).delete(testUser);

        // When
        userService.deleteUser(testUser.getId());

        // Then
        verify(userRepository).delete(testUser);
    }

    @Test
    void whenDeleteNonExistentUser_thenThrowException() {
        // Given
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.empty());

        // When/Then
        assertThatThrownBy(() -> userService.deleteUser(testUser.getId()))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessageContaining("User not found");
    }

    @Test
    void whenUpdateUserWithNullPassword_thenPasswordNotChanged() {
        testUser.setPassword(null);
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        User userDetails = new User();
        userDetails.setFirstName("Jane");
        userDetails.setLastName("Smith");
        userDetails.setPassword(null);
        User updatedUser = userService.updateUser(testUser.getId(), userDetails);
        assertThat(updatedUser.getPassword()).isNull();
        verify(userRepository).save(any(User.class));
    }

    @Test
    void whenUpdateUserWithEmptyPassword_thenPasswordNotChanged() {
        testUser.setPassword("password123");
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        User userDetails = new User();
        userDetails.setFirstName("Jane");
        userDetails.setLastName("Smith");
        userDetails.setPassword("");
        User updatedUser = userService.updateUser(testUser.getId(), userDetails);
        assertThat(updatedUser.getPassword()).isEqualTo("password123");
        verify(userRepository).save(any(User.class));
    }
} 