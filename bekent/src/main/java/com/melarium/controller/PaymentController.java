package com.melarium.controller;

import com.melarium.entity.Transaction;
import com.melarium.enums.TransactionStatus;
import com.melarium.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
@Slf4j
public class PaymentController {

    private final TransactionRepository transactionRepository;

    /**
     * Simulate Click payment initiation
     * POST /api/payment/click/prepare
     */
    @PostMapping("/click/prepare")
    public ResponseEntity<Map<String, Object>> clickPrepare(@RequestBody Map<String, Object> payload) {
        log.info("CLICK prepare webhook received: {}", payload);

        String merchantTransId = payload.getOrDefault("merchant_trans_id", "").toString();
        String clickTransId = "CLICK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        transactionRepository.findByProviderTxId(merchantTransId).ifPresent(tx -> {
            tx.setProviderTxId(clickTransId);
            tx.setProviderPayload(payload.toString());
            transactionRepository.save(tx);
        });

        return ResponseEntity.ok(Map.of(
                "click_trans_id", clickTransId,
                "merchant_trans_id", merchantTransId,
                "merchant_confirm_id", 1,
                "error", 0,
                "error_note", "Success"
        ));
    }

    /**
     * Simulate Click payment confirmation (webhook)
     * POST /api/payment/click/confirm
     */
    @PostMapping("/click/confirm")
    public ResponseEntity<Map<String, Object>> clickConfirm(@RequestBody Map<String, Object> payload) {
        log.info("CLICK confirm webhook received: {}", payload);

        String clickTransId = payload.getOrDefault("click_trans_id", "").toString();

        transactionRepository.findByProviderTxId(clickTransId).ifPresent(tx -> {
            tx.setStatus(TransactionStatus.SUCCESS);
            transactionRepository.save(tx);
            log.info("Transaction {} confirmed via CLICK", clickTransId);
        });

        return ResponseEntity.ok(Map.of(
                "click_trans_id", clickTransId,
                "merchant_confirm_id", 1,
                "error", 0,
                "error_note", "Success"
        ));
    }

    /**
     * Simulate Payme check-perform (webhook)
     * POST /api/payment/payme/webhook
     */
    @PostMapping("/payme/webhook")
    public ResponseEntity<Map<String, Object>> paymeWebhook(@RequestBody Map<String, Object> payload) {
        log.info("PAYME webhook received: {}", payload);

        String method = payload.getOrDefault("method", "").toString();
        Map<String, Object> params = (Map<String, Object>) payload.getOrDefault("params", Map.of());

        return switch (method) {
            case "CheckPerformTransaction" -> ResponseEntity.ok(Map.of(
                    "result", Map.of("allow", true)
            ));
            case "CreateTransaction" -> {
                String transactionId = params.getOrDefault("id", UUID.randomUUID().toString()).toString();
                yield ResponseEntity.ok(Map.of(
                        "result", Map.of(
                                "create_time", OffsetDateTime.now().toEpochSecond() * 1000,
                                "transaction", transactionId,
                                "state", 1
                        )
                ));
            }
            case "PerformTransaction" -> {
                String txId = params.getOrDefault("id", "").toString();
                transactionRepository.findByProviderTxId(txId).ifPresent(tx -> {
                    tx.setStatus(TransactionStatus.SUCCESS);
                    transactionRepository.save(tx);
                });
                yield ResponseEntity.ok(Map.of(
                        "result", Map.of(
                                "perform_time", OffsetDateTime.now().toEpochSecond() * 1000,
                                "transaction", txId,
                                "state", 2
                        )
                ));
            }
            default -> ResponseEntity.ok(Map.of("error", Map.of("code", -32601, "message", "Method not found")));
        };
    }

    /**
     * Get transaction status by ID (mock)
     * GET /api/payment/status/{providerTxId}
     */
    @GetMapping("/status/{providerTxId}")
    public ResponseEntity<Map<String, Object>> getStatus(@PathVariable String providerTxId) {
        Transaction tx = transactionRepository.findByProviderTxId(providerTxId)
                .orElse(null);

        if (tx == null) {
            return ResponseEntity.ok(Map.of("status", "NOT_FOUND"));
        }

        return ResponseEntity.ok(Map.of(
                "transactionId", tx.getId(),
                "providerTxId", providerTxId,
                "status", tx.getStatus(),
                "amount", tx.getAmount(),
                "type", tx.getType()
        ));
    }
}
