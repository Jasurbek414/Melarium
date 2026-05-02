package com.melarium.controller;

import com.melarium.dto.investment.InvestmentRequest;
import com.melarium.dto.investment.InvestmentResponse;
import com.melarium.entity.User;
import com.melarium.enums.HoneyChoice;
import com.melarium.service.InvestmentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/investments")
@RequiredArgsConstructor
public class InvestmentController {

    private final InvestmentService investmentService;

    /**
     * Buy shares in a colony
     * POST /api/investments
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('INVESTOR', 'ADMIN')")
    public ResponseEntity<InvestmentResponse> buyShares(
            @Valid @RequestBody InvestmentRequest request,
            @AuthenticationPrincipal User currentUser
    ) {
        InvestmentResponse response = investmentService.buyShares(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Get my portfolio
     * GET /api/investments/my
     */
    @GetMapping("/my")
    @PreAuthorize("hasAnyRole('INVESTOR', 'ADMIN')")
    public ResponseEntity<Page<InvestmentResponse>> getMyInvestments(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(investmentService.getMyInvestments(currentUser.getId(), pageable));
    }

    /**
     * Get single investment detail
     * GET /api/investments/{id}
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('INVESTOR', 'ADMIN')")
    public ResponseEntity<InvestmentResponse> getById(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(investmentService.getById(id, currentUser.getId()));
    }

    /**
     * Set honey delivery preference after harvest
     * PATCH /api/investments/{id}/honey-choice
     */
    @PatchMapping("/{id}/honey-choice")
    @PreAuthorize("hasRole('INVESTOR')")
    public ResponseEntity<InvestmentResponse> setHoneyChoice(
            @PathVariable Long id,
            @RequestParam HoneyChoice choice,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(investmentService.setHoneyChoice(id, choice, currentUser.getId()));
    }
}
