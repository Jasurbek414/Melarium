package com.melarium.controller;

import com.melarium.dto.auth.*;
import com.melarium.entity.User;
import com.melarium.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Step 1a: Send OTP to phone (email optional if user has it registered)
     * POST /api/auth/send-otp
     * Body: { "phone": "+998901234567" }
     */
    @PostMapping("/send-otp")
    public ResponseEntity<OtpResponse> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        return ResponseEntity.ok(authService.sendOtp(request.phone()));
    }

    /**
     * Step 1b: Send OTP directly to email
     * POST /api/auth/send-otp-email
     * Body: { "email": "user@example.com" }
     */
    @PostMapping("/send-otp-email")
    public ResponseEntity<OtpResponse> sendOtpByEmail(@Valid @RequestBody SendOtpEmailRequest request) {
        return ResponseEntity.ok(authService.sendOtpByEmail(request.email()));
    }

    /**
     * Step 2a: Verify OTP (phone-based)
     * POST /api/auth/verify-otp
     */
    @PostMapping("/verify-otp")
    public ResponseEntity<AuthResponse> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        return ResponseEntity.ok(authService.verifyOtp(request.phone(), request.otpCode()));
    }

    /**
     * Step 2b: Verify OTP (email-based)
     * POST /api/auth/verify-otp-email
     */
    @PostMapping("/verify-otp-email")
    public ResponseEntity<AuthResponse> verifyOtpByEmail(@Valid @RequestBody VerifyOtpEmailRequest request) {
        return ResponseEntity.ok(authService.verifyOtpByEmail(request.email(), request.otpCode()));
    }

    /**
     * Refresh access token
     * POST /api/auth/refresh
     */
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refreshToken(request.refreshToken()));
    }

    /**
     * Link email to phone account (for existing users)
     * PUT /api/auth/email
     */
    @PutMapping("/email")
    public ResponseEntity<Void> updateEmail(
            @RequestBody UpdateEmailRequest request,
            @AuthenticationPrincipal User currentUser
    ) {
        authService.updateUserEmail(currentUser.getId(), request.email());
        return ResponseEntity.ok().build();
    }
}
