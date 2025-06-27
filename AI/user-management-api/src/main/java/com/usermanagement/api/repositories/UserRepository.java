package com.usermanagement.api.repositories;

import com.usermanagement.api.models.User;
import com.usermanagement.api.models.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    
    // Analytics methods
    long countByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    long countByCreatedAtBefore(LocalDateTime date);
    long countByCreatedAtAfter(LocalDateTime date);
    long countByRoleAndCreatedAtBetween(Role role, LocalDateTime startDate, LocalDateTime endDate);
    long countByRoleAndCreatedAtBefore(Role role, LocalDateTime date);
} 