import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../utils/api_service.dart';

class TopUpSheet extends StatefulWidget {
  final AuthProvider auth;
  const TopUpSheet({Key? key, required this.auth}) : super(key: key);

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Click';
  bool _isLoading = false;

  final List<Map<String, String>> _methods = [
    {'name': 'Click', 'icon': '💳'},
    {'name': 'Payme', 'icon': '📱'},
    {'name': 'Uzum', 'icon': '💜'},
    {'name': 'Bank', 'icon': '🏦'},
  ];

  Future<void> _submitRequest() async {
    final String amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, summani kiriting'), backgroundColor: AppTheme.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double? amount = double.tryParse(amountText);
      if (amount == null) throw "Summa noto'g'ri kiritildi";

      final String phone = widget.auth.phoneNumber;
      debugPrint("[TOPUP] Yuborilmoqda: $amount via $_selectedMethod for $phone");

      final response = await ApiService().requestTopUp(amount, _selectedMethod, phone);
      
      debugPrint("[TOPUP] Server javobi: ${response.statusCode} - ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('So\'rov yuborildi. Admin tasdiqlashini kuting.'), backgroundColor: AppTheme.green),
          );
        }
      } else {
        throw "Server xatosi: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("[TOPUP] Xatolik yuz berdi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: AppTheme.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Bu padding klaviatura ochilganda formani yuqoriga chiqaradi
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111116), // Dark background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.honey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_card_rounded, color: AppTheme.honey, size: 24),
              ),
              const SizedBox(width: 16),
              Text("Balansni to'ldirish", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
            const SizedBox(height: 24),
            Text("To'ldirish summasi (UZS)", style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true, // Sahifa ochilishi bilan fokus tushadi
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.honey),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(color: Colors.white10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 24),
            Text("To'lov usuli", style: GoogleFonts.inter(fontSize: 13, color: Colors.white60)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _methods.map((m) {
                final bool isSelected = _selectedMethod == m['name'];
                return InkWell(
                  onTap: () => setState(() => _selectedMethod = m['name']!),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.honey.withOpacity(0.1) : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppTheme.honey : Colors.white10, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(m['icon']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(m['name']!, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.honey : Colors.white70)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.honey,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("Operatorga so'rov yuborish", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void showTopUpSheet(BuildContext context, AuthProvider auth) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TopUpSheet(auth: auth),
  );
}
