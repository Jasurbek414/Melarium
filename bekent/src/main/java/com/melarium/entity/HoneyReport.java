package com.melarium.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "honey_reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HoneyReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "colony_id", nullable = false)
    private Colony colony;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beekeeper_id", nullable = false)
    private User beekeeper;

    @Column(name = "period_start", nullable = false)
    private LocalDate periodStart;

    @Column(name = "period_end", nullable = false)
    private LocalDate periodEnd;

    @Column(name = "honey_volume_kg", nullable = false, precision = 8, scale = 2)
    private BigDecimal honeyVolumeKg;

    @Column(name = "expenses_usd", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal expensesUsd = BigDecimal.ZERO;

    @Column(name = "honey_price_per_kg", nullable = false, precision = 8, scale = 2)
    private BigDecimal honeyPricePerKg;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_finalized", nullable = false)
    @Builder.Default
    private Boolean isFinalized = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}
