package com.melarium.service;

import com.melarium.dto.report.HoneyReportRequest;
import com.melarium.entity.*;
import com.melarium.enums.*;
import com.melarium.repository.*;
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
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class HoneyReportService {

    private final HoneyReportRepository honeyReportRepository;
    private final ColonyRepository colonyRepository;
    private final UserRepository userRepository;
    private final InvestmentRepository investmentRepository;
    private final TransactionRepository transactionRepository;
    private final NotificationService notificationService;

    @Value("${melarium.commission.honey-sale-pct}")
    private double honeySaleCommissionPct;

    // ── CREATE REPORT ─────────────────────────────────────────
    @Transactional
    public HoneyReport createReport(HoneyReportRequest req, Long beekeeperId) {
        Colony colony = colonyRepository.findById(req.colonyId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Colony not found"));

        User beekeeper = userRepository.findById(beekeeperId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Beekeeper not found"));

        if (!colony.getBeekeeper().getId().equals(beekeeperId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not your colony");
        }

        HoneyReport report = HoneyReport.builder()
                .colony(colony)
                .beekeeper(beekeeper)
                .periodStart(req.periodStart())
                .periodEnd(req.periodEnd())
                .honeyVolumeKg(req.honeyVolumeKg())
                .expensesUsd(req.expensesUsd())
                .honeyPricePerKg(req.honeyPricePerKg())
                .notes(req.notes())
                .isFinalized(false)
                .build();

        return honeyReportRepository.save(report);
    }

    // ── FINALIZE REPORT (triggers ROI distribution) ───────────
    @Transactional
    public HoneyReport finalizeReport(Long reportId, Long beekeeperId) {
        HoneyReport report = honeyReportRepository.findById(reportId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));

        if (!report.getBeekeeper().getId().equals(beekeeperId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not your report");
        }

        if (report.getIsFinalized()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Report already finalized");
        }

        Colony colony = report.getColony();
        colony.setStatus(ColonyStatus.HARVESTING);
        colonyRepository.save(colony);

        // Total honey revenue
        BigDecimal totalRevenue = report.getHoneyVolumeKg()
                .multiply(report.getHoneyPricePerKg())
                .setScale(2, RoundingMode.HALF_UP);

        BigDecimal netRevenue = totalRevenue.subtract(report.getExpensesUsd());

        // Platform commission
        BigDecimal platformCommission = netRevenue
                .multiply(BigDecimal.valueOf(honeySaleCommissionPct / 100))
                .setScale(2, RoundingMode.HALF_UP);

        BigDecimal distributableRevenue = netRevenue.subtract(platformCommission);

        // Distribute to active investors proportionally
        List<Investment> activeInvestments = investmentRepository
                .findByColonyIdAndStatus(colony.getId(), InvestmentStatus.ACTIVE);

        int totalInvestedShares = activeInvestments.stream()
                .mapToInt(Investment::getSharesCount)
                .sum();

        for (Investment inv : activeInvestments) {
            if (totalInvestedShares > 0) {
                BigDecimal sharePct = BigDecimal.valueOf(inv.getSharesCount())
                        .divide(BigDecimal.valueOf(totalInvestedShares), 6, RoundingMode.HALF_UP);

                BigDecimal investorReturn = distributableRevenue
                        .multiply(sharePct)
                        .setScale(2, RoundingMode.HALF_UP);

                inv.setActualReturn(inv.getActualReturn().add(investorReturn));
                inv.setStatus(InvestmentStatus.COMPLETED);
                investmentRepository.save(inv);

                // Payout transaction
                Transaction payoutTx = Transaction.builder()
                        .user(inv.getInvestor())
                        .investment(inv)
                        .amount(investorReturn)
                        .type(TransactionType.PAYOUT)
                        .provider(PaymentProvider.MOCK)
                        .status(TransactionStatus.SUCCESS)
                        .description("Honey harvest payout - " + colony.getName())
                        .build();

                transactionRepository.save(payoutTx);

                // ── NOTIFICATION (TZ §5: asal yigʻilishi triggeri) ─────
                notificationService.onHarvestCompleted(
                        inv.getInvestor(),
                        colony.getName(),
                        investorReturn.toPlainString()
                );
            }
        }

        report.setIsFinalized(true);
        colony.setStatus(ColonyStatus.COMPLETED);
        colonyRepository.save(colony);

        log.info("Report finalized: colony={}, revenue={}, distributed={}",
                colony.getId(), totalRevenue, distributableRevenue);

        return honeyReportRepository.save(report);
    }

    public Page<HoneyReport> getReportsByColony(Long colonyId, Pageable pageable) {
        return honeyReportRepository.findByColonyId(colonyId, pageable);
    }
}
