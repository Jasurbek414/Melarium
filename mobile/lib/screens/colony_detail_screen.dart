import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/api_service.dart';
import '../app/theme.dart';

class ColonyDetailScreen extends StatefulWidget {
  final String id;
  const ColonyDetailScreen({super.key, required this.id});

  @override
  State<ColonyDetailScreen> createState() => _ColonyDetailScreenState();
}

class _ColonyDetailScreenState extends State<ColonyDetailScreen> {
  Map<String, dynamic>? _colony;
  bool _loading = true;
  int _shares = 1;
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await apiService.getColonyById(widget.id);
      setState(() { _colony = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _buy() async {
    final token = Hive.box('auth').get('accessToken');
    if (token == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first'))); return; }
    setState(() => _buying = true);
    try {
      await apiService.buyShares(int.parse(widget.id), _shares);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 Bought $_shares shares!'),
          backgroundColor: MelariumTheme.success,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: MelariumTheme.error));
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: MelariumTheme.honey500)));
    if (_colony == null) return const Scaffold(body: Center(child: Text('Colony not found')));

    final c = _colony!;
    final totalCost = (double.parse(c['pricePerShare'].toString()) * _shares).toStringAsFixed(2);
    final roiReturn = (double.parse(c['pricePerShare'].toString()) * _shares * double.parse(c['expectedRoiPct'].toString()) / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: Text(c['name'] ?? 'Colony')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(
                color: MelariumTheme.forest700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('🐝', style: TextStyle(fontSize: 64))),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
              if (c['isVerified'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: MelariumTheme.success.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                  child: const Text('✓ Verified', style: TextStyle(fontSize: 12, color: MelariumTheme.success)),
                ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(c['location'] ?? '', style: const TextStyle(color: Colors.white54)),
            ]),
            const SizedBox(height: 20),

            // Stats
            Row(children: [
              _statCard('\$${c['pricePerShare']}', 'Per Share'),
              const SizedBox(width: 12),
              _statCard('${c['expectedRoiPct']}%', 'ROI', accent: MelariumTheme.success),
              const SizedBox(width: 12),
              _statCard('${c['availableShares']}', 'Available'),
            ]),
            const SizedBox(height: 20),

            // IoT
            _section('🌡️ Live IoT Data', Row(children: [
              _iotTile('🌡️', '${c['temperatureCelsius'] ?? '—'}°C', 'Temp'),
              const SizedBox(width: 8),
              _iotTile('💧', '${c['humidityPct'] ?? '—'}%', 'Humidity'),
              const SizedBox(width: 8),
              _iotTile('⚖️', '${c['weightKg'] ?? '—'}kg', 'Weight'),
            ])),
            const SizedBox(height: 20),

            // Buy
            _section('💰 Buy Shares', Column(children: [
              Row(children: [
                const Text('Shares:', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.remove_circle_outline), color: MelariumTheme.honey400,
                    onPressed: () { if (_shares > 1) setState(() => _shares--); }),
                Text('$_shares', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.add_circle_outline), color: MelariumTheme.honey400,
                    onPressed: () { if (_shares < (c['availableShares'] as int)) setState(() => _shares++); }),
              ]),
              const Divider(color: Colors.white12),
              Row(children: [
                const Text('Total Cost:', style: TextStyle(color: Colors.white60)),
                const Spacer(),
                Text('\$$totalCost', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Text('Expected Return:', style: TextStyle(color: Colors.white60)),
                const Spacer(),
                Text('+\$$roiReturn', style: const TextStyle(fontWeight: FontWeight.w700, color: MelariumTheme.success)),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_buying || c['availableShares'] == 0) ? null : _buy,
                child: _buying
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MelariumTheme.forest700))
                    : Text(c['availableShares'] == 0 ? 'Fully Funded' : 'Invest \$$totalCost'),
              ),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, {Color? accent}) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: accent ?? MelariumTheme.honey400)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
      ]),
    ));
  }

  Widget _section(String title, Widget content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 10),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: content)),
    ],
  );

  Widget _iotTile(String emoji, String value, String label) => Expanded(child: Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 22)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
  ]));
}
