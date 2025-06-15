package com.usermanagement.api.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.usermanagement.api.dto.AuthenticationRequest;
import com.usermanagement.api.dto.UserRegistrationRequest;
import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String authToken;
    private Long userId;

    @BeforeEach
    void setUp() throws Exception {
        // Register a user
        UserRegistrationRequest regRequest = new UserRegistrationRequest(
                "test@example.com",
                "password123",
                "John",
                "Doe"
        );
        String response = mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        // Extract token from response
        authToken = objectMapper.readTree(response).get("token").asText();
    }

    @Test
    void whenGetCurrentUser_thenReturnUser() throws Exception {
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + authToken)
                        .param("email", "test@example.com"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.firstName").value("John"))
                .andExpect(jsonPath("$.lastName").value("Doe"));
    }

    @Test
    void whenGetCurrentUserWithInvalidEmail_thenReturnNotFound() throws Exception {
        mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + authToken)
                        .param("email", "nonexistent@example.com"))
                .andExpect(status().isNotFound());
    }

    @Test
    void whenUpdateUser_thenReturnUpdatedUser() throws Exception {
        // First get the user ID
        String response = mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + authToken)
                        .param("email", "test@example.com"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        userId = objectMapper.readTree(response).get("id").asLong();

        // Update the user
        UserRegistrationRequest updateRequest = new UserRegistrationRequest(
                "test@example.com",
                "newpassword123",
                "Jane",
                "Smith"
        );
        mockMvc.perform(put("/api/users/" + userId)
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("Jane"))
                .andExpect(jsonPath("$.lastName").value("Smith"));
    }

    @Test
    void whenUpdateUserWithInvalidData_thenReturnBadRequest() throws Exception {
        UserRegistrationRequest updateRequest = new UserRegistrationRequest(
                "invalid-email",
                "short",
                "",
                ""
        );
        mockMvc.perform(put("/api/users/1")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void whenDeleteUser_thenReturnOk() throws Exception {
        // First get the user ID
        String response = mockMvc.perform(get("/api/users/me")
                        .header("Authorization", "Bearer " + authToken)
                        .param("email", "test@example.com"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        userId = objectMapper.readTree(response).get("id").asLong();

        // Delete the user
        mockMvc.perform(delete("/api/users/" + userId)
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isOk());

        // Try to get the user with a new registration
        UserRegistrationRequest newUser = new UserRegistrationRequest(
                "test@example.com",
                "password123",
                "John",
                "Doe"
        );
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newUser)))
                .andExpect(status().isOk());
    }

    @Test
    void whenDeleteNonExistentUser_thenReturnNotFound() throws Exception {
        mockMvc.perform(delete("/api/users/999")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().isNotFound());
    }
} 