import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({Key? key}) : super(key: key);

  static const _colonies = [
    {'name': 'Toshkent Oltin', 'loc': 'Toshkent viloyati', 'price': 150000, 'roi': 18.5, 'funded': 72, 'status': 'Sotuvda'},
    {'name': "Bo'stonliq Tog'", 'loc': "Bo'stonliq tumani", 'price': 220000, 'roi': 22.0, 'funded': 45, 'status': 'Faol'},
    {'name': 'Samarqand Vodiysi', 'loc': 'Samarqand viloyati', 'price': 180000, 'roi': 16.0, 'funded': 88, 'status': "Yig'im"},
    {'name': "Farg'ona Premium", 'loc': "Farg'ona viloyati", 'price': 300000, 'roi': 25.0, 'funded': 30, 'status': 'Sotuvda'},
    {'name': 'Buxoro Klassik', 'loc': 'Buxoro viloyati', 'price': 120000, 'roi': 19.5, 'funded': 92, 'status': 'Sotuvda'},
    {'name': "Namangan Tog'", 'loc': 'Namangan viloyati', 'price': 250000, 'roi': 24.0, 'funded': 55, 'status': 'Faol'},
  ];

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVerified = auth.isVerified;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [

        // Colony cards
        ..._colonies.map((c) => _CompactColonyCard(colony: c, formatPrice: _fmt, isVerified: isVerified)),
      ],
    );
  }


}

class _CompactColonyCard extends StatelessWidget {
  final Map<String, dynamic> colony;
  final String Function(int) formatPrice;
  final bool isVerified;
  const _CompactColonyCard({required this.colony, required this.formatPrice, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final statusColors = {'Sotuvda': AppTheme.green, 'Faol': AppTheme.honey, "Yig'im": AppTheme.blue};
    final color = statusColors[colony['status']] ?? AppTheme.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(children: [
        // Bee icon
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.honey.withAlpha(20), Colors.transparent]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Text('🐝', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(colony['name'] as String, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
              child: Text(colony['status'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 11, color: AppTheme.muted),
            const SizedBox(width: 3),
            Text(colony['loc'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('${formatPrice(colony['price'] as int)} UZS', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.green.withAlpha(15), borderRadius: BorderRadius.circular(4)),
              child: Text('+${colony['roi']}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.green)),
            ),
            const Spacer(),
            // Mini progress
            SizedBox(
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (colony['funded'] as int) / 100,
                  backgroundColor: const Color(0xFF1C1C22),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.honey),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text('${colony['funded']}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          ]),
          if (colony['status'] == 'Sotuvda') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: MelButton(
                padding: const EdgeInsets.symmetric(vertical: 0),
                onPressed: () async {
                  if (!isVerified) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avval verifikatsiyadan o\'ting!'), backgroundColor: AppTheme.red));
                    return;
                  }
                  final price = colony['price'] as int;
                  final success = await context.read<AuthProvider>().deductBalance(price);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Muvaffaqiyatli investitsiya qilindi!'), backgroundColor: AppTheme.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balansda mablag\' yetarli emas!'), backgroundColor: AppTheme.red));
                  }
                },
                child: const Center(child: Text('Investitsiya', style: TextStyle(fontSize: 12))),
              ),
            ),
          ],
        ])),
      ]),
    );
  }
}
