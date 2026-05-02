package com.melarium.dto.auth;

public record OtpResponse(
        String phone,
        String message,
        String otpCode   // only in simulate mode
) {}
