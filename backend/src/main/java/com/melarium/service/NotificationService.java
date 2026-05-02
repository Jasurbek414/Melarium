package com.melarium.service;

import com.melarium.entity.Notification;
import com.melarium.entity.User;
import com.melarium.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final EmailService emailService;

    // ── CREATE IN-APP NOTIFICATION ────────────────────────────
    @Async
    @Transactional
    public void notify(User user, String title, String body, String type) {
        try {
            Notification n = Notification.builder()
                    .user(user)
                    .title(title)
                    .body(body)
                    .type(type)
                    .isRead(false)
                    .build();
            notificationRepository.save(n);
            log.info("[NOTIFY] {} → {}: {}", type, user.getPhone(), title);
        } catch (Exception e) {
            log.error("Failed to save notification: {}", e.getMessage());
        }
    }

    // ── INVESTMENT PURCHASED ──────────────────────────────────
    @Async
    public void onInvestmentPurchased(User investor, String colonyName,
                                       int shares, String total, String roi) {
        String title = "Investment Confirmed — " + colonyName;
        String body  = String.format("You purchased %d shares in %s for $%s. Expected ROI: +$%s",
                shares, colonyName, total, roi);
        notify(investor, title, body, "PURCHASE");

        // Email notification
        if (investor.getEmail() != null) {
            emailService.sendInvestmentConfirmation(investor.getEmail(), colonyName, shares, total, roi);
        }
    }

    // ── HONEY HARVESTED ───────────────────────────────────────
    @Async
    public void onHarvestCompleted(User investor, String colonyName, String payout) {
        String title = "🍯 Honey Harvested — " + colonyName;
        String body  = String.format("Colony %s harvest complete! Your payout: $%s. "
                + "Login to select: Receive Honey or Cash.", colonyName, payout);
        notify(investor, title, body, "HARVEST");

        if (investor.getEmail() != null) {
            emailService.sendHarvestNotification(investor.getEmail(), colonyName, payout);
        }
    }

    // ── COLONY STATUS CHANGED ─────────────────────────────────
    @Async
    public void onColonyStatusChanged(User beekeeper, String colonyName, String newStatus) {
        String title = "Colony Status Updated";
        String body  = String.format("Colony '%s' status changed to: %s", colonyName, newStatus);
        notify(beekeeper, title, body, "STATUS_CHANGE");
    }

    // ── COLONY VERIFIED ───────────────────────────────────────
    @Async
    public void onColonyVerified(User beekeeper, String colonyName) {
        String title = "✅ Colony Approved!";
        String body  = String.format("Your colony '%s' has been verified by admin and is now live on marketplace!",
                colonyName);
        notify(beekeeper, title, body, "COLONY_VERIFIED");
    }

    // ── GET NOTIFICATIONS FOR USER ────────────────────────────
    public Page<Notification> getMyNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    @Transactional
    public void markAllRead(Long userId) {
        notificationRepository.markAllReadByUserId(userId);
    }

    public long countUnread(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }
}
