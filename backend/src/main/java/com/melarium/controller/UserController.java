package com.melarium.controller;

import com.melarium.dto.auth.AuthResponse;
import com.melarium.entity.User;
import com.melarium.repository.UserRepository;
import com.melarium.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    /**
     * GET /api/users/me — Returns current user's full profile (for mobile refresh)
     */
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getMe(@AuthenticationPrincipal User user) {
        // Reload from DB to get latest balance
        User fresh = userRepository.findById(user.getId()).orElse(user);
        return ResponseEntity.ok(Map.of(
                "id", fresh.getId(),
                "phone", fresh.getPhone() != null ? fresh.getPhone() : "",
                "fullName", fresh.getFullName() != null ? fresh.getFullName() : "",
                "email", fresh.getEmail() != null ? fresh.getEmail() : "",
                "role", fresh.getRole().name(),
                "isVerified", fresh.getIsVerified(),
                "isActive", fresh.getIsActive(),
                "balance", fresh.getBalance(),
                "createdAt", fresh.getCreatedAt() != null ? fresh.getCreatedAt().toString() : ""
        ));
    }

    /**
     * PUT /api/users/me/profile — Update own profile (name)
     */
    @PutMapping("/me/profile")
    public ResponseEntity<Map<String, Object>> updateProfile(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, String> body
    ) {
        User fresh = userRepository.findById(user.getId()).orElseThrow();
        if (body.containsKey("fullName")) {
            fresh.setFullName(body.get("fullName"));
        }
        userRepository.save(fresh);
        return ResponseEntity.ok(Map.of("message", "Profile updated", "fullName", fresh.getFullName()));
    }
}
