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
        // Balance card (compact)
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.honey.withAlpha(12), Colors.transparent]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.honey.withAlpha(25)),
          ),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppTheme.honey),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Balans', style: TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600)),
              Text('${_fmt(auth.balance)} UZS', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
            ])),
            GestureDetector(
              onTap: () => _showTopUp(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.honey, borderRadius: BorderRadius.circular(8)),
                child: const Text("To'ldirish", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ),
          ]),
        ),
        // Colony cards
        ..._colonies.map((c) => _CompactColonyCard(colony: c, formatPrice: _fmt, isVerified: isVerified)),
      ],
    );
  }

  void _showTopUp(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333338), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text("Balansni to'ldirish", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Operator orqali pul o\'tkazish', style: TextStyle(fontSize: 13, color: AppTheme.muted)),
          const SizedBox(height: 20),
          // Quick amounts
          Row(children: [
            for (final amt in [50000, 100000, 500000])
              Expanded(child: GestureDetector(
                onTap: () => ctrl.text = amt.toString(),
                child: Container(
                  margin: EdgeInsets.only(right: amt == 500000 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.darkBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.darkBorder)),
                  child: Center(child: Text('${amt ~/ 1000}K', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.honey))),
                ),
              )),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(hintText: 'Summani kiriting (UZS)', suffixText: 'UZS'),
          ),
          const SizedBox(height: 14),
          // Operator buttons
          Row(children: [
            _operatorBtn('Payme', const Color(0xFF00CCCC)),
            const SizedBox(width: 8),
            _operatorBtn('Click', const Color(0xFF0A84FF)),
            const SizedBox(width: 8),
            _operatorBtn('Uzum', const Color(0xFFFF6B00)),
          ]),
          const SizedBox(height: 16),
          MelButton(
            onPressed: () {
              final amount = int.tryParse(ctrl.text) ?? 0;
              if (amount > 0) {
                context.read<AuthProvider>().addBalance(amount);
                Navigator.pop(context);
              }
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("To'ldirish"), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18)]),
          ),
        ]),
      ),
    );
  }

  Widget _operatorBtn(String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(40))),
      child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
    ));
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
        ])),
      ]),
    );
  }
}
