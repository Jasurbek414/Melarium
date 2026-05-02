import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class BeekeeperReportsScreen extends StatelessWidget {
  const BeekeeperReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        // Summary
        GlassCard(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Umumiy hisobot', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(children: [
              _summaryItem("Jami\nasal", '320 kg', AppTheme.honey),
              const SizedBox(width: 12),
              _summaryItem("Jami\ndaromad", '15.2M UZS', AppTheme.green),
              const SizedBox(width: 12),
              _summaryItem("Jami\nxarajat", '4.8M UZS', AppTheme.red),
            ]),
          ]),
        ),

        // Reports list
        Text("So'nggi hisobotlar", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ...List.generate(5, (i) => _ReportItem(index: i)),
      ],
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withAlpha(12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(30))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.3)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final int index;
  const _ReportItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final months = ['Aprel', 'Mart', 'Fevral', 'Yanvar', 'Dekabr'];
    final honeys = ['45 kg', '38 kg', '52 kg', '42 kg', '35 kg'];
    final revenues = ['3.2M', '2.8M', '3.6M', '3.0M', '2.5M'];
    final icons = [Icons.check_circle_outline, Icons.check_circle_outline, Icons.check_circle_outline, Icons.check_circle_outline, Icons.hourglass_bottom_rounded];
    final colors = [AppTheme.green, AppTheme.green, AppTheme.green, AppTheme.green, AppTheme.honey];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.darkBorder)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: colors[index].withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Icon(icons[index], size: 18, color: colors[index]),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${months[index]} hisoboti', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Asal: ${honeys[index]}  •  Daromad: ${revenues[index]} UZS', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
        ])),
        const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF333338)),
      ]),
    );
  }
}
