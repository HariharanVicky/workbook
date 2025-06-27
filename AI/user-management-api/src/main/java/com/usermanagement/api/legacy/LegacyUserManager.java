package com.usermanagement.api.legacy;

import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import com.usermanagement.api.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * LEGACY CODE - This class violates SOLID principles and needs modernization
 * 
 * Problems:
 * 1. Single Responsibility Principle: Handles multiple responsibilities
 * 2. Open/Closed Principle: Hard to extend without modification
 * 3. Dependency Inversion: Directly depends on concrete implementations
 * 4. Poor error handling
 * 5. Mixed concerns (business logic, data access, validation)
 * 6. No proper logging
 * 7. Hard-coded values
 * 8. No unit testing support
 */
@Component
public class LegacyUserManager {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    // Violation: Multiple responsibilities in one class
    public boolean createUser(String email, String password, String firstName, String lastName, String role) {
        try {
            // Validation logic mixed with business logic
            if (email == null || email.isEmpty()) {
                System.out.println("Email is required");
                return false;
            }
            
            if (password == null || password.length() < 6) {
                System.out.println("Password must be at least 6 characters");
                return false;
            }
            
            // Direct database access mixed with JPA usage
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/user_management", "user", "password");
            PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE email = ?");
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                System.out.println("User already exists");
                return false;
            }
            
            // Business logic mixed with data access
            User user = new User();
            user.setEmail(email);
            user.setPassword(passwordEncoder.encode(password));
            user.setFirstName(firstName);
            user.setLastName(lastName);
            
            // Hard-coded role mapping
            if ("admin".equalsIgnoreCase(role)) {
                user.setRole(Role.ADMIN);
            } else {
                user.setRole(Role.USER);
            }
            
            userRepository.save(user);
            
            // Mixed concerns: Email notification logic
            sendWelcomeEmail(email);
            
            return true;
            
        } catch (Exception e) {
            System.err.println("Error creating user: " + e.getMessage());
            return false;
        }
    }
    
    // Violation: Another responsibility - email sending
    private void sendWelcomeEmail(String email) {
        try {
            // Hard-coded email logic
            System.out.println("Sending welcome email to: " + email);
            // In real legacy code, this might be complex SMTP logic
        } catch (Exception e) {
            System.err.println("Failed to send email: " + e.getMessage());
        }
    }
    
    // Violation: Poor error handling and mixed concerns
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        try {
            users = userRepository.findAll();
            
            // Mixed concerns: Data transformation logic
            for (User user : users) {
                if (user.getPassword() != null) {
                    user.setPassword("***HIDDEN***");
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error getting users: " + e.getMessage());
        }
        return users;
    }
    
    // Violation: Inconsistent error handling and hard-coded values
    public boolean updateUser(Long id, String email, String firstName, String lastName) {
        try {
            User user = userRepository.findById(id).orElse(null);
            if (user == null) {
                System.out.println("User not found");
                return false;
            }
            
            // Hard-coded validation
            if (email != null && email.contains("@")) {
                user.setEmail(email);
            }
            
            if (firstName != null && firstName.length() > 0) {
                user.setFirstName(firstName);
            }
            
            if (lastName != null && lastName.length() > 0) {
                user.setLastName(lastName);
            }
            
            userRepository.save(user);
            return true;
            
        } catch (Exception e) {
            System.err.println("Error updating user: " + e.getMessage());
            return false;
        }
    }
    
    // Violation: No proper logging, poor error handling
    public boolean deleteUser(Long id) {
        try {
            userRepository.deleteById(id);
            return true;
        } catch (Exception e) {
            System.err.println("Error deleting user: " + e.getMessage());
            return false;
        }
    }
} 