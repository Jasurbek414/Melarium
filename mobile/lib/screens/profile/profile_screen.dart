import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../utils/topup_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isVerified = auth.isVerified;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(children: [
        // Avatar
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppTheme.honeyLight, AppTheme.honeyDark]),
          ),
          child: Center(child: Text(
            auth.fullName.isNotEmpty ? auth.fullName[0].toUpperCase() : '?',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black),
          )),
        ),
        const SizedBox(height: 14),
        Text(
          auth.fullName.isNotEmpty ? auth.fullName : auth.phoneNumber.isNotEmpty ? auth.phoneNumber : 'Foydalanuvchi',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (auth.phoneNumber.isNotEmpty && auth.fullName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(auth.phoneNumber, style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
        ],
        const SizedBox(height: 8),

        // Role + Verification badges
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.honey.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Text(
              auth.role == UserRole.INVESTOR ? 'Investor' : auth.role == UserRole.BEEKEEPER ? 'Asalarichi' : 'Foydalanuvchi',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.honey),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? AppTheme.green.withAlpha(20) : AppTheme.red.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                isVerified ? Icons.verified_rounded : Icons.error_outline_rounded,
                size: 14,
                color: isVerified ? AppTheme.green : AppTheme.red,
              ),
              const SizedBox(width: 4),
              Text(
                isVerified ? 'Tasdiqlangan' : 'Tasdiqlanmagan',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isVerified ? AppTheme.green : AppTheme.red),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 24),

        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF222226), Color(0xFF15151A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.honey.withAlpha(30)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppTheme.muted),
                        const SizedBox(width: 6),
                        const Text('Mavjud balans', style: TextStyle(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${auth.balance.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} UZS',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.honey),
                    ),
                  ],
                ),
              ),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppTheme.honey.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded, color: AppTheme.honey),
                  onPressed: () => showTopUpSheet(context, auth),
                  tooltip: "Balansni to'ldirish",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _menuSection('Hisob', [
          _menuItem(Icons.person_outline_rounded, 'Profilni tahrirlash', () {}),
          _menuItem(Icons.notifications_none_rounded, 'Bildirishnomalar', () {}),
          _menuItem(Icons.language_rounded, 'Til sozlamalari', () {}),
          _menuItem(Icons.security_outlined, 'Xavfsizlik', () {}),
        ]),
        const SizedBox(height: 16),
        _menuSection('Umumiy', [
          _menuItem(Icons.help_outline_rounded, 'Yordam va qo\'llab-quvvatlash', () {}),
          _menuItem(Icons.info_outline_rounded, 'Melarium haqida', () {}),
          _menuItem(Icons.description_outlined, 'Shartlar va Maxfiylik', () {}),
        ]),
        const SizedBox(height: 16),
        _menuSection('', [
          _menuItem(Icons.logout_rounded, 'Chiqish', () => auth.logout(), isDestructive: true),
        ]),
      ]),
    );
  }

  Widget _menuSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title.isNotEmpty) ...[
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.muted, letterSpacing: 0.5)),
        const SizedBox(height: 10),
      ],
      Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          gradient: LinearGradient(
            colors: [Colors.white.withAlpha(5), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(10)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final idx = entry.key;
            final isLast = idx == items.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  Divider(height: 1, indent: 52, color: Colors.white.withAlpha(10)),
              ],
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppTheme.red : AppTheme.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Icon(icon, size: 18, color: isDestructive ? AppTheme.red : Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDestructive ? AppTheme.red : Colors.white))),
          Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withAlpha(40)),
        ]),
      ),
    );
  }
}
