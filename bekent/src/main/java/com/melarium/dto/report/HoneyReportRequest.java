package com.melarium.dto.report;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;

public record HoneyReportRequest(
        @NotNull Long colonyId,
        @NotNull LocalDate periodStart,
        @NotNull LocalDate periodEnd,
        @NotNull @DecimalMin("0.01") BigDecimal honeyVolumeKg,
        @NotNull @DecimalMin("0.00") BigDecimal expensesUsd,
        @NotNull @DecimalMin("0.01") BigDecimal honeyPricePerKg,
        String notes
) {}
