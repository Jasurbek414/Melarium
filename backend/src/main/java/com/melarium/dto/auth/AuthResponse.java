package com.melarium.dto.auth;

import java.math.BigDecimal;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        String role,
        Long userId,
        String phone,
        String fullName,
        Boolean isVerified,
        BigDecimal balance
) {}
