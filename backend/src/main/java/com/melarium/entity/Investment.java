package com.melarium.entity;

import com.melarium.enums.HoneyChoice;
import com.melarium.enums.InvestmentStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "investments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Investment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "investor_id", nullable = false)
    private User investor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "colony_id", nullable = false)
    private Colony colony;

    @Column(name = "shares_count", nullable = false)
    private Integer sharesCount;

    @Column(name = "share_price_at_purchase", nullable = false, precision = 12, scale = 2)
    private BigDecimal sharePriceAtPurchase;

    @Column(name = "total_invested", nullable = false, precision = 14, scale = 2)
    private BigDecimal totalInvested;

    @Column(name = "expected_roi", precision = 14, scale = 2)
    private BigDecimal expectedRoi;

    @Column(name = "actual_return", precision = 14, scale = 2)
    @Builder.Default
    private BigDecimal actualReturn = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private InvestmentStatus status = InvestmentStatus.PENDING;

    @Enumerated(EnumType.STRING)
    @Column(name = "honey_choice", length = 30)
    private HoneyChoice honeyChoice;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}
