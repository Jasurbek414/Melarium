package com.melarium.repository;

import com.melarium.entity.Colony;
import com.melarium.enums.ColonyStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ColonyRepository extends JpaRepository<Colony, Long> {

    Page<Colony> findByStatus(ColonyStatus status, Pageable pageable);

    Page<Colony> findByBeekeeperIdAndStatus(Long beekeeperId, ColonyStatus status, Pageable pageable);

    List<Colony> findByBeekeeperId(Long beekeeperId);

    Page<Colony> findByIsVerifiedTrue(Pageable pageable);

    @Query(value = "SELECT * FROM colonies c WHERE " +
           "(:status IS NULL OR c.status::text = :status) AND " +
           "(:location IS NULL OR c.location ILIKE CONCAT('%', :location, '%')) AND " +
           "c.is_verified = true ORDER BY c.created_at DESC",
           countQuery = "SELECT count(*) FROM colonies c WHERE " +
           "(:status IS NULL OR c.status::text = :status) AND " +
           "(:location IS NULL OR c.location ILIKE CONCAT('%', :location, '%')) AND " +
           "c.is_verified = true",
           nativeQuery = true)
    Page<Colony> searchMarketplace(@Param("status") String status,
                                   @Param("location") String location,
                                   Pageable pageable);

    long countByStatus(ColonyStatus status);
}
