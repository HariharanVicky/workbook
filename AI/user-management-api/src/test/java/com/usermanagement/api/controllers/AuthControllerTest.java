package com.usermanagement.api.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.usermanagement.api.dto.AuthenticationRequest;
import com.usermanagement.api.dto.UserRegistrationRequest;
import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void whenRegister_thenReturnToken() throws Exception {
        UserRegistrationRequest request = new UserRegistrationRequest(
                "test2@example.com",
                "password123",
                "John",
                "Doe"
        );

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.email").value("test2@example.com"));
    }

    @Test
    void whenLogin_thenReturnToken() throws Exception {
        // First register
        UserRegistrationRequest regRequest = new UserRegistrationRequest(
                "test3@example.com",
                "password123",
                "John",
                "Doe"
        );
        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(regRequest)))
                .andExpect(status().isOk());

        // Then login
        AuthenticationRequest loginRequest = new AuthenticationRequest(
                "test3@example.com",
                "password123"
        );
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.email").value("test3@example.com"));
    }
} 