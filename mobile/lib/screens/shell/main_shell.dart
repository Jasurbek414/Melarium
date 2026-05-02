import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../market/market_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../profile/profile_screen.dart';
import '../beekeeper/beekeeper_colonies_screen.dart';
import '../beekeeper/beekeeper_reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isInvestor = auth.role == UserRole.INVESTOR;

    final pages = isInvestor
        ? const [HomeScreen(), MarketScreen(), PortfolioScreen(), ProfileScreen()]
        : const [HomeScreen(), BeekeeperColoniesScreen(), BeekeeperReportsScreen(), ProfileScreen()];

    final navItems = isInvestor
        ? [
            _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
            _NavData(Icons.storefront_outlined, Icons.storefront_rounded, 'Bozor'),
            _NavData(Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'Portfolio'),
            _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
          ]
        : [
            _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
            _NavData(Icons.hive_outlined, Icons.hive_rounded, 'Koloniyalar'),
            _NavData(Icons.description_outlined, Icons.description_rounded, 'Hisobotlar'),
            _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
          ];

    // Clamp index
    final idx = _currentIndex.clamp(0, pages.length - 1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.hexagon_outlined, size: 24, color: AppTheme.honey),
                      const SizedBox(width: 8),
                      Text('MELARIUM', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 4)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.honey.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        isInvestor ? 'Investor' : 'Asalarichi',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.honey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.darkBorder),
              Expanded(child: pages[idx]),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: AppTheme.darkCard, border: Border(top: BorderSide(color: AppTheme.darkBorder))),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (i) => _navItem(navItems[i], i, idx)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(_NavData data, int idx, int currentIdx) {
    final isActive = currentIdx == idx;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.honey.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? data.activeIcon : data.icon, size: 22, color: isActive ? AppTheme.honey : AppTheme.muted),
          if (isActive) ...[
            const SizedBox(width: 6),
            Text(data.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.honey)),
          ],
        ]),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavData(this.icon, this.activeIcon, this.label);
}
