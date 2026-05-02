import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.honeyLight, AppTheme.honeyDark])),
          child: const Center(child: Icon(Icons.person_rounded, size: 40, color: Colors.black)),
        ),
        const SizedBox(height: 14),
        Text(auth.phoneNumber.isEmpty ? 'Foydalanuvchi' : auth.phoneNumber, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.honey.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: Text(
            auth.role == UserRole.INVESTOR ? 'Investor' : auth.role == UserRole.BEEKEEPER ? 'Asalarichi' : 'Foydalanuvchi',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.honey),
          ),
        ),
        const SizedBox(height: 32),

        _menuSection('Hisob', [
          _menuItem(Icons.person_outline_rounded, 'Profilni tahrirlash', () {}),
          _menuItem(Icons.notifications_none_rounded, 'Bildirishnomalar', () {}),
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
        decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.darkBorder)),
        child: Column(children: items),
      ),
    ]);
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(children: [
          Icon(icon, size: 20, color: isDestructive ? AppTheme.red : AppTheme.muted),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDestructive ? AppTheme.red : Colors.white))),
          const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF333338)),
        ]),
      ),
    );
  }
}
