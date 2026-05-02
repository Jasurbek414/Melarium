import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assalomu alaykum 👋', style: TextStyle(fontSize: 14, color: AppTheme.muted)),
          const SizedBox(height: 4),
          Text('Melarium platformasi', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),

          Row(children: [
            const Expanded(child: StatBox(label: 'Umumiy qiymat', value: '\$4,500', icon: Icons.account_balance_wallet_outlined)),
            const SizedBox(width: 12),
            Expanded(child: StatBox(label: 'Daromad', value: '+18.5%', valueColor: AppTheme.green, icon: Icons.trending_up_rounded)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: StatBox(label: 'Koloniyalar', value: '4', icon: Icons.hive_outlined)),
            const SizedBox(width: 12),
            Expanded(child: StatBox(label: 'Asal hosili', value: '120kg', valueColor: AppTheme.honey, icon: Icons.water_drop_outlined)),
          ]),
          const SizedBox(height: 28),

          Text('Tezkor amallar', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(children: [
            _actionTile(Icons.shopping_bag_outlined, 'Investitsiya', AppTheme.honey),
            const SizedBox(width: 12),
            _actionTile(Icons.receipt_long_outlined, 'Hisobotlar', AppTheme.blue),
            const SizedBox(width: 12),
            _actionTile(Icons.local_shipping_outlined, 'Yetkazish', AppTheme.green),
            const SizedBox(width: 12),
            _actionTile(Icons.support_agent_outlined, 'Yordam', const Color(0xFF8B5CF6)),
          ]),
          const SizedBox(height: 28),

          Text("So'nggi faoliyat", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _activityItem("Investitsiya yakunlandi", "Bo'stonliq tog' asalxonasi", Icons.check_circle_outline, AppTheme.green, '2s oldin'),
          _activityItem("Asal yig'ish boshlandi", 'Samarqand vodiysi', Icons.agriculture_outlined, AppTheme.honey, '1k oldin'),
          _activityItem("Yangi koloniya qo'shildi", "Farg'ona Premium", Icons.add_circle_outline, AppTheme.blue, '3k oldin'),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.darkBorder)),
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
}
