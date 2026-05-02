package com.melarium.controller;

import com.melarium.dto.colony.ColonyCreateRequest;
import com.melarium.dto.colony.ColonyResponse;
import com.melarium.entity.User;
import com.melarium.enums.ColonyStatus;
import com.melarium.service.ColonyService;
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

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/colonies")
@RequiredArgsConstructor
public class ColonyController {

    private final ColonyService colonyService;

    // ── PUBLIC MARKETPLACE ────────────────────────────────────

    @GetMapping
    public ResponseEntity<Page<ColonyResponse>> getMarketplace(
            @RequestParam(required = false) ColonyStatus status,
            @RequestParam(required = false) String location,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "createdAt") String sort
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, sort));
        return ResponseEntity.ok(colonyService.getMarketplace(status, location, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ColonyResponse> getColony(@PathVariable Long id) {
        return ResponseEntity.ok(colonyService.getColonyById(id));
    }

    // ── BEEKEEPER: CREATE COLONY ──────────────────────────────

    @PostMapping
    @PreAuthorize("hasAnyRole('BEEKEEPER', 'ADMIN')")
    public ResponseEntity<ColonyResponse> createColony(
            @Valid @RequestBody ColonyCreateRequest request,
            @AuthenticationPrincipal User currentUser
    ) {
        ColonyResponse response = colonyService.createColony(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // ── BEEKEEPER: UPDATE STATUS ──────────────────────────────

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('BEEKEEPER', 'ADMIN')")
    public ResponseEntity<ColonyResponse> updateStatus(
            @PathVariable Long id,
            @RequestParam ColonyStatus status,
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(colonyService.updateColonyStatus(id, status, currentUser.getId()));
    }

    // ── BEEKEEPER: UPDATE IOT DATA ────────────────────────────

    @PatchMapping("/{id}/iot")
    @PreAuthorize("hasAnyRole('BEEKEEPER', 'ADMIN')")
    public ResponseEntity<ColonyResponse> updateIot(
            @PathVariable Long id,
            @RequestParam(required = false) BigDecimal temperature,
            @RequestParam(required = false) BigDecimal humidity,
            @RequestParam(required = false) BigDecimal weight
    ) {
        return ResponseEntity.ok(colonyService.updateIotData(id, temperature, humidity, weight));
    }
}
