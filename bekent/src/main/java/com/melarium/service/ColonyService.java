package com.melarium.service;

import com.melarium.dto.colony.ColonyCreateRequest;
import com.melarium.dto.colony.ColonyResponse;
import com.melarium.entity.Colony;
import com.melarium.entity.User;
import com.melarium.enums.ColonyStatus;
import com.melarium.repository.ColonyRepository;
import com.melarium.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class ColonyService {

    private final ColonyRepository colonyRepository;
    private final UserRepository userRepository;

    // ── MARKETPLACE ───────────────────────────────────────────
    public Page<ColonyResponse> getMarketplace(ColonyStatus status, String location, Pageable pageable) {
        String statusStr = status != null ? status.name() : null;
        return colonyRepository.searchMarketplace(statusStr, location, pageable)
                .map(this::toResponse);
    }

    public ColonyResponse getColonyById(Long id) {
        Colony colony = colonyRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));
        return toResponse(colony);
    }

    // ── BEEKEEPER OPERATIONS ──────────────────────────────────
    @Transactional
    public ColonyResponse createColony(ColonyCreateRequest req, Long beekeeperId) {
        User beekeeper = userRepository.findById(beekeeperId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Beekeeper not found"));

        Colony colony = Colony.builder()
                .name(req.name())
                .location(req.location())
                .description(req.description())
                .beekeeper(beekeeper)
                .pricePerShare(req.pricePerShare())
                .totalShares(req.totalShares())
                .availableShares(req.totalShares())
                .expectedRoiPct(req.expectedRoiPct())
                .seasonStart(req.seasonStart())
                .seasonEnd(req.seasonEnd())
                .imageUrl(req.imageUrl())
                .temperatureCelsius(req.temperatureCelsius())
                .humidityPct(req.humidityPct())
                .weightKg(req.weightKg())
                .status(ColonyStatus.AVAILABLE)
                .isVerified(false)
                .build();

        return toResponse(colonyRepository.save(colony));
    }

    @Transactional
    public ColonyResponse updateColonyStatus(Long colonyId, ColonyStatus newStatus, Long requesterId) {
        Colony colony = colonyRepository.findById(colonyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));

        // Only colony's beekeeper or admin can update
        colony.setStatus(newStatus);
        return toResponse(colonyRepository.save(colony));
    }

    @Transactional
    public ColonyResponse updateIotData(Long colonyId, java.math.BigDecimal temp,
                                        java.math.BigDecimal humidity,
                                        java.math.BigDecimal weight) {
        Colony colony = colonyRepository.findById(colonyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));
        colony.setTemperatureCelsius(temp);
        colony.setHumidityPct(humidity);
        colony.setWeightKg(weight);
        return toResponse(colonyRepository.save(colony));
    }

    // ── ADMIN ─────────────────────────────────────────────────
    @Transactional
    public ColonyResponse verifyColony(Long colonyId) {
        Colony colony = colonyRepository.findById(colonyId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));
        colony.setIsVerified(true);
        colony.setStatus(ColonyStatus.AVAILABLE);
        return toResponse(colonyRepository.save(colony));
    }

    public Page<ColonyResponse> getAllColonies(Pageable pageable) {
        return colonyRepository.findAll(pageable).map(this::toResponse);
    }

    // ── MAPPER ────────────────────────────────────────────────
    public ColonyResponse toResponse(Colony colony) {
        return new ColonyResponse(
                colony.getId(),
                colony.getName(),
                colony.getLocation(),
                colony.getDescription(),
                colony.getBeekeeper().getId(),
                colony.getBeekeeper().getFullName(),
                colony.getPricePerShare(),
                colony.getTotalShares(),
                colony.getAvailableShares(),
                colony.getExpectedRoiPct(),
                colony.getSeasonStart(),
                colony.getSeasonEnd(),
                colony.getStatus(),
                colony.getImageUrl(),
                colony.getIsVerified(),
                colony.getTemperatureCelsius(),
                colony.getHumidityPct(),
                colony.getWeightKg(),
                colony.getCreatedAt()
        );
    }
}
