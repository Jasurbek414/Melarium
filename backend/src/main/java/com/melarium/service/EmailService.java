package com.melarium.service;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    /**
     * Send OTP code via email (async — non-blocking)
     */
    @Async
    public void sendOtpEmail(String toEmail, String otpCode, String phone) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, "MELARIUM Platform");
            helper.setTo(toEmail);
            helper.setSubject("🍯 MELARIUM — Your OTP Code");
            helper.setText(buildOtpEmailHtml(otpCode, phone), true); // HTML

            mailSender.send(message);
            log.info("OTP email sent to: {}", toEmail);

        } catch (Exception e) {
            log.error("Failed to send OTP email to {}: {}", toEmail, e.getMessage());
        }
    }

    /**
     * Send investment confirmation email
     */
    @Async
    public void sendInvestmentConfirmation(String toEmail, String colonyName,
                                            int shares, String totalAmount, String expectedRoi) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, "MELARIUM Platform");
            helper.setTo(toEmail);
            helper.setSubject("🐝 MELARIUM — Investment Confirmed!");
            helper.setText(buildInvestmentHtml(colonyName, shares, totalAmount, expectedRoi), true);

            mailSender.send(message);
            log.info("Investment confirmation sent to: {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send investment email: {}", e.getMessage());
        }
    }

    /**
     * Send harvest notification email to investor
     */
    @Async
    public void sendHarvestNotification(String toEmail, String colonyName, String payoutAmount) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail, "MELARIUM Platform");
            helper.setTo(toEmail);
            helper.setSubject("🍯 MELARIUM — Honey Harvested! Your Payout is Ready");
            helper.setText(buildHarvestHtml(colonyName, payoutAmount), true);

            mailSender.send(message);
        } catch (Exception e) {
            log.error("Failed to send harvest email: {}", e.getMessage());
        }
    }

    // ── HTML TEMPLATES ────────────────────────────────────────

    private String buildOtpEmailHtml(String otpCode, String phone) {
        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="margin:0;padding:0;background:#0a0e12;font-family:'Inter',Arial,sans-serif;">
              <div style="max-width:520px;margin:40px auto;background:#111827;border-radius:16px;
                          border:1px solid rgba(245,158,11,0.25);overflow:hidden;">
                <!-- Header -->
                <div style="background:linear-gradient(135deg,#1a3520,#0d1f13);padding:32px 40px;text-align:center;">
                  <div style="font-size:48px;margin-bottom:8px;">🍯</div>
                  <h1 style="color:#fbbf24;font-size:24px;margin:0;letter-spacing:2px;">MELARIUM</h1>
                  <p style="color:#9ca3af;font-size:13px;margin:6px 0 0;">Agro Investment Platform</p>
                </div>
                <!-- Content -->
                <div style="padding:36px 40px;">
                  <h2 style="color:#f9fafb;font-size:20px;margin:0 0 12px;">Your Verification Code</h2>
                  <p style="color:#9ca3af;font-size:14px;margin:0 0 28px;">
                    Enter this code to verify your account. It expires in <strong style="color:#fbbf24;">2 minutes</strong>.
                  </p>
                  <!-- OTP Box -->
                  <div style="background:rgba(245,158,11,0.08);border:2px solid rgba(245,158,11,0.35);
                              border-radius:12px;padding:24px;text-align:center;margin-bottom:28px;">
                    <div style="font-size:42px;font-weight:800;letter-spacing:12px;color:#fbbf24;
                                font-family:'Courier New',monospace;">%s</div>
                  </div>
                  <p style="color:#6b7280;font-size:13px;margin:0;">
                    This code was requested for phone: <strong style="color:#9ca3af;">%s</strong><br>
                    If you didn't request this, please ignore this email.
                  </p>
                </div>
                <!-- Footer -->
                <div style="background:#0d1f13;padding:20px 40px;text-align:center;
                            border-top:1px solid rgba(255,255,255,0.06);">
                  <p style="color:#4b5563;font-size:12px;margin:0;">
                    © 2024 MELARIUM · Agro Investment Platform · Do not reply to this email
                  </p>
                </div>
              </div>
            </body>
            </html>
            """.formatted(otpCode, phone);
    }

    private String buildInvestmentHtml(String colonyName, int shares, String total, String roi) {
        return """
            <!DOCTYPE html>
            <html>
            <body style="margin:0;padding:0;background:#0a0e12;font-family:'Inter',Arial,sans-serif;">
              <div style="max-width:520px;margin:40px auto;background:#111827;border-radius:16px;
                          border:1px solid rgba(16,185,129,0.25);overflow:hidden;">
                <div style="background:linear-gradient(135deg,#1a3520,#0d1f13);padding:32px 40px;text-align:center;">
                  <div style="font-size:48px;">🐝</div>
                  <h1 style="color:#fbbf24;font-size:22px;margin:8px 0 0;letter-spacing:2px;">Investment Confirmed!</h1>
                </div>
                <div style="padding:36px 40px;">
                  <p style="color:#9ca3af;">Your investment in <strong style="color:#f9fafb;">%s</strong> has been confirmed.</p>
                  <div style="background:rgba(16,185,129,0.08);border:1px solid rgba(16,185,129,0.25);
                              border-radius:12px;padding:20px;margin:20px 0;">
                    <table style="width:100%%;border-collapse:collapse;">
                      <tr><td style="color:#6b7280;padding:6px 0;font-size:14px;">Shares Purchased</td>
                          <td style="color:#f9fafb;text-align:right;font-weight:700;">%d shares</td></tr>
                      <tr><td style="color:#6b7280;padding:6px 0;font-size:14px;">Total Invested</td>
                          <td style="color:#fbbf24;text-align:right;font-weight:700;">$%s</td></tr>
                      <tr><td style="color:#6b7280;padding:6px 0;font-size:14px;">Expected ROI</td>
                          <td style="color:#10b981;text-align:right;font-weight:700;">+$%s</td></tr>
                    </table>
                  </div>
                  <p style="color:#6b7280;font-size:13px;">Track your investment in the MELARIUM Investor Dashboard.</p>
                </div>
                <div style="background:#0d1f13;padding:16px 40px;text-align:center;border-top:1px solid rgba(255,255,255,0.06);">
                  <p style="color:#4b5563;font-size:12px;margin:0;">© 2024 MELARIUM</p>
                </div>
              </div>
            </body>
            </html>
            """.formatted(colonyName, shares, total, roi);
    }

    private String buildHarvestHtml(String colonyName, String payout) {
        return """
            <!DOCTYPE html>
            <html>
            <body style="margin:0;padding:0;background:#0a0e12;font-family:'Inter',Arial,sans-serif;">
              <div style="max-width:520px;margin:40px auto;background:#111827;border-radius:16px;
                          border:1px solid rgba(245,158,11,0.3);overflow:hidden;">
                <div style="background:linear-gradient(135deg,#78350f,#1a3520);padding:32px 40px;text-align:center;">
                  <div style="font-size:64px;">🍯</div>
                  <h1 style="color:#fbbf24;margin:8px 0 0;">Honey Harvested!</h1>
                </div>
                <div style="padding:36px 40px;text-align:center;">
                  <p style="color:#9ca3af;">Colony <strong style="color:#f9fafb;">%s</strong> has completed its harvest season.</p>
                  <div style="background:rgba(245,158,11,0.1);border:2px solid rgba(245,158,11,0.3);
                              border-radius:12px;padding:24px;margin:24px 0;">
                    <div style="color:#9ca3af;font-size:13px;margin-bottom:6px;">Your Payout</div>
                    <div style="color:#fbbf24;font-size:36px;font-weight:800;">$%s</div>
                  </div>
                  <p style="color:#6b7280;font-size:13px;">
                    Login to your MELARIUM dashboard to select: Receive Honey or Cash Payout.
                  </p>
                </div>
                <div style="background:#0d1f13;padding:16px 40px;text-align:center;border-top:1px solid rgba(255,255,255,0.06);">
                  <p style="color:#4b5563;font-size:12px;margin:0;">© 2024 MELARIUM</p>
                </div>
              </div>
            </body>
            </html>
            """.formatted(colonyName, payout);
    }
}
