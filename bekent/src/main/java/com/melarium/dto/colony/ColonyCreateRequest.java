package com.melarium.dto.colony;

import com.melarium.enums.ColonyStatus;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;

public record ColonyCreateRequest(
        @NotBlank String name,
        @NotBlank String location,
        String description,

        @NotNull @DecimalMin("1.00") BigDecimal pricePerShare,
        @NotNull @Min(1) @Max(1000) Integer totalShares,
        @NotNull @DecimalMin("0.01") @DecimalMax("999.99") BigDecimal expectedRoiPct,

        LocalDate seasonStart,
        LocalDate seasonEnd,
        String imageUrl,

        // IoT simulation
        BigDecimal temperatureCelsius,
        BigDecimal humidityPct,
        BigDecimal weightKg
) {}
