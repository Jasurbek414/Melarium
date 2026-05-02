package com.melarium.service;

import com.melarium.dto.investment.InvestmentRequest;
import com.melarium.dto.investment.InvestmentResponse;
import com.melarium.entity.Colony;
import com.melarium.entity.Investment;
import com.melarium.entity.Transaction;
import com.melarium.entity.User;
import com.melarium.enums.*;
import com.melarium.repository.ColonyRepository;
import com.melarium.repository.InvestmentRepository;
import com.melarium.repository.TransactionRepository;
import com.melarium.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
@RequiredArgsConstructor
@Slf4j
public class InvestmentService {

    private final InvestmentRepository investmentRepository;
    private final ColonyRepository colonyRepository;
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final NotificationService notificationService;

    @Value("${melarium.commission.investment-pct}")
    private double investmentCommissionPct;

    // ── BUY SHARES ───────────────────────────────────────────
    @Transactional
    public InvestmentResponse buyShares(InvestmentRequest req, Long investorId) {
        User investor = userRepository.findById(investorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Investor not found"));

        Colony colony = colonyRepository.findById(req.colonyId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));

        if (colony.getStatus() != ColonyStatus.AVAILABLE) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Colony is not available for investment");
        }

        if (!colony.getIsVerified()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Colony is not verified yet");
        }

        if (colony.getAvailableShares() < req.sharesCount()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Not enough shares available. Available: " + colony.getAvailableShares());
        }

        // Calculate investment
        BigDecimal totalInvested = colony.getPricePerShare()
                .multiply(BigDecimal.valueOf(req.sharesCount()));

        BigDecimal expectedRoi = calculateExpectedRoi(totalInvested, colony.getExpectedRoiPct());

        // Reserve shares
        colony.setAvailableShares(colony.getAvailableShares() - req.sharesCount());
        if (colony.getAvailableShares() == 0) {
            colony.setStatus(ColonyStatus.ACTIVE);
        }
        colonyRepository.save(colony);

        // Create investment record
        Investment investment = Investment.builder()
                .investor(investor)
                .colony(colony)
                .sharesCount(req.sharesCount())
                .sharePriceAtPurchase(colony.getPricePerShare())
                .totalInvested(totalInvested)
                .expectedRoi(expectedRoi)
                .actualReturn(BigDecimal.ZERO)
                .status(InvestmentStatus.ACTIVE)
                .build();

        investment = investmentRepository.save(investment);

        // Create mock payment transaction
        BigDecimal commission = totalInvested
                .multiply(BigDecimal.valueOf(investmentCommissionPct / 100))
                .setScale(2, RoundingMode.HALF_UP);

        Transaction tx = Transaction.builder()
                .user(investor)
                .investment(investment)
                .amount(totalInvested)
                .type(TransactionType.INVESTMENT)
                .provider(PaymentProvider.MOCK)
                .status(TransactionStatus.SUCCESS)
                .providerTxId("MOCK-" + System.currentTimeMillis())
                .description("Investment in colony: " + colony.getName() + " | Commission: $" + commission)
                .build();

        transactionRepository.save(tx);

        // Commission transaction
        Transaction commTx = Transaction.builder()
                .user(investor)
                .investment(investment)
                .amount(commission)
                .type(TransactionType.COMMISSION)
                .provider(PaymentProvider.MOCK)
                .status(TransactionStatus.SUCCESS)
                .description("Platform commission for colony: " + colony.getName())
                .build();

        transactionRepository.save(commTx);

        log.info("Investment created: investor={}, colony={}, shares={}, total={}",
                investorId, colony.getId(), req.sharesCount(), totalInvested);

        // ── NOTIFICATION (TZ §5: sotib olish triggeri) ────────
        notificationService.onInvestmentPurchased(
                investor,
                colony.getName(),
                req.sharesCount(),
                totalInvested.toPlainString(),
                expectedRoi.toPlainString()
        );

        return toResponse(investment);
    }

    // ── INVESTOR PORTFOLIO ────────────────────────────────────
    public Page<InvestmentResponse> getMyInvestments(Long investorId, Pageable pageable) {
        return investmentRepository.findByInvestorId(investorId, pageable)
                .map(this::toResponse);
    }

    public InvestmentResponse getById(Long id, Long investorId) {
        Investment inv = investmentRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Investment not found"));

        if (!inv.getInvestor().getId().equals(investorId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        return toResponse(inv);
    }

    // ── HONEY CHOICE ─────────────────────────────────────────
    @Transactional
    public InvestmentResponse setHoneyChoice(Long investmentId, HoneyChoice choice, Long investorId) {
        Investment inv = investmentRepository.findById(investmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Investment not found"));

        if (!inv.getInvestor().getId().equals(investorId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }

        inv.setHoneyChoice(choice);
        return toResponse(investmentRepository.save(inv));
    }

    // ── ROI CALCULATION ───────────────────────────────────────
    private BigDecimal calculateExpectedRoi(BigDecimal invested, BigDecimal roiPct) {
        // ROI = invested * (roi_pct / 100)
        return invested
                .multiply(roiPct)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    // ── MAPPER ────────────────────────────────────────────────
    private InvestmentResponse toResponse(Investment inv) {
        return new InvestmentResponse(
                inv.getId(),
                inv.getColony().getId(),
                inv.getColony().getName(),
                inv.getColony().getLocation(),
                inv.getSharesCount(),
                inv.getSharePriceAtPurchase(),
                inv.getTotalInvested(),
                inv.getExpectedRoi(),
                inv.getActualReturn(),
                inv.getStatus(),
                inv.getHoneyChoice(),
                inv.getCreatedAt()
        );
    }
}
