import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';

void showTopUpSheet(BuildContext context, AuthProvider auth) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.darkCard,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF333338), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.honey.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.honey, size: 32),
          ),
          const SizedBox(height: 16),
          Text("Balansni to'ldirish", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            "Balansni to'ldirish uchun administrator bilan bog'laning.\nAdmin panel orqali balans to'ldiriladi.",
            style: TextStyle(fontSize: 13, color: AppTheme.muted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Contact info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: const Column(children: [
              Row(children: [
                Icon(Icons.phone_outlined, size: 16, color: AppTheme.honey),
                SizedBox(width: 8),
                Text('+998 90 123 45 67', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: 8),
              Row(children: [
                Icon(Icons.telegram, size: 16, color: AppTheme.honey),
                SizedBox(width: 8),
                Text('@melarium_admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Refresh button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await auth.refreshProfile();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Balans yangilandi'), backgroundColor: AppTheme.green),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.honey.withAlpha(20),
                foregroundColor: AppTheme.honey,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppTheme.honey.withAlpha(50)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Balansni yangilash', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ]),
      ),
    ),
  );
}
