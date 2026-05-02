import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class BeekeeperDashboard extends StatelessWidget {
  const BeekeeperDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('My Apiaries 🍯', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45))),
                      const SizedBox(height: 2),
                      Text('Beekeeper', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
                    ]),
                    Row(children: [
                      _circleBtn(Icons.add_rounded, () {}),
                      const SizedBox(width: 10),
                      _circleBtn(Icons.logout_rounded, () => context.read<AuthProvider>().logout()),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(child: StatBox(label: 'Colonies', value: '3', icon: Icons.hive_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: StatBox(label: 'Revenue', value: '\$2.8K', valueColor: AppTheme.green, icon: Icons.trending_up_rounded)),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Colony List ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: 3,
                  itemBuilder: (context, index) => _ColonyManageCard(index: index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Icon(icon, size: 20, color: Colors.white.withOpacity(0.6)),
      ),
    );
  }
}

class _ColonyManageCard extends StatelessWidget {
  final int index;
  const _ColonyManageCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final names = ['Toshkent Gold Apiary', 'Bostanliq Mountain Hive', 'Samarkand Valley'];
    final statuses = ['Active', 'Harvesting', 'Active'];
    final statusColors = [AppTheme.green, AppTheme.blue, AppTheme.green];
    final temps = ['34.2°C', '32.8°C', '35.1°C'];
    final humidity = ['62%', '58%', '65%'];
    final weights = ['45.2 kg', '38.7 kg', '52.1 kg'];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(names[index], style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColors[index].withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColors[index].withOpacity(0.25)),
            ),
            child: Text(statuses[index], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColors[index])),
          ),
        ]),
        const SizedBox(height: 16),

        // IoT Sensors
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(children: [
            _sensorTile(Icons.thermostat_outlined, 'Temp', temps[index], AppTheme.honey),
            _divider(),
            _sensorTile(Icons.water_drop_outlined, 'Humid', humidity[index], AppTheme.blue),
            _divider(),
            _sensorTile(Icons.monitor_weight_outlined, 'Weight', weights[index], AppTheme.green),
          ]),
        ),
        const SizedBox(height: 16),

        // Investors Info
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _infoChip(Icons.people_outline_rounded, '${(index + 1) * 4} investors'),
          _infoChip(Icons.pie_chart_outline_rounded, '${65 + index * 10}% funded'),
        ]),
        const SizedBox(height: 16),

        // Actions
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined, size: 16),
              label: const Text('Report'),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _sensorTile(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.35))),
      ]),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: AppTheme.darkBorder, margin: const EdgeInsets.symmetric(horizontal: 8));
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.5))),
      ]),
    );
  }
}
