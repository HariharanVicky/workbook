package com.usermanagement.api.modern;

import com.usermanagement.api.exceptions.EmailAlreadyExistsException;
import com.usermanagement.api.exceptions.UserNotFoundException;
import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import com.usermanagement.api.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Modernized User Service
 * Follows SOLID principles:
 * - Single Responsibility: Only handles user business logic
 * - Open/Closed: Easy to extend without modification
 * - Liskov Substitution: Uses interfaces
 * - Interface Segregation: Uses specific interfaces
 * - Dependency Inversion: Depends on abstractions
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ModernUserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserValidationService validationService;
    private final NotificationService notificationService;
    
    /**
     * Create a new user with proper validation and error handling
     * @param user User to create
     * @return Created user
     */
    @Transactional
    public User createUser(User user) {
        log.info("Creating new user with email: {}", user.getEmail());
        
        // Validate input
        validateUserForCreation(user);
        
        // Check if user already exists
        if (userRepository.existsByEmail(user.getEmail())) {
            log.warn("Attempted to create user with existing email: {}", user.getEmail());
            throw new EmailAlreadyExistsException("Email already exists: " + user.getEmail());
        }
        
        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        // Set default role if not specified
        if (user.getRole() == null) {
            user.setRole(Role.USER);
        }
        
        // Save user
        User savedUser = userRepository.save(user);
        
        // Send welcome notification
        try {
            notificationService.sendWelcomeEmail(savedUser.getEmail(), savedUser.getFirstName());
        } catch (Exception e) {
            log.error("Failed to send welcome email, but user was created successfully", e);
            // Don't fail the user creation if notification fails
        }
        
        log.info("Successfully created user with ID: {}", savedUser.getId());
        return savedUser;
    }
    
    /**
     * Find user by email with proper error handling
     * @param email Email to search for
     * @return User if found
     */
    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        log.debug("Finding user by email: {}", email);
        
        UserValidationService.ValidationResult validation = validationService.validateEmail(email);
        if (!validation.isValid()) {
            throw new IllegalArgumentException(validation.getErrorMessage());
        }
        
        return userRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("User not found with email: {}", email);
                    return new UserNotFoundException("User not found with email: " + email);
                });
    }
    
    /**
     * Update user with proper validation
     * @param id User ID
     * @param userDetails Updated user details
     * @return Updated user
     */
    @Transactional
    public User updateUser(Long id, User userDetails) {
        log.info("Updating user with ID: {}", id);
        
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("User not found with ID: {}", id);
                    return new UserNotFoundException("User not found with id: " + id);
                });
        
        // Validate email if provided
        if (userDetails.getEmail() != null && !userDetails.getEmail().equals(existingUser.getEmail())) {
            UserValidationService.ValidationResult validation = validationService.validateEmail(userDetails.getEmail());
            if (!validation.isValid()) {
                throw new IllegalArgumentException(validation.getErrorMessage());
            }
            
            // Check if new email already exists
            if (userRepository.existsByEmail(userDetails.getEmail())) {
                throw new EmailAlreadyExistsException("Email already exists: " + userDetails.getEmail());
            }
            
            existingUser.setEmail(userDetails.getEmail());
        }
        
        // Update other fields
        if (userDetails.getFirstName() != null) {
            UserValidationService.ValidationResult validation = validationService.validateName(userDetails.getFirstName());
            if (!validation.isValid()) {
                throw new IllegalArgumentException(validation.getErrorMessage());
            }
            existingUser.setFirstName(userDetails.getFirstName());
        }
        
        if (userDetails.getLastName() != null) {
            UserValidationService.ValidationResult validation = validationService.validateName(userDetails.getLastName());
            if (!validation.isValid()) {
                throw new IllegalArgumentException(validation.getErrorMessage());
            }
            existingUser.setLastName(userDetails.getLastName());
        }
        
        // Update password if provided
        if (userDetails.getPassword() != null && !userDetails.getPassword().isEmpty()) {
            UserValidationService.ValidationResult validation = validationService.validatePassword(userDetails.getPassword());
            if (!validation.isValid()) {
                throw new IllegalArgumentException(validation.getErrorMessage());
            }
            existingUser.setPassword(passwordEncoder.encode(userDetails.getPassword()));
            
            // Send password change notification
            try {
                notificationService.sendPasswordChangeNotification(existingUser.getEmail());
            } catch (Exception e) {
                log.error("Failed to send password change notification", e);
                // Don't fail the update if notification fails
            }
        }
        
        User updatedUser = userRepository.save(existingUser);
        log.info("Successfully updated user with ID: {}", updatedUser.getId());
        return updatedUser;
    }
    
    /**
     * Delete user with proper error handling
     * @param id User ID to delete
     */
    @Transactional
    public void deleteUser(Long id) {
        log.info("Deleting user with ID: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("User not found with ID: {}", id);
                    return new UserNotFoundException("User not found with id: " + id);
                });
        
        userRepository.delete(user);
        log.info("Successfully deleted user with ID: {}", id);
    }
    
    /**
     * Get all users with sensitive data removed
     * @return List of users without passwords
     */
    @Transactional(readOnly = true)
    public List<User> getAllUsers() {
        log.debug("Retrieving all users");
        
        return userRepository.findAll().stream()
                .map(this::removeSensitiveData)
                .collect(Collectors.toList());
    }
    
    /**
     * Remove sensitive data from user object
     * @param user User to sanitize
     * @return Sanitized user
     */
    private User removeSensitiveData(User user) {
        user.setPassword(null);
        return user;
    }
    
    /**
     * Validate user data for creation
     * @param user User to validate
     */
    private void validateUserForCreation(User user) {
        UserValidationService.ValidationResult emailValidation = validationService.validateEmail(user.getEmail());
        if (!emailValidation.isValid()) {
            throw new IllegalArgumentException(emailValidation.getErrorMessage());
        }
        
        UserValidationService.ValidationResult passwordValidation = validationService.validatePassword(user.getPassword());
        if (!passwordValidation.isValid()) {
            throw new IllegalArgumentException(passwordValidation.getErrorMessage());
        }
        
        UserValidationService.ValidationResult firstNameValidation = validationService.validateName(user.getFirstName());
        if (!firstNameValidation.isValid()) {
            throw new IllegalArgumentException(firstNameValidation.getErrorMessage());
        }
        
        UserValidationService.ValidationResult lastNameValidation = validationService.validateName(user.getLastName());
        if (!lastNameValidation.isValid()) {
            throw new IllegalArgumentException(lastNameValidation.getErrorMessage());
        }
    }
} 