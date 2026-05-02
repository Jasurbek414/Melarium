import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_bg.dart';
import '../home/home_screen.dart';
import '../market/market_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../profile/profile_screen.dart';
import '../beekeeper/beekeeper_colonies_screen.dart';
import '../beekeeper/beekeeper_reports_screen.dart';
import '../auth/verification_screen.dart';

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
    final isVerified = auth.isVerified;

    // ── Pages & Nav based on role + verification ──
    late final List<Widget> pages;
    late final List<_NavData> navItems;

    if (isInvestor) {
      if (isVerified) {
        // Tasdiqlangan investor — to'liq kirish
        pages = const [HomeScreen(), MarketScreen(), PortfolioScreen(), ProfileScreen()];
        navItems = [
          _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
          _NavData(Icons.storefront_outlined, Icons.storefront_rounded, 'Bozor'),
          _NavData(Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'Portfolio'),
          _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
        ];
      } else {
        // Tasdiqlanmagan investor — faqat bosh sahifa, verifikatsiya, profil
        pages = const [HomeScreen(), MarketScreen(), VerificationScreen(), ProfileScreen()];
        navItems = [
          _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
          _NavData(Icons.storefront_outlined, Icons.storefront_rounded, 'Bozor'),
          _NavData(Icons.verified_user_outlined, Icons.verified_user_rounded, 'Tasdiqlash'),
          _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
        ];
      }
    } else {
      // Beekeeper
      if (isVerified) {
        pages = const [HomeScreen(), BeekeeperColoniesScreen(), BeekeeperReportsScreen(), ProfileScreen()];
        navItems = [
          _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
          _NavData(Icons.hive_outlined, Icons.hive_rounded, 'Koloniyalar'),
          _NavData(Icons.description_outlined, Icons.description_rounded, 'Hisobotlar'),
          _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
        ];
      } else {
        pages = const [HomeScreen(), VerificationScreen(), ProfileScreen()];
        navItems = [
          _NavData(Icons.home_outlined, Icons.home_rounded, 'Bosh sahifa'),
          _NavData(Icons.verified_user_outlined, Icons.verified_user_rounded, 'Tasdiqlash'),
          _NavData(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
        ];
      }
    }

    // Clamp index
    final idx = _currentIndex.clamp(0, pages.length - 1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hexagon_outlined, size: 24, color: AppTheme.honey),
                        const SizedBox(width: 8),
                        Text('MELARIUM', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 4)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Verification badge
                          if (isVerified)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.green.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, size: 14, color: AppTheme.green),
                            ),
                          // Balance Pill
                          Flexible(
                            child: GestureDetector(
                              onTap: () => _showTopUp(context, context.read<AuthProvider>()),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkCard,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.honey.withAlpha(50)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppTheme.honey),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${auth.balance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} UZS',
                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.honey.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isInvestor ? 'Investor' : 'Asalarichi',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.honey),
                            ),
                          ),
                        ],
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
          decoration: const BoxDecoration(
            color: AppTheme.darkCard,
            border: Border(top: BorderSide(color: AppTheme.darkBorder)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 8, 
              right: 8, 
              top: 8, 
              bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12,
            ),
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

  void _showTopUp(BuildContext context, AuthProvider auth) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333338), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text("Balansni to'ldirish", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Operator orqali pul o\'tkazish', style: TextStyle(fontSize: 13, color: AppTheme.muted)),
          const SizedBox(height: 20),
          // Quick amounts
          Row(children: [
            for (final amt in [50000, 100000, 500000])
              Expanded(child: GestureDetector(
                onTap: () => ctrl.text = amt.toString(),
                child: Container(
                  margin: EdgeInsets.only(right: amt == 500000 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.darkBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.darkBorder)),
                  child: Center(child: Text('${amt ~/ 1000}K', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.honey))),
                ),
              )),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(hintText: 'Summani kiriting (UZS)', suffixText: 'UZS'),
          ),
          const SizedBox(height: 14),
          // Operator buttons
          Row(children: [
            _operatorBtn('Payme', const Color(0xFF00CCCC)),
            const SizedBox(width: 8),
            _operatorBtn('Click', const Color(0xFF0A84FF)),
            const SizedBox(width: 8),
            _operatorBtn('Uzum', const Color(0xFFFF6B00)),
          ]),
          const SizedBox(height: 16),
          MelButton(
            onPressed: () {
              final amount = int.tryParse(ctrl.text) ?? 0;
              if (amount > 0) {
                auth.addBalance(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balans muvaffaqiyatli to\'ldirildi!'), backgroundColor: AppTheme.green));
              }
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("To'ldirish"), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18)]),
          ),
        ]),
        ),
      ),
    );
  }

  Widget _operatorBtn(String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(40))),
      child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
    ));
  }
}

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavData(this.icon, this.activeIcon, this.label);
}
