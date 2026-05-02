import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: 5,
      itemBuilder: (context, index) => _ColonyCard(index: index),
    );
  }
}

class _ColonyCard extends StatelessWidget {
  final int index;
  const _ColonyCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ['Toshkent Oltin Asalxona', "Bo'stonliq Tog' Asalxonasi", 'Samarqand Vodiysi', "Farg'ona Premium", 'Buxoro Klassik'];
    final locations = ['Toshkent viloyati', "Bo'stonliq tumani", 'Samarqand viloyati', "Farg'ona viloyati", 'Buxoro viloyati'];
    final prices = ['1,500,000', '2,200,000', '1,800,000', '3,000,000', '1,200,000'];
    final rois = ['18.5%', '22.0%', '16.0%', '25.0%', '19.5%'];
    final shares = [72, 45, 88, 30, 92];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(colors: [AppTheme.honey.withAlpha(20), AppTheme.darkCard], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Stack(children: [
            const Center(child: Text('🐝', style: TextStyle(fontSize: 48))),
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.green.withAlpha(30), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.green.withAlpha(60))),
                child: const Text('Sotuvda', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.green)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(names[index % names.length], style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.honey),
              const SizedBox(width: 4),
              Text(locations[index % locations.length], style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _stat('Narxi', '${prices[index % prices.length]} UZS', Colors.white),
              const SizedBox(width: 12),
              _stat('Kutilgan ROI', rois[index % rois.length], AppTheme.green),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Moliyalashtirilgan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.muted)),
              Text('${shares[index % shares.length]}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: shares[index % shares.length] / 100, backgroundColor: const Color(0xFF1C1C22), valueColor: const AlwaysStoppedAnimation(AppTheme.honey), minHeight: 5),
            ),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('Investitsiya qilish'))),
          ]),
        ),
      ]),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF0D0D11), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.darkBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}
