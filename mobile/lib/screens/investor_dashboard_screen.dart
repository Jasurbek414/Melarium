import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../app/theme.dart';

class InvestorDashboardScreen extends StatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  State<InvestorDashboardScreen> createState() => _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState extends State<InvestorDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await apiService.getMyPortfolio();
      setState(() { _data = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: MelariumTheme.honey500));

    final investments = (_data?['content'] as List?) ?? [];
    double totalInvested = investments.fold(0, (s, i) => s + double.parse(i['totalInvested'].toString()));
    double totalRoi = investments.fold(0, (s, i) => s + double.parse(i['expectedRoi']?.toString() ?? '0'));
    double totalActual = investments.fold(0, (s, i) => s + double.parse(i['actualReturn']?.toString() ?? '0'));

    return RefreshIndicator(
      color: MelariumTheme.honey500,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // STATS
          Row(children: [
            _statCard('Invested', '\$${totalInvested.toStringAsFixed(2)}', MelariumTheme.honey400),
            const SizedBox(width: 12),
            _statCard('Expected ROI', '\$${totalRoi.toStringAsFixed(2)}', MelariumTheme.success),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('Actual Returns', '\$${totalActual.toStringAsFixed(2)}', const Color(0xFF60A5FA)),
            const SizedBox(width: 12),
            _statCard('Active', '${investments.where((i) => i['status'] == 'ACTIVE').length}', MelariumTheme.honey500),
          ]),
          const SizedBox(height: 24),

          const Text('Investment History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          if (investments.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No investments yet 🐝', style: TextStyle(color: Colors.white38)),
            ))
          else
            ...investments.map((inv) => _InvestmentTile(investment: inv)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
      ]),
    ));
  }
}

class _InvestmentTile extends StatelessWidget {
  final Map<String, dynamic> investment;
  const _InvestmentTile({required this.investment});

  @override
  Widget build(BuildContext context) {
    final status = investment['status'] as String? ?? '';
    final statusColors = {
      'ACTIVE': MelariumTheme.honey400,
      'COMPLETED': MelariumTheme.success,
      'PENDING': Colors.white54,
      'CANCELLED': MelariumTheme.error,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🐝', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(investment['colonyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (statusColors[status] ?? Colors.white).withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColors[status] ?? Colors.white54)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _chip('${investment['sharesCount']} shares'),
            const SizedBox(width: 8),
            _chip('\$${investment['totalInvested']} invested'),
            const SizedBox(width: 8),
            _chip('+\$${investment['expectedRoi'] ?? 0} ROI', color: MelariumTheme.success),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String label, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color ?? Colors.white70)),
  );
}
