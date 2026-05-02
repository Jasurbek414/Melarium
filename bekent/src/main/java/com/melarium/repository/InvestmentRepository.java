package com.melarium.repository;

import com.melarium.entity.Investment;
import com.melarium.enums.InvestmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface InvestmentRepository extends JpaRepository<Investment, Long> {

    Page<Investment> findByInvestorId(Long investorId, Pageable pageable);

    List<Investment> findByColonyId(Long colonyId);

    List<Investment> findByColonyIdAndStatus(Long colonyId, InvestmentStatus status);

    boolean existsByInvestorIdAndColonyId(Long investorId, Long colonyId);

    @Query("SELECT COALESCE(SUM(i.totalInvested), 0) FROM Investment i WHERE i.investor.id = :investorId AND i.status = 'ACTIVE'")
    BigDecimal sumActiveInvestmentsByInvestor(@Param("investorId") Long investorId);

    @Query("SELECT COALESCE(SUM(i.totalInvested), 0) FROM Investment i")
    BigDecimal sumTotalPlatformInvestments();
}
