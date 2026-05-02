package com.melarium.dto.colony;

import com.melarium.enums.ColonyStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public record ColonyResponse(
        Long id,
        String name,
        String location,
        String description,
        Long beekeeperId,
        String beekeeperName,
        BigDecimal pricePerShare,
        Integer totalShares,
        Integer availableShares,
        BigDecimal expectedRoiPct,
        LocalDate seasonStart,
        LocalDate seasonEnd,
        ColonyStatus status,
        String imageUrl,
        Boolean isVerified,
        // IoT data
        BigDecimal temperatureCelsius,
        BigDecimal humidityPct,
        BigDecimal weightKg,
        OffsetDateTime createdAt
) {}
