package com.melarium.dto.auth;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String role,
        Long userId,
        String phone,
        String fullName
) {}
