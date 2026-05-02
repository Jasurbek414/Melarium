import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isInvestor = auth.role == UserRole.INVESTOR;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppTheme.honey.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSubmitted ? Icons.hourglass_top_rounded : Icons.verified_user_outlined,
              size: 48,
              color: _isSubmitted ? AppTheme.honey : AppTheme.muted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSubmitted ? 'So\'rov yuborildi' : 'Verifikatsiya talab etiladi',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _isSubmitted
                ? 'Hujjatlaringiz ko\'rib chiqilmoqda.\nBu 24 soatgacha vaqt olishi mumkin.'
                : isInvestor
                    ? 'Investitsiya qilish uchun shaxsiy ma\'lumotlaringizni tasdiqlashingiz kerak.'
                    : 'Koloniya ro\'yxatdan o\'tkazish uchun shaxsiy ma\'lumotlaringizni tasdiqlashingiz kerak.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.muted, height: 1.6),
          ),
          const SizedBox(height: 32),

          if (!_isSubmitted) ...[
            // Steps
            _stepItem(1, 'Shaxsiy ma\'lumotlar', 'Ism, familiya, manzil', Icons.person_outline, true),
            _stepItem(2, 'Hujjat yuklash', isInvestor ? 'Pasport yoki ID karta' : 'Pasport + Guvohnoma', Icons.upload_file_outlined, false),
            _stepItem(3, 'Tasdiqlash', 'Ko\'rib chiqish va yuborish', Icons.check_circle_outline, false),
            const SizedBox(height: 32),

            // Submit button
            MelButton(
              onPressed: _isSubmitting ? null : () async {
                setState(() => _isSubmitting = true);
                await context.read<AuthProvider>().requestVerification();
                if (mounted) setState(() { _isSubmitting = false; _isSubmitted = true; });
              },
              child: _isSubmitting
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)))
                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Verifikatsiyani boshlash'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ]),
            ),
          ] else ...[
            // Status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.honey.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.honey.withAlpha(30)),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.honey.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.check_rounded, color: AppTheme.honey),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Muvaffaqiyatli yuborildi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Tez orada tasdiqlanadi', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                ])),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepItem(int num, String title, String subtitle, IconData icon, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? AppTheme.honey.withAlpha(8) : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: active ? AppTheme.honey.withAlpha(30) : AppTheme.darkBorder),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: active ? AppTheme.honey.withAlpha(25) : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('$num', style: TextStyle(fontWeight: FontWeight.w800, color: active ? AppTheme.honey : AppTheme.muted))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : AppTheme.muted)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: active ? AppTheme.muted : const Color(0xFF333338))),
        ])),
        Icon(icon, size: 20, color: active ? AppTheme.honey : const Color(0xFF333338)),
      ]),
    );
  }
}
