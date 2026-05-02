package com.melarium.repository;

import com.melarium.entity.HoneyReport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface HoneyReportRepository extends JpaRepository<HoneyReport, Long> {

    Page<HoneyReport> findByColonyId(Long colonyId, Pageable pageable);

    List<HoneyReport> findByColonyIdAndIsFinalized(Long colonyId, Boolean isFinalized);

    @Query("SELECT COALESCE(SUM(h.honeyVolumeKg), 0) FROM HoneyReport h WHERE h.colony.id = :colonyId AND h.isFinalized = true")
    BigDecimal sumFinalizedHoneyByColony(@Param("colonyId") Long colonyId);

    @Query("SELECT COALESCE(SUM(h.honeyVolumeKg), 0) FROM HoneyReport h WHERE h.isFinalized = true")
    BigDecimal sumTotalHoneyProduced();
}
