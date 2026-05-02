package com.melarium.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VerifyOtpRequest(
        @NotBlank(message = "Phone is required")
        @Pattern(regexp = "^\\+998[0-9]{9}$", message = "Phone must be in format +998XXXXXXXXX")
        String phone,

        @NotBlank(message = "OTP code is required")
        @Size(min = 6, max = 6, message = "OTP must be exactly 6 digits")
        String otpCode
) {}
