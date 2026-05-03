package com.melarium.controller;

import com.melarium.entity.TopUpRequest;
import com.melarium.entity.User;
import com.melarium.enums.TopUpStatus;
import com.melarium.repository.TopUpRequestRepository;
import com.melarium.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/topup")
@RequiredArgsConstructor
@Slf4j
public class TopUpController {

    private final TopUpRequestRepository topUpRequestRepository;
    private final UserRepository userRepository;

    @PostMapping("/request")
    public ResponseEntity<?> createRequest(@RequestBody Map<String, Object> body) {
        log.info("[TOPUP] DEBUG: Request body = {}", body);
        try {
            // Mobil ilovadan foydalanuvchi telefonini ham yuboramiz
            String phone = body.get("phone").toString();
            User user = userRepository.findByPhone(phone)
                    .orElseThrow(() -> new RuntimeException("User not found: " + phone));

            BigDecimal amount = new BigDecimal(body.get("amount").toString());
            String method = body.get("method").toString();

            TopUpRequest request = TopUpRequest.builder()
                    .user(user)
                    .amount(amount)
                    .paymentMethod(method)
                    .status(TopUpStatus.PENDING)
                    .createdAt(OffsetDateTime.now())
                    .updatedAt(OffsetDateTime.now())
                    .build();

            topUpRequestRepository.save(request);
            log.info("[TOPUP] SUCCESS: Saved for {}", phone);
            return ResponseEntity.ok(Map.of("message", "Success"));
        } catch (Exception e) {
            log.error("[TOPUP] ERROR: ", e);
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/pending")
    public ResponseEntity<List<TopUpRequest>> getPendingRequests() {
        return ResponseEntity.ok(topUpRequestRepository.findByStatus(TopUpStatus.PENDING));
    }

    @PostMapping("/{id}/process")
    public ResponseEntity<?> processRequest(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        TopUpRequest req = topUpRequestRepository.findById(id).orElseThrow();
        if ("APPROVE".equals(body.get("action"))) {
            req.setStatus(TopUpStatus.APPROVED);
            User u = req.getUser();
            u.setBalance(u.getBalance().add(req.getAmount()));
            userRepository.save(u);
        } else {
            req.setStatus(TopUpStatus.REJECTED);
        }
        topUpRequestRepository.save(req);
        return ResponseEntity.ok(Map.of("message", "Done"));
    }
}
