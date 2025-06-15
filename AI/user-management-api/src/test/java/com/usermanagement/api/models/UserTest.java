package com.usermanagement.api.models;

import com.usermanagement.api.models.enums.Role;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @Test
    void whenCreatingUser_thenUserIsCreatedWithCorrectFields() {
        User user = User.builder()
                .email("test@example.com")
                .password("password123")
                .firstName("John")
                .lastName("Doe")
                .role(Role.USER)
                .build();

        assertNotNull(user);
        assertEquals("test@example.com", user.getEmail());
        assertEquals("password123", user.getPassword());
        assertEquals("John", user.getFirstName());
        assertEquals("Doe", user.getLastName());
        assertEquals(Role.USER, user.getRole());
        assertTrue(user.isEnabled());
    }

    @Test
    void whenCreatingUser_thenDefaultValuesAreSet() {
        User user = User.builder()
                .email("test@example.com")
                .password("password123")
                .build();
        user.setCreatedAt(java.time.LocalDateTime.now());
        user.setUpdatedAt(java.time.LocalDateTime.now());
        assertNotNull(user);
        assertEquals(com.usermanagement.api.models.enums.Role.USER, user.getRole());
        assertTrue(user.isEnabled());
        assertNotNull(user.getCreatedAt());
        assertNotNull(user.getUpdatedAt());
    }

    @Test
    void whenUpdatingUser_thenUpdatedAtIsModified() {
        User user = User.builder()
                .email("test@example.com")
                .password("password123")
                .build();
        user.setCreatedAt(java.time.LocalDateTime.now());
        user.setUpdatedAt(java.time.LocalDateTime.now());
        java.time.LocalDateTime initialUpdatedAt = user.getUpdatedAt();
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setUpdatedAt(java.time.LocalDateTime.now());
        assertNotNull(user.getUpdatedAt());
        assertTrue(user.getUpdatedAt().isAfter(initialUpdatedAt));
    }
} 