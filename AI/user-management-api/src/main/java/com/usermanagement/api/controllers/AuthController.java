package com.usermanagement.api.controllers;

import com.usermanagement.api.dto.AuthenticationRequest;
import com.usermanagement.api.dto.AuthenticationResponse;
import com.usermanagement.api.dto.UserRegistrationRequest;
import com.usermanagement.api.models.User;
import com.usermanagement.api.services.AuthenticationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationService authenticationService;

    @PostMapping("/register")
    public ResponseEntity<AuthenticationResponse> register(
            @Valid @RequestBody UserRegistrationRequest request) {
        User registeredUser = authenticationService.register(request);
        String token = authenticationService.authenticate(new AuthenticationRequest(
                request.getEmail(),
                request.getPassword()
        ));

        return ResponseEntity.ok(AuthenticationResponse.builder()
                .token(token)
                .email(registeredUser.getEmail())
                .firstName(registeredUser.getFirstName())
                .lastName(registeredUser.getLastName())
                .build());
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticate(
            @Valid @RequestBody AuthenticationRequest request) {
        try {
            String token = authenticationService.authenticate(request);
            User user = authenticationService.getUserByEmail(request.getEmail());

            return ResponseEntity.ok(AuthenticationResponse.builder()
                    .token(token)
                    .email(user.getEmail())
                    .firstName(user.getFirstName())
                    .lastName(user.getLastName())
                    .build());
        } catch (BadCredentialsException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Invalid credentials");
        }
    }
} 