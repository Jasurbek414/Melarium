import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({Key? key}) : super(key: key);

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                      Text('Good Morning 👋', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45))),
                      const SizedBox(height: 2),
                      Text('Investor', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
                    ]),
                    Row(children: [
                      _circleBtn(Icons.notifications_none_rounded, () {}),
                      const SizedBox(width: 10),
                      _circleBtn(Icons.logout_rounded, () => context.read<AuthProvider>().logout()),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(child: StatBox(label: 'Portfolio', value: '\$4,500', valueColor: Colors.white, icon: Icons.account_balance_wallet_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: StatBox(label: 'Returns', value: '+18.5%', valueColor: AppTheme.green, icon: Icons.trending_up_rounded)),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Tab Bar ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: AppTheme.honey,
                  unselectedLabelColor: Colors.white.withOpacity(0.4),
                  labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Marketplace'),
                    Tab(text: 'My Portfolio'),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // ── Tab Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _MarketplaceTab(),
                    _PortfolioTab(),
                  ],
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

// ═════════════════════════════════════════════════════
//  MARKETPLACE TAB
// ═════════════════════════════════════════════════════
class _MarketplaceTab extends StatelessWidget {
  const _MarketplaceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
    final names = ['Toshkent Gold Apiary', 'Bostanliq Mountain Hive', 'Samarkand Valley', 'Fergana Premium', 'Bukhara Classic'];
    final locations = ['Toshkent viloyati', "Bo'stonliq tumani", 'Samarkand viloyati', "Farg'ona viloyati", 'Buxoro viloyati'];
    final prices = ['\$150', '\$220', '\$180', '\$300', '\$120'];
    final rois = ['18.5%', '22.0%', '16.0%', '25.0%', '19.5%'];
    final shares = [72, 45, 88, 30, 92];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Image area
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [AppTheme.honey.withOpacity(0.15), AppTheme.darkCard],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(children: [
              const Center(child: Text('🐝', style: TextStyle(fontSize: 56))),
              Positioned(top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.green.withOpacity(0.3)),
                  ),
                  child: Text('Available', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.green)),
                ),
              ),
            ]),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(names[index % names.length], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppTheme.honey),
                const SizedBox(width: 4),
                Text(locations[index % locations.length], style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45))),
              ]),
              const SizedBox(height: 16),

              // Stats row
              Row(children: [
                _miniStat('Share Price', prices[index % prices.length], Colors.white),
                const SizedBox(width: 12),
                _miniStat('Est. ROI', rois[index % rois.length], AppTheme.green),
              ]),
              const SizedBox(height: 14),

              // Progress
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Funded', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.35))),
                Text('${shares[index % shares.length]}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: shares[index % shares.length] / 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.honey),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 14),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Invest Now'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.35), letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
//  PORTFOLIO TAB
// ═════════════════════════════════════════════════════
class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
    final names = ['Bostanliq Mountain Hive', 'Samarkand Valley', 'Fergana Premium'];
    final statuses = ['Harvesting', 'Active', 'Completed'];
    final statusColors = [AppTheme.blue, AppTheme.honey, AppTheme.green];
    final progresses = [0.7, 0.45, 1.0];

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

        // Stats
        Row(children: [
          _miniStat('Invested', '\$${(index + 1) * 450}'),
          const SizedBox(width: 12),
          _miniStat('Shares', '${(index + 1) * 3}'),
          const SizedBox(width: 12),
          _miniStat('Return', '+${((index + 1) * 7.5).toStringAsFixed(1)}%', valueColor: AppTheme.green),
        ]),
        const SizedBox(height: 16),

        // Progress
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Honey Collection', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.35))),
          Text('${(progresses[index] * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progresses[index],
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation(statusColors[index]),
            minHeight: 5,
          ),
        ),

        if (statuses[index] == 'Harvesting' || statuses[index] == 'Completed') ...[
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_shipping_outlined, size: 16),
                label: const Text('Deliver'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_money_rounded, size: 16),
                label: const Text('Cash Out'),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _miniStat(String label, String value, {Color valueColor = Colors.white}) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.35), letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor)),
      ]),
    );
  }
}
