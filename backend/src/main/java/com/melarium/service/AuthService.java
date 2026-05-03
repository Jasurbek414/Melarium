package com.melarium.service;

import com.melarium.dto.auth.*;
import com.melarium.entity.User;
import com.melarium.enums.UserRole;
import com.melarium.repository.UserRepository;
import com.melarium.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final EmailService emailService;

    @Value("${melarium.otp.expiry-seconds}")
    private int otpExpirySeconds;

    @Value("${melarium.otp.simulate}")
    private boolean otpSimulate;

    private static final SecureRandom RANDOM = new SecureRandom();

    // ── SEND OTP (Phone-based, email optional) ────────────────
    @Transactional
    public OtpResponse sendOtp(String phone) {
        User user = userRepository.findByPhone(phone).orElseGet(() -> {
            User newUser = User.builder()
                    .phone(phone)
                    .role(UserRole.INVESTOR)
                    .isActive(true)
                    .isVerified(false)
                    .balance(java.math.BigDecimal.ZERO)
                    .build();
            return userRepository.save(newUser);
        });

        String otp = generateOtp();
        user.setOtpCode(otp);
        user.setOtpExpiresAt(OffsetDateTime.now().plusSeconds(otpExpirySeconds));
        userRepository.save(user);

        log.info("[OTP] Phone: {} | Code: {} | Expires: {}s", phone, otp, otpExpirySeconds);

        // Send email only if NOT in simulate mode
        if (!otpSimulate && user.getEmail() != null && !user.getEmail().isBlank()) {
            emailService.sendOtpEmail(user.getEmail(), otp, phone);
            log.info("[OTP] Email sent to: {}", user.getEmail());
        } else {
            log.info("[OTP] Simulate mode or no email. OTP: {}", otp);
        }

        // In simulate mode: return OTP in response (for testing)
        String returnedOtp = otpSimulate ? otp : null;
        return new OtpResponse(phone, "OTP sent successfully", returnedOtp);
    }

    // ── SEND OTP BY EMAIL (direct email auth) ─────────────────
    @Transactional
    public OtpResponse sendOtpByEmail(String email) {
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            // Phone placeholder for email-only users
            User newUser = User.builder()
                    .phone("email:" + email.replaceAll("[^a-zA-Z0-9]", "").substring(0, Math.min(10, email.length())))
                    .email(email)
                    .role(UserRole.INVESTOR)
                    .isActive(true)
                    .build();
            return userRepository.save(newUser);
        });

        String otp = generateOtp();
        user.setOtpCode(otp);
        user.setOtpExpiresAt(OffsetDateTime.now().plusSeconds(otpExpirySeconds));
        userRepository.save(user);

        log.info("[OTP-EMAIL] Sending OTP {} to {}", otp, email);
        emailService.sendOtpEmail(email, otp, user.getPhone());

        // Simulate mode: return code in response
        String returnedOtp = otpSimulate ? otp : null;
        return new OtpResponse(email, "OTP sent to your email", returnedOtp);
    }

    // ── VERIFY OTP (by phone) ─────────────────────────────────
    @Transactional
    public AuthResponse verifyOtp(String phone, String otpCode, String requestedRole) {
        User user = userRepository.findByPhone(phone)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return doVerify(user, otpCode, requestedRole);
    }

    // ── VERIFY OTP (by email) ─────────────────────────────────
    @Transactional
    public AuthResponse verifyOtpByEmail(String email, String otpCode, String requestedRole) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return doVerify(user, otpCode, requestedRole);
    }

    private AuthResponse doVerify(User user, String otpCode, String requestedRole) {
        if (user.getOtpCode() == null || !user.getOtpCode().equals(otpCode)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid OTP code");
        }

        if (user.getOtpExpiresAt() == null || OffsetDateTime.now().isAfter(user.getOtpExpiresAt())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OTP expired. Please request a new one.");
        }

        // Clear OTP after successful verification (one-time use)
        user.setOtpCode(null);
        user.setOtpExpiresAt(null);

        // Update role if requested and current role is default (INVESTOR)
        if (requestedRole != null && !requestedRole.isBlank()) {
            try {
                UserRole role = UserRole.valueOf(requestedRole.toUpperCase());
                // Only allow change if user is still a default INVESTOR and not already something else
                if (user.getRole() == UserRole.INVESTOR) {
                    user.setRole(role);
                }
            } catch (IllegalArgumentException e) {
                log.warn("Invalid role requested: {}", requestedRole);
            }
        }

        userRepository.save(user);

        String accessToken  = jwtUtil.generateAccessToken(user.getId(), user.getPhone(), user.getRole().name());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId(), user.getPhone(), user.getRole().name());

        log.info("[AUTH] User {} logged in. Role: {}", user.getPhone(), user.getRole());

        return new AuthResponse(
                accessToken,
                refreshToken,
                user.getRole().name(),
                user.getId(),
                user.getPhone(),
                user.getFullName(),
                user.getIsVerified(),
                user.getBalance()
        );
    }

    // ── REFRESH TOKEN ─────────────────────────────────────────
    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtUtil.isTokenValid(refreshToken)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid or expired refresh token");
        }

        Long userId = jwtUtil.extractUserId(refreshToken);
        User user   = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        if (!user.getIsActive()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is deactivated");
        }

        String newAccess  = jwtUtil.generateAccessToken(user.getId(), user.getPhone(), user.getRole().name());
        String newRefresh = jwtUtil.generateRefreshToken(user.getId(), user.getPhone(), user.getRole().name());

        return new AuthResponse(newAccess, newRefresh, user.getRole().name(),
                user.getId(), user.getPhone(), user.getFullName(),
                user.getIsVerified(), user.getBalance());
    }

    // ── UPDATE USER EMAIL ─────────────────────────────────────
    @Transactional
    public void updateUserEmail(Long userId, String email) {
        if (userRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already in use");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setEmail(email);
        userRepository.save(user);
    }

    // ── HELPERS ───────────────────────────────────────────────
    private String generateOtp() {
        if (otpSimulate) {
            return "1234";
        }
        return String.valueOf(100000 + RANDOM.nextInt(900000));
    }
}
