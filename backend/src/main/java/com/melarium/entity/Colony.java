package com.melarium.entity;

import com.melarium.enums.ColonyStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "colonies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Colony {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 255)
    private String location;

    @Column(length = 2000)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beekeeper_id", nullable = false)
    private User beekeeper;

    @Column(name = "price_per_share", nullable = false, precision = 12, scale = 2)
    private BigDecimal pricePerShare;

    @Column(name = "total_shares", nullable = false)
    @Builder.Default
    private Integer totalShares = 100;

    @Column(name = "available_shares", nullable = false)
    @Builder.Default
    private Integer availableShares = 100;

    @Column(name = "expected_roi_pct", nullable = false, precision = 5, scale = 2)
    private BigDecimal expectedRoiPct;

    @Column(name = "season_start")
    private LocalDate seasonStart;

    @Column(name = "season_end")
    private LocalDate seasonEnd;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private ColonyStatus status = ColonyStatus.AVAILABLE;

    // IoT simulation (manually entered)
    @Column(name = "temperature_celsius", precision = 4, scale = 1)
    private BigDecimal temperatureCelsius;

    @Column(name = "humidity_pct", precision = 4, scale = 1)
    private BigDecimal humidityPct;

    @Column(name = "weight_kg", precision = 6, scale = 2)
    private BigDecimal weightKg;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private Boolean isVerified = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;
}
