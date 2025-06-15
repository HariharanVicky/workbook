package com.usermanagement.api.exceptions;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class ExceptionTest {
    @Test
    void testUserNotFoundException() {
        String msg = "User not found!";
        UserNotFoundException ex = new UserNotFoundException(msg);
        assertEquals(msg, ex.getMessage());
    }

    @Test
    void testEmailAlreadyExistsException() {
        String msg = "Email already exists!";
        EmailAlreadyExistsException ex = new EmailAlreadyExistsException(msg);
        assertEquals(msg, ex.getMessage());
    }

    @Test
    void testHandleUserNotFoundException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        UserNotFoundException ex = new UserNotFoundException("User not found!");
        ResponseEntity<Map<String, Object>> response = handler.handleUserNotFoundException(ex);
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
        assertTrue(response.getBody().get("message").toString().contains("User not found!"));
    }

    @Test
    void testHandleEmailAlreadyExistsException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        EmailAlreadyExistsException ex = new EmailAlreadyExistsException("Email already exists!");
        ResponseEntity<Map<String, Object>> response = handler.handleEmailAlreadyExistsException(ex);
        assertEquals(HttpStatus.CONFLICT, response.getStatusCode());
        assertTrue(response.getBody().get("message").toString().contains("Email already exists!"));
    }

    @Test
    void testHandleGenericException() {
        GlobalExceptionHandler handler = new GlobalExceptionHandler();
        Exception ex = new Exception("Generic error");
        ResponseEntity<Map<String, Object>> response = handler.handleGenericException(ex);
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertTrue(response.getBody().get("message").toString().contains("Generic error"));
    }
} 