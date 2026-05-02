package com.melarium.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VerifyOtpEmailRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 6, max = 6) String otpCode
) {}
