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

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(names[index], style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColors[index].withAlpha(25), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColors[index].withAlpha(50))),
            child: Text(statuses[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColors[index])),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _stat('Investitsiya', '${(index + 1) * 4500000} UZS'),
          const SizedBox(width: 16),
          _stat('Ulushlar', '${(index + 1) * 3}'),
          const SizedBox(width: 16),
          _stat('Daromad', '+${((index + 1) * 7.5).toStringAsFixed(1)}%', valueColor: AppTheme.green),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Asal yig'ish", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          Text('${(progresses[index] * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progresses[index], backgroundColor: const Color(0xFF1C1C22), valueColor: AlwaysStoppedAnimation(statusColors[index]), minHeight: 5),
        ),
        if (statuses[index] != 'Faol') ...[
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.local_shipping_outlined, size: 16), label: const Text('Yetkazish'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.attach_money_rounded, size: 16), label: const Text('Sotish'))),
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
