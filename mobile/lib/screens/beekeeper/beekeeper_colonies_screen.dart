import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/colony_provider.dart';
import '../../core/theme/app_theme.dart';

class BeekeeperColoniesScreen extends StatefulWidget {
  const BeekeeperColoniesScreen({Key? key}) : super(key: key);

  @override
  State<BeekeeperColoniesScreen> createState() => _BeekeeperColoniesScreenState();
}

class _BeekeeperColoniesScreenState extends State<BeekeeperColoniesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColonyProvider>().fetchColonies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ColonyProvider>();

    return RefreshIndicator(
      onRefresh: () => provider.fetchColonies(),
      color: AppTheme.honey,
      backgroundColor: AppTheme.darkCard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          GlassCard(
            onTap: () => _showAddColonyModal(context),
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
          if (provider.isLoading && provider.colonies.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppTheme.honey)))
          else if (provider.colonies.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Hozircha koloniyalar yo'q", style: TextStyle(color: AppTheme.muted))))
          else
            ...provider.colonies.map((c) => _ColonyManageCard(colony: c)),
        ],
      ),
    );
  }

  void _showAddColonyModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final roiCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333338), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text("Yangi koloniya", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Koloniya nomi')),
          const SizedBox(height: 12),
          TextField(controller: locCtrl, decoration: const InputDecoration(hintText: 'Manzil (Viloyat/Tuman)')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Narxi (UZS)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: roiCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Kutilgan ROI (%)'))),
          ]),
          const SizedBox(height: 24),
          MelButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && locCtrl.text.isNotEmpty) {
                final newColony = Colony(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  location: locCtrl.text,
                  price: int.tryParse(priceCtrl.text) ?? 1000000,
                  expectedRoi: double.tryParse(roiCtrl.text) ?? 15.0,
                  fundedPercentage: 0,
                  status: 'Kutish',
                  temperature: 30.0,
                  humidity: 50.0,
                  weight: 0.0,
                  investorCount: 0,
                );
                context.read<ColonyProvider>().addColony(newColony);
                Navigator.pop(context);
              }
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Qo'shish"), SizedBox(width: 8), Icon(Icons.add_rounded, size: 18)]),
          ),
        ]),
      ),
    );
  }
}

class _ColonyManageCard extends StatelessWidget {
  final Colony colony;
  const _ColonyManageCard({required this.colony});

  @override
  Widget build(BuildContext context) {
    final statusColors = {'Sotuvda': AppTheme.green, 'Faol': AppTheme.honey, "Yig'im": AppTheme.blue, 'Kutish': AppTheme.muted};
    final color = statusColors[colony.status] ?? AppTheme.muted;
    final String priceFmt = colony.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.honey.withAlpha(20), Colors.transparent]), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('🐝', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(colony.name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 12, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text(colony.location, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              ]),
            ])),
            // Menu
            PopupMenuButton<String>(
              color: AppTheme.darkCard,
              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.muted, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.darkBorder)),
              onSelected: (val) {
                if (val == 'delete') context.read<ColonyProvider>().deleteColony(colony.id);
                // tahrirlash qismi...
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Tahrirlash', style: TextStyle(fontSize: 14))])),
                PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.red), const SizedBox(width: 8), Text("O'chirish", style: TextStyle(fontSize: 14, color: AppTheme.red))])),
              ],
            ),
          ]),
        ),
        const Divider(height: 1, color: AppTheme.darkBorder),
        // IoT data
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _miniStat(Icons.thermostat_outlined, '${colony.temperature}°C', AppTheme.honey),
            _miniStat(Icons.water_drop_outlined, '${colony.humidity}%', AppTheme.blue),
            _miniStat(Icons.monitor_weight_outlined, '${colony.weight} kg', AppTheme.green),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(6)),
              child: Text(colony.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(IconData icon, String val, Color c) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
