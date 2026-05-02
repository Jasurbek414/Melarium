import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';

void showTopUpSheet(BuildContext context, AuthProvider auth) {
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
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(50))),
    child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
  ));
}
