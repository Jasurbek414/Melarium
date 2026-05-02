package com.melarium.dto.investment;

import com.melarium.enums.HoneyChoice;
import com.melarium.enums.InvestmentStatus;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record InvestmentResponse(
        Long id,
        Long colonyId,
        String colonyName,
        String colonyLocation,
        Integer sharesCount,
        BigDecimal sharePriceAtPurchase,
        BigDecimal totalInvested,
        BigDecimal expectedRoi,
        BigDecimal actualReturn,
        InvestmentStatus status,
        HoneyChoice honeyChoice,
        OffsetDateTime createdAt
) {}
