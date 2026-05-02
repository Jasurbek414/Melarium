import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isInvestor = auth.role == UserRole.INVESTOR;
    final isBeekeeper = auth.role == UserRole.BEEKEEPER;
    final isVerified = auth.isVerified;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text('Assalomu alaykum 👋', style: TextStyle(fontSize: 14, color: AppTheme.muted)),
          const SizedBox(height: 4),
          Text(
            auth.fullName.isNotEmpty ? auth.fullName : 'Melarium platformasi',
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),

          // ── Verification Banner (if not verified) ──
          if (!isVerified) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.honey.withAlpha(15), AppTheme.honey.withAlpha(5)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.honey.withAlpha(40)),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.honey.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppTheme.honey, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Verifikatsiya talab etiladi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      isInvestor
                          ? 'Investitsiya qilish uchun profilni tasdiqlang'
                          : 'Koloniya qo\'shish uchun profilni tasdiqlang',
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                )),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.honey, size: 22),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          // ── Stats (different for each role) ──
          if (isInvestor) ...[
            Row(children: [
              Expanded(child: StatBox(
                label: 'Umumiy qiymat',
                value: isVerified ? '4,500,000' : '—',
                suffix: isVerified ? 'UZS' : null,
                icon: Icons.account_balance_wallet_outlined,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatBox(
                label: 'Daromad',
                value: isVerified ? '+18.5%' : '—',
                valueColor: isVerified ? AppTheme.green : null,
                icon: Icons.trending_up_rounded,
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatBox(
                label: 'Ulushlarim',
                value: isVerified ? '12' : '0',
                icon: Icons.pie_chart_outline_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatBox(
                label: 'Koloniyalar',
                value: isVerified ? '4' : '0',
                valueColor: AppTheme.honey,
                icon: Icons.hive_outlined,
              )),
            ]),
          ] else if (isBeekeeper) ...[
            Row(children: [
              Expanded(child: StatBox(
                label: 'Koloniyalarim',
                value: isVerified ? '3' : '0',
                icon: Icons.hive_outlined,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatBox(
                label: 'Asal hosili',
                value: isVerified ? '120 kg' : '—',
                valueColor: AppTheme.honey,
                icon: Icons.water_drop_outlined,
              )),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StatBox(
                label: 'Investorlar',
                value: isVerified ? '28' : '0',
                icon: Icons.people_outline_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: StatBox(
                label: 'Daromad',
                value: isVerified ? '8.2M' : '—',
                suffix: isVerified ? 'UZS' : null,
                valueColor: AppTheme.green,
                icon: Icons.trending_up_rounded,
              )),
            ]),
          ],

          const SizedBox(height: 28),

          // ── Quick Actions ──
          Text('Tezkor amallar', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

          if (isInvestor) ...[
            Row(children: [
              _actionTile(Icons.shopping_bag_outlined, 'Bozor', AppTheme.honey, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.pie_chart_outline_rounded, 'Portfolio', AppTheme.blue, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.receipt_long_outlined, 'Hisobotlar', AppTheme.green, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.support_agent_outlined, 'Yordam', const Color(0xFF8B5CF6), true),
            ]),
          ] else ...[
            Row(children: [
              _actionTile(Icons.add_circle_outline, 'Yangi koloniya', AppTheme.honey, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.bar_chart_rounded, 'Hisobotlar', AppTheme.blue, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.sensors_rounded, 'IoT sensor', AppTheme.green, isVerified),
              const SizedBox(width: 12),
              _actionTile(Icons.support_agent_outlined, 'Yordam', const Color(0xFF8B5CF6), true),
            ]),
          ],

          const SizedBox(height: 28),

          // ── Recent Activity ──
          Text("So'nggi faoliyat", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

          if (!isVerified) ...[
            _emptyActivity(),
          ] else if (isInvestor) ...[
            _activityItem("Investitsiya yakunlandi", "Bo'stonliq tog' asalxonasi", Icons.check_circle_outline, AppTheme.green, '2s oldin'),
            _activityItem("Asal yig'ish boshlandi", 'Samarqand vodiysi', Icons.agriculture_outlined, AppTheme.honey, '1k oldin'),
            _activityItem("Yangi koloniya qo'shildi", "Farg'ona Premium", Icons.add_circle_outline, AppTheme.blue, '3k oldin'),
          ] else ...[
            _activityItem("Asal yig'ildi", "120 kg — Toshkent asalxonasi", Icons.water_drop_outlined, AppTheme.honey, '1s oldin'),
            _activityItem("Yangi investor qo'shildi", "3 ta yangi investor", Icons.person_add_outlined, AppTheme.blue, '5s oldin'),
            _activityItem("IoT ma'lumot yangilandi", "Harorat: 34.5°C", Icons.sensors_outlined, AppTheme.green, '12s oldin'),
          ],
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, bool enabled) {
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          ]),
        ),
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, IconData icon, Color color, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.darkBorder)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
        ])),
        Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF444448))),
      ]),
    );
  }

  Widget _emptyActivity() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: const Center(child: Column(children: [
        Icon(Icons.history_rounded, size: 36, color: Color(0xFF333338)),
        SizedBox(height: 12),
        Text('Hozircha faoliyat yo\'q', style: TextStyle(fontSize: 14, color: AppTheme.muted, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text('Verifikatsiyadan o\'ting va boshlang', style: TextStyle(fontSize: 12, color: Color(0xFF333338))),
      ])),
    );
  }
}
