package com.melarium.controller;

import com.melarium.dto.report.HoneyReportRequest;
import com.melarium.entity.HoneyReport;
import com.melarium.entity.User;
import com.melarium.service.HoneyReportService;
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
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class HoneyReportController {

    private final HoneyReportService honeyReportService;

    /**
     * Beekeeper: submit honey production report
     * POST /api/reports
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('BEEKEEPER', 'ADMIN')")
    public ResponseEntity<HoneyReport> createReport(
            @Valid @RequestBody HoneyReportRequest request,
            @AuthenticationPrincipal User currentUser
    ) {
        HoneyReport report = honeyReportService.createReport(request, currentUser.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(report);
    }

    /**
     * Beekeeper: finalize report (triggers ROI distribution to investors)
     * POST /api/reports/{id}/finalize
     */
    @PostMapping("/{id}/finalize")
    @PreAuthorize("hasAnyRole('BEEKEEPER', 'ADMIN')")
    public ResponseEntity<HoneyReport> finalizeReport(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser
    ) {
        HoneyReport report = honeyReportService.finalizeReport(id, currentUser.getId());
        return ResponseEntity.ok(report);
    }

    /**
     * Get reports for a colony
     * GET /api/reports/colony/{colonyId}
     */
    @GetMapping("/colony/{colonyId}")
    public ResponseEntity<Page<HoneyReport>> getByColony(
            @PathVariable Long colonyId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return ResponseEntity.ok(honeyReportService.getReportsByColony(colonyId, pageable));
    }
}
