package com.melarium.controller;

import com.melarium.dto.colony.ColonyResponse;
import com.melarium.entity.User;
import com.melarium.enums.ColonyStatus;
import com.melarium.enums.UserRole;
import com.melarium.repository.*;
import com.melarium.service.ColonyService;
import com.melarium.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserRepository userRepository;
    private final ColonyRepository colonyRepository;
    private final InvestmentRepository investmentRepository;
    private final TransactionRepository transactionRepository;
    private final HoneyReportRepository honeyReportRepository;
    private final ColonyService colonyService;
    private final NotificationService notificationService;


    // ── DASHBOARD STATS ───────────────────────────────────────

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        long totalUsers = userRepository.count();
        long totalInvestors = userRepository.countByRole(UserRole.INVESTOR);
        long totalBeekeepers = userRepository.countByRole(UserRole.BEEKEEPER);
        long totalColonies = colonyRepository.count();
        long activeColonies = colonyRepository.countByStatus(ColonyStatus.ACTIVE);
        BigDecimal totalInvestments = investmentRepository.sumTotalPlatformInvestments();
        BigDecimal totalHoney = honeyReportRepository.sumTotalHoneyProduced();

        Map<String, Object> stats = Map.of(
                "totalUsers", totalUsers,
                "totalInvestors", totalInvestors,
                "totalBeekeepers", totalBeekeepers,
                "totalColonies", totalColonies,
                "activeColonies", activeColonies,
                "totalInvestmentsUsd", totalInvestments,
                "totalHoneyKg", totalHoney
        );

        return ResponseEntity.ok(stats);
    }

    // ── USERS ─────────────────────────────────────────────────

    @GetMapping("/users")
    public ResponseEntity<Page<User>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(userRepository.findAll(pageable));
    }

    @PatchMapping("/users/{id}/role")
    public ResponseEntity<User> changeUserRole(
            @PathVariable Long id,
            @RequestParam UserRole role
    ) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "User not found"));
        user.setRole(role);
        return ResponseEntity.ok(userRepository.save(user));
    }

    @PatchMapping("/users/{id}/toggle-active")
    public ResponseEntity<User> toggleUserActive(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "User not found"));
        user.setIsActive(!user.getIsActive());
        return ResponseEntity.ok(userRepository.save(user));
    }

    // ── COLONIES ──────────────────────────────────────────────

    @GetMapping("/colonies")
    public ResponseEntity<Page<ColonyResponse>> getAllColonies(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(colonyService.getAllColonies(pageable));
    }

    @PostMapping("/colonies/{id}/verify")
    public ResponseEntity<ColonyResponse> verifyColony(@PathVariable Long id) {
        return ResponseEntity.ok(colonyService.verifyColony(id));
    }

    // ── TRANSACTIONS ──────────────────────────────────────────

    @GetMapping("/transactions")
    public ResponseEntity<org.springframework.data.domain.Page<com.melarium.entity.Transaction>> getAllTransactions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(transactionRepository.findAll(pageable));
    }
}
