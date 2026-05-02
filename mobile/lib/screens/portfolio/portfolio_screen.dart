import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: 3,
      itemBuilder: (context, index) => _InvestmentCard(index: index),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final int index;
  const _InvestmentCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ["Bo'stonliq Tog'", 'Samarqand Vodiysi', "Farg'ona Premium"];
    final statuses = ["Yig'im", 'Faol', 'Tugallangan'];
    final statusColors = [AppTheme.blue, AppTheme.honey, AppTheme.green];
    final progresses = [0.7, 0.45, 1.0];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        gradient: LinearGradient(
          colors: [statusColors[index].withAlpha(15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColors[index].withAlpha(30)),
        boxShadow: [
          BoxShadow(color: statusColors[index].withAlpha(10), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(names[index], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColors[index].withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColors[index].withAlpha(40)),
            ),
            child: Text(statuses[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColors[index])),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          _stat('Investitsiya', '${(index + 1) * 4500000} UZS'),
          const SizedBox(width: 16),
          _stat('Ulushlar', '${(index + 1) * 3}'),
          const SizedBox(width: 16),
          _stat('Daromad', '+${((index + 1) * 7.5).toStringAsFixed(1)}%', valueColor: AppTheme.green),
        ]),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Asal yig'ish", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          Text('${(progresses[index] * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: statusColors[index].withAlpha(20), blurRadius: 6)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progresses[index], backgroundColor: Colors.black.withAlpha(50), valueColor: AlwaysStoppedAnimation(statusColors[index]), minHeight: 6),
          ),
        ),
        if (statuses[index] != 'Faol') ...[
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: MelButton(outlined: true, onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 12), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.local_shipping_outlined, size: 16), SizedBox(width: 6), Text('Yetkazish', style: TextStyle(fontSize: 13))]))),
            const SizedBox(width: 12),
            Expanded(child: MelButton(onPressed: () {}, padding: const EdgeInsets.symmetric(vertical: 12), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.attach_money_rounded, size: 16), SizedBox(width: 6), Text('Sotish', style: TextStyle(fontSize: 13))]))),
          ]),
        ],
      ]),
    );
  }

  Widget _stat(String label, String value, {Color valueColor = Colors.white}) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
      ]),
    );
  }
}
