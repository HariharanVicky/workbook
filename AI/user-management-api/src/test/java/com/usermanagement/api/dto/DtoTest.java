package com.usermanagement.api.dto;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class DtoTest {

    @Test
    void testAuthenticationRequest() {
        AuthenticationRequest request = new AuthenticationRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");

        assertEquals("test@example.com", request.getEmail());
        assertEquals("password123", request.getPassword());
    }

    @Test
    void testUserRegistrationRequest() {
        UserRegistrationRequest request = new UserRegistrationRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");
        request.setFirstName("John");
        request.setLastName("Doe");

        assertEquals("test@example.com", request.getEmail());
        assertEquals("password123", request.getPassword());
        assertEquals("John", request.getFirstName());
        assertEquals("Doe", request.getLastName());
    }

    @Test
    void testAuthenticationResponse() {
        AuthenticationResponse response = new AuthenticationResponse();
        response.setToken("jwt.token.here");
        response.setEmail("test@example.com");

        assertEquals("jwt.token.here", response.getToken());
        assertEquals("test@example.com", response.getEmail());
    }

    @Test
    void testUserRegistrationRequestValidation() {
        UserRegistrationRequest request = new UserRegistrationRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");
        request.setFirstName("John");
        request.setLastName("Doe");

        assertNotNull(request);
        assertTrue(request.getEmail().contains("@"));
        assertTrue(request.getPassword().length() >= 8);
        assertFalse(request.getFirstName().isEmpty());
        assertFalse(request.getLastName().isEmpty());
    }

    @Test
    void testAuthenticationRequestValidation() {
        AuthenticationRequest request = new AuthenticationRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");

        assertNotNull(request);
        assertTrue(request.getEmail().contains("@"));
        assertTrue(request.getPassword().length() >= 8);
    }

    @Test
    void testAuthenticationRequestEqualsAndHashCode() {
        AuthenticationRequest req1 = new AuthenticationRequest("user@example.com", "password");
        AuthenticationRequest req2 = new AuthenticationRequest("user@example.com", "password");
        AuthenticationRequest req3 = new AuthenticationRequest("other@example.com", "otherpass");
        assertEquals(req1, req2);
        assertNotEquals(req1, req3);
        assertEquals(req1.hashCode(), req2.hashCode());
        assertNotEquals(req1.hashCode(), req3.hashCode());
    }

    @Test
    void testAuthenticationRequestToString() {
        AuthenticationRequest req = new AuthenticationRequest("user@example.com", "password");
        String str = req.toString();
        assertTrue(str.contains("user@example.com"));
        assertTrue(str.contains("password"));
    }

    @Test
    void testUserRegistrationRequestEqualsAndHashCode() {
        UserRegistrationRequest req1 = new UserRegistrationRequest("user@example.com", "password", "John", "Doe");
        UserRegistrationRequest req2 = new UserRegistrationRequest("user@example.com", "password", "John", "Doe");
        UserRegistrationRequest req3 = new UserRegistrationRequest("other@example.com", "otherpass", "Jane", "Smith");
        assertEquals(req1, req2);
        assertNotEquals(req1, req3);
        assertEquals(req1.hashCode(), req2.hashCode());
        assertNotEquals(req1.hashCode(), req3.hashCode());
    }

    @Test
    void testUserRegistrationRequestToString() {
        UserRegistrationRequest req = new UserRegistrationRequest("user@example.com", "password", "John", "Doe");
        String str = req.toString();
        assertTrue(str.contains("user@example.com"));
        assertTrue(str.contains("John"));
        assertTrue(str.contains("Doe"));
    }

    @Test
    void testAuthenticationResponseEqualsAndHashCode() {
        AuthenticationResponse res1 = new AuthenticationResponse("token123", "user@example.com", "John", "Doe");
        AuthenticationResponse res2 = new AuthenticationResponse("token123", "user@example.com", "John", "Doe");
        AuthenticationResponse res3 = new AuthenticationResponse("token456", "other@example.com", "Jane", "Smith");
        assertEquals(res1, res2);
        assertNotEquals(res1, res3);
        assertEquals(res1.hashCode(), res2.hashCode());
        assertNotEquals(res1.hashCode(), res3.hashCode());
    }

    @Test
    void testAuthenticationResponseToString() {
        AuthenticationResponse res = new AuthenticationResponse("token123", "user@example.com", "John", "Doe");
        String str = res.toString();
        assertTrue(str.contains("token123"));
        assertTrue(str.contains("user@example.com"));
        assertTrue(str.contains("John"));
        assertTrue(str.contains("Doe"));
    }

    @Test
    void testUserRegistrationRequestValidation_NullFields() {
        UserRegistrationRequest req = new UserRegistrationRequest(null, null, null, null);
        assertNull(req.getEmail());
        assertNull(req.getPassword());
        assertNull(req.getFirstName());
        assertNull(req.getLastName());
    }

    @Test
    void testUserRegistrationRequestValidation_EmptyFields() {
        UserRegistrationRequest req = new UserRegistrationRequest("", "", "", "");
        assertEquals("", req.getEmail());
        assertEquals("", req.getPassword());
        assertEquals("", req.getFirstName());
        assertEquals("", req.getLastName());
    }

    @Test
    void testUserRegistrationRequestValidation_InvalidEmail() {
        UserRegistrationRequest req = new UserRegistrationRequest("invalid-email", "password123", "John", "Doe");
        assertEquals("invalid-email", req.getEmail());
    }

    @Test
    void testAuthenticationResponseBuilder() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("jwt.token.here")
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .build();

        assertEquals("jwt.token.here", response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertEquals("John", response.getFirstName());
        assertEquals("Doe", response.getLastName());
    }

    @Test
    void testAuthenticationResponseNullFields() {
        AuthenticationResponse response = new AuthenticationResponse(null, null, null, null);
        assertNull(response.getToken());
        assertNull(response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseEmptyFields() {
        AuthenticationResponse response = new AuthenticationResponse("", "", "", "");
        assertEquals("", response.getToken());
        assertEquals("", response.getEmail());
        assertEquals("", response.getFirstName());
        assertEquals("", response.getLastName());
    }

    @Test
    void testAuthenticationRequestNullFields() {
        AuthenticationRequest request = new AuthenticationRequest(null, null);
        assertNull(request.getEmail());
        assertNull(request.getPassword());
    }

    @Test
    void testAuthenticationRequestEmptyFields() {
        AuthenticationRequest request = new AuthenticationRequest("", "");
        assertEquals("", request.getEmail());
        assertEquals("", request.getPassword());
    }

    @Test
    void testAuthenticationRequestInvalidEmail() {
        AuthenticationRequest request = new AuthenticationRequest("invalid-email", "password123");
        assertEquals("invalid-email", request.getEmail());
    }

    @Test
    void testAuthenticationResponseEqualsWithNull() {
        AuthenticationResponse res1 = new AuthenticationResponse(null, null, null, null);
        AuthenticationResponse res2 = new AuthenticationResponse(null, null, null, null);
        AuthenticationResponse res3 = new AuthenticationResponse("token", "email", "first", "last");
        
        assertEquals(res1, res2);
        assertNotEquals(res1, res3);
        assertNotEquals(res1, null);
        assertNotEquals(res1, new Object());
    }

    @Test
    void testUserRegistrationRequestEqualsWithNull() {
        UserRegistrationRequest req1 = new UserRegistrationRequest(null, null, null, null);
        UserRegistrationRequest req2 = new UserRegistrationRequest(null, null, null, null);
        UserRegistrationRequest req3 = new UserRegistrationRequest("email", "pass", "first", "last");
        
        assertEquals(req1, req2);
        assertNotEquals(req1, req3);
        assertNotEquals(req1, null);
        assertNotEquals(req1, new Object());
    }

    @Test
    void testAuthenticationRequestEqualsWithNull() {
        AuthenticationRequest req1 = new AuthenticationRequest(null, null);
        AuthenticationRequest req2 = new AuthenticationRequest(null, null);
        AuthenticationRequest req3 = new AuthenticationRequest("email", "pass");
        
        assertEquals(req1, req2);
        assertNotEquals(req1, req3);
        assertNotEquals(req1, null);
        assertNotEquals(req1, new Object());
    }

    @Test
    void testAuthenticationResponseBuilderWithNullValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token(null)
            .email(null)
            .firstName(null)
            .lastName(null)
            .build();

        assertNotNull(response);
        assertNull(response.getToken());
        assertNull(response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithMixedValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("test-token")
            .email(null)
            .firstName("John")
            .lastName(null)
            .build();

        assertNotNull(response);
        assertEquals("test-token", response.getToken());
        assertNull(response.getEmail());
        assertEquals("John", response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithWhitespaceValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("   ")
            .email("  ")
            .firstName("  ")
            .lastName("  ")
            .build();

        assertNotNull(response);
        assertEquals("   ", response.getToken());
        assertEquals("  ", response.getEmail());
        assertEquals("  ", response.getFirstName());
        assertEquals("  ", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithUnicodeValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("🔑")
            .email("test@example.com")
            .firstName("José")
            .lastName("García")
            .build();

        assertNotNull(response);
        assertEquals("🔑", response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertEquals("José", response.getFirstName());
        assertEquals("García", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithEmptyValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("")
            .email("")
            .firstName("")
            .lastName("")
            .build();

        assertEquals("", response.getToken());
        assertEquals("", response.getEmail());
        assertEquals("", response.getFirstName());
        assertEquals("", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithPartialValues() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("jwt.token.here")
            .email("test@example.com")
            .build();

        assertEquals("jwt.token.here", response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseEqualsWithDifferentTypes() {
        AuthenticationResponse response = new AuthenticationResponse("token", "email", "first", "last");
        assertNotEquals(response, "not a response object");
        assertNotEquals(response, null);
    }

    @Test
    void testAuthenticationResponseHashCodeConsistency() {
        AuthenticationResponse response1 = new AuthenticationResponse("token1", "email1", "first1", "last1");
        AuthenticationResponse response2 = new AuthenticationResponse("token1", "email1", "first1", "last1");
        AuthenticationResponse response3 = new AuthenticationResponse("token2", "email2", "first2", "last2");

        assertEquals(response1.hashCode(), response2.hashCode());
        assertNotEquals(response1.hashCode(), response3.hashCode());
    }

    @Test
    void testAuthenticationResponseToStringWithNullValues() {
        AuthenticationResponse response = new AuthenticationResponse(null, null, null, null);
        String str = response.toString();
        assertTrue(str.contains("null"));
    }

    @Test
    void testAuthenticationResponseToStringWithEmptyValues() {
        AuthenticationResponse response = new AuthenticationResponse("", "", "", "");
        String str = response.toString();
        assertTrue(str.contains("token="));
        assertTrue(str.contains("email="));
        assertTrue(str.contains("firstName="));
        assertTrue(str.contains("lastName="));
    }

    @Test
    void testAuthenticationResponseEqualsWithSameInstance() {
        AuthenticationResponse response = new AuthenticationResponse("token", "email", "first", "last");
        assertEquals(response, response);
    }

    @Test
    void testAuthenticationResponseEqualsWithDifferentFields() {
        AuthenticationResponse response1 = new AuthenticationResponse("token1", "email1", "first1", "last1");
        AuthenticationResponse response2 = new AuthenticationResponse("token2", "email1", "first1", "last1");
        AuthenticationResponse response3 = new AuthenticationResponse("token1", "email2", "first1", "last1");
        AuthenticationResponse response4 = new AuthenticationResponse("token1", "email1", "first2", "last1");
        AuthenticationResponse response5 = new AuthenticationResponse("token1", "email1", "first1", "last2");

        assertNotEquals(response1, response2);
        assertNotEquals(response1, response3);
        assertNotEquals(response1, response4);
        assertNotEquals(response1, response5);
    }

    @Test
    void testAuthenticationResponseEqualsWithNullAndNonNullFields() {
        AuthenticationResponse response1 = new AuthenticationResponse(null, "email", "first", "last");
        AuthenticationResponse response2 = new AuthenticationResponse("token", "email", "first", "last");
        assertNotEquals(response1, response2);
    }

    @Test
    void testAuthenticationResponseBuilderWithAllFields() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("test-token")
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .build();

        assertNotNull(response);
        assertEquals("test-token", response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertEquals("John", response.getFirstName());
        assertEquals("Doe", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithOnlyToken() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("test-token")
            .build();

        assertNotNull(response);
        assertEquals("test-token", response.getToken());
        assertNull(response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithOnlyEmail() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .email("test@example.com")
            .build();

        assertNotNull(response);
        assertNull(response.getToken());
        assertEquals("test@example.com", response.getEmail());
        assertNull(response.getFirstName());
        assertNull(response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithOnlyName() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .firstName("John")
            .lastName("Doe")
            .build();

        assertNotNull(response);
        assertNull(response.getToken());
        assertNull(response.getEmail());
        assertEquals("John", response.getFirstName());
        assertEquals("Doe", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithEmptyStrings() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("")
            .email("")
            .firstName("")
            .lastName("")
            .build();

        assertNotNull(response);
        assertEquals("", response.getToken());
        assertEquals("", response.getEmail());
        assertEquals("", response.getFirstName());
        assertEquals("", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithSpecialCharacters() {
        AuthenticationResponse response = AuthenticationResponse.builder()
            .token("!@#$%^&*()")
            .email("test+special@example.com")
            .firstName("John-Doe")
            .lastName("O'Connor")
            .build();

        assertNotNull(response);
        assertEquals("!@#$%^&*()", response.getToken());
        assertEquals("test+special@example.com", response.getEmail());
        assertEquals("John-Doe", response.getFirstName());
        assertEquals("O'Connor", response.getLastName());
    }

    @Test
    void testAuthenticationResponseBuilderWithLongValues() {
        String longToken = "a".repeat(1000);
        String longEmail = "a".repeat(100) + "@example.com";
        String longFirstName = "a".repeat(100);
        String longLastName = "a".repeat(100);

        AuthenticationResponse response = AuthenticationResponse.builder()
            .token(longToken)
            .email(longEmail)
            .firstName(longFirstName)
            .lastName(longLastName)
            .build();

        assertNotNull(response);
        assertEquals(longToken, response.getToken());
        assertEquals(longEmail, response.getEmail());
        assertEquals(longFirstName, response.getFirstName());
        assertEquals(longLastName, response.getLastName());
    }
} 