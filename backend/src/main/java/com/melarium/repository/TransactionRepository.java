package com.melarium.repository;

import com.melarium.entity.Transaction;
import com.melarium.enums.TransactionStatus;
import com.melarium.enums.TransactionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    Page<Transaction> findByUserId(Long userId, Pageable pageable);

    Optional<Transaction> findByProviderTxId(String providerTxId);

    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.type = :type AND t.status = 'SUCCESS'")
    BigDecimal sumByTypeAndSuccess(@Param("type") TransactionType type);

    Page<Transaction> findByStatus(TransactionStatus status, Pageable pageable);
}
