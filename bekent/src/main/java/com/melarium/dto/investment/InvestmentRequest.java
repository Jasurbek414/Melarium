package com.melarium.dto.investment;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record InvestmentRequest(
        @NotNull Long colonyId,
        @NotNull @Min(1) Integer sharesCount
) {}
