import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class BeekeeperColoniesScreen extends StatelessWidget {
  const BeekeeperColoniesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        GlassCard(
          onTap: () {},
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.honey.withAlpha(25), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add_rounded, size: 18, color: AppTheme.honey),
            ),
            const SizedBox(width: 12),
            Text("Yangi koloniya qo'shish", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.honey)),
          ]),
        ),
        ...List.generate(3, (i) => _ColonyManageCard(index: i)),
      ],
    );
  }
}

class _ColonyManageCard extends StatelessWidget {
  final int index;
  const _ColonyManageCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ['Toshkent Oltin Asalxona', "Bo'stonliq Tog' Asalxonasi", 'Samarqand Vodiysi'];
    final statuses = ['Faol', "Yig'im", 'Faol'];
    final statusColors = [AppTheme.green, AppTheme.blue, AppTheme.green];
    final temps = ['34.2°C', '32.8°C', '35.1°C'];
    final humidity = ['62%', '58%', '65%'];
    final weights = ['45.2 kg', '38.7 kg', '52.1 kg'];

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
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0D0D11), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.darkBorder)),
          child: Row(children: [
            _sensorTile(Icons.thermostat_outlined, 'Harorat', temps[index], AppTheme.honey),
            Container(width: 1, height: 36, color: AppTheme.darkBorder, margin: const EdgeInsets.symmetric(horizontal: 8)),
            _sensorTile(Icons.water_drop_outlined, 'Namlik', humidity[index], AppTheme.blue),
            Container(width: 1, height: 36, color: AppTheme.darkBorder, margin: const EdgeInsets.symmetric(horizontal: 8)),
            _sensorTile(Icons.monitor_weight_outlined, 'Vazn', weights[index], AppTheme.green),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _infoChip(Icons.people_outline_rounded, '${(index + 1) * 4} investor'),
          const SizedBox(width: 10),
          _infoChip(Icons.pie_chart_outline_rounded, '${65 + index * 10}% moliya'),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: MelButton(outlined: true, onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 6), Text('Tahrirlash')]))),
          const SizedBox(width: 10),
          Expanded(child: MelButton(onPressed: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.description_outlined, size: 16), SizedBox(width: 6), Text('Hisobot')]))),
        ]),
      ]),
    );
  }

  Widget _sensorTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF0D0D11), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.darkBorder)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: AppTheme.muted),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.muted)),
        ]),
      ),
    );
  }
}
