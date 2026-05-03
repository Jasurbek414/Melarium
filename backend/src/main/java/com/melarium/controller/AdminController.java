package com.melarium.controller;

import com.melarium.dto.colony.ColonyResponse;
import com.melarium.entity.Colony;
import com.melarium.entity.Transaction;
import com.melarium.entity.User;
import com.melarium.enums.ColonyStatus;
import com.melarium.enums.TransactionStatus;
import com.melarium.enums.TransactionType;
import com.melarium.enums.PaymentProvider;
import com.melarium.enums.UserRole;
import com.melarium.repository.*;
import com.melarium.service.ColonyService;
import com.melarium.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.HashMap;
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

    // Platform settings (in-memory for now, could be a DB table)
    private static BigDecimal investmentCommissionPct = new BigDecimal("8.0");
    private static BigDecimal honeyCommissionPct = new BigDecimal("12.0");
    private static BigDecimal colonyListingFee = new BigDecimal("50000");
    private static BigDecimal minimumInvestment = new BigDecimal("100000");

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
        BigDecimal totalBalance = userRepository.sumTotalBalance();
        long totalTransactions = transactionRepository.count();

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", totalUsers);
        stats.put("totalInvestors", totalInvestors);
        stats.put("totalBeekeepers", totalBeekeepers);
        stats.put("totalColonies", totalColonies);
        stats.put("activeColonies", activeColonies);
        stats.put("totalInvestmentsUsd", totalInvestments != null ? totalInvestments : BigDecimal.ZERO);
        stats.put("totalHoneyKg", totalHoney != null ? totalHoney : BigDecimal.ZERO);
        stats.put("totalBalance", totalBalance != null ? totalBalance : BigDecimal.ZERO);
        stats.put("totalTransactions", totalTransactions);
        stats.put("investmentCommissionPct", investmentCommissionPct);
        stats.put("honeyCommissionPct", honeyCommissionPct);

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

    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return ResponseEntity.ok(user);
    }

    @PatchMapping("/users/{id}/role")
    public ResponseEntity<User> changeUserRole(
            @PathVariable Long id,
            @RequestParam UserRole role
    ) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setRole(role);
        return ResponseEntity.ok(userRepository.save(user));
    }

    @PatchMapping("/users/{id}/toggle-active")
    public ResponseEntity<User> toggleUserActive(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setIsActive(!user.getIsActive());
        return ResponseEntity.ok(userRepository.save(user));
    }

    // ── USER VERIFICATION ─────────────────────────────────────

    @PatchMapping("/users/{id}/verify")
    public ResponseEntity<User> verifyUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setIsVerified(true);
        return ResponseEntity.ok(userRepository.save(user));
    }

    @PatchMapping("/users/{id}/unverify")
    public ResponseEntity<User> unverifyUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        user.setIsVerified(false);
        return ResponseEntity.ok(userRepository.save(user));
    }

    // ── BALANCE MANAGEMENT ────────────────────────────────────

    @PatchMapping("/users/{id}/balance")
    public ResponseEntity<Map<String, Object>> addBalance(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body
    ) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        String description = body.containsKey("description") ? body.get("description").toString() : "Admin tomonidan to'ldirildi";

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Amount must be positive");
        }

        user.setBalance(user.getBalance().add(amount));
        userRepository.save(user);

        // Record transaction
        Transaction tx = Transaction.builder()
                .user(user)
                .amount(amount)
                .type(TransactionType.DEPOSIT)
                .provider(PaymentProvider.MOCK)
                .status(TransactionStatus.COMPLETED)
                .description(description)
                .build();
        transactionRepository.save(tx);

        return ResponseEntity.ok(Map.of(
                "message", "Balance updated",
                "newBalance", user.getBalance(),
                "transactionId", tx.getId()
        ));
    }

    @PatchMapping("/users/{id}/deduct-balance")
    public ResponseEntity<Map<String, Object>> deductBalance(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body
    ) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        BigDecimal amount = new BigDecimal(body.get("amount").toString());
        String description = body.containsKey("description") ? body.get("description").toString() : "Admin tomonidan yechildi";

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Amount must be positive");
        }
        if (user.getBalance().compareTo(amount) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Insufficient balance");
        }

        user.setBalance(user.getBalance().subtract(amount));
        userRepository.save(user);

        Transaction tx = Transaction.builder()
                .user(user)
                .amount(amount)
                .type(TransactionType.WITHDRAWAL)
                .provider(PaymentProvider.MOCK)
                .status(TransactionStatus.COMPLETED)
                .description(description)
                .build();
        transactionRepository.save(tx);

        return ResponseEntity.ok(Map.of(
                "message", "Balance deducted",
                "newBalance", user.getBalance(),
                "transactionId", tx.getId()
        ));
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

    @PostMapping("/colonies/{id}/reject")
    public ResponseEntity<Map<String, String>> rejectColony(@PathVariable Long id) {
        Colony colony = colonyRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));
        colony.setIsVerified(false);
        colony.setStatus(ColonyStatus.DEACTIVATED);
        colonyRepository.save(colony);
        return ResponseEntity.ok(Map.of("message", "Colony rejected"));
    }

    // ── TRANSACTIONS ──────────────────────────────────────────

    @GetMapping("/transactions")
    public ResponseEntity<Page<Transaction>> getAllTransactions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(transactionRepository.findAll(pageable));
    }

    // ── REPORTS ───────────────────────────────────────────────

    @GetMapping("/reports")
    public ResponseEntity<Page<com.melarium.entity.HoneyReport>> getAllReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(honeyReportRepository.findAll(pageable));
    }

    // ── PLATFORM SETTINGS ─────────────────────────────────────

    @GetMapping("/settings")
    public ResponseEntity<Map<String, Object>> getSettings() {
        return ResponseEntity.ok(Map.of(
                "investmentCommissionPct", investmentCommissionPct,
                "honeyCommissionPct", honeyCommissionPct,
                "colonyListingFee", colonyListingFee,
                "minimumInvestment", minimumInvestment
        ));
    }

    @PostMapping("/settings")
    public ResponseEntity<Map<String, Object>> updateSettings(@RequestBody Map<String, Object> body) {
        if (body.containsKey("investmentCommissionPct"))
            investmentCommissionPct = new BigDecimal(body.get("investmentCommissionPct").toString());
        if (body.containsKey("honeyCommissionPct"))
            honeyCommissionPct = new BigDecimal(body.get("honeyCommissionPct").toString());
        if (body.containsKey("colonyListingFee"))
            colonyListingFee = new BigDecimal(body.get("colonyListingFee").toString());
        if (body.containsKey("minimumInvestment"))
            minimumInvestment = new BigDecimal(body.get("minimumInvestment").toString());

        return ResponseEntity.ok(Map.of(
                "message", "Settings updated",
                "investmentCommissionPct", investmentCommissionPct,
                "honeyCommissionPct", honeyCommissionPct,
                "colonyListingFee", colonyListingFee,
                "minimumInvestment", minimumInvestment
        ));
    }

    // ── STATIC ACCESSORS for services ──────────────────────────
    public static BigDecimal getInvestmentCommissionPct() { return investmentCommissionPct; }
    public static BigDecimal getHoneyCommissionPct() { return honeyCommissionPct; }
    public static BigDecimal getColonyListingFee() { return colonyListingFee; }
    public static BigDecimal getMinimumInvestment() { return minimumInvestment; }
}
