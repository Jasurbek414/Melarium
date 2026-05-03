package com.melarium.repository;

import com.melarium.entity.TopUpRequest;
import com.melarium.enums.TopUpStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TopUpRequestRepository extends JpaRepository<TopUpRequest, Long> {
    List<TopUpRequest> findByUserId(Long userId);
    List<TopUpRequest> findByStatus(TopUpStatus status);
}
