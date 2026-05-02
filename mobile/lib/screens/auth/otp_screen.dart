import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _selectedRoleIndex = 0;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verify() async {
    if (_otp.length < 4) return;
    setState(() => _isLoading = true);
    try {
      final role = _selectedRoleIndex == 0 ? UserRole.INVESTOR : UserRole.BEEKEEPER;
      await context.read<AuthProvider>().verifyOtp(_otp, role);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.darkBorder)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                ),
                const SizedBox(height: 36),
                Text('Tasdiqlash', style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Telefon raqamingizga yuborilgan 6 xonali kodni kiriting.', style: TextStyle(fontSize: 15, color: AppTheme.muted)),
                const SizedBox(height: 36),

                // ── OTP Boxes ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => SizedBox(
                    width: 48, height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppTheme.darkCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.darkBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF33333A), width: 1.5)),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                        if (val.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                      },
                    ),
                  )),
                ),
                const SizedBox(height: 28),

                // ── Role Toggle ──
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.darkBorder)),
                  child: Row(children: [
                    _roleTab('Investor', 0),
                    _roleTab('Asalarichi', 1),
                  ]),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verify,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('Tasdiqlash'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18),
                          ]),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Kodni qayta yuborish', style: TextStyle(color: AppTheme.honey, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String label, int idx) {
    final isActive = _selectedRoleIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleIndex = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E1E25) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? AppTheme.honey : AppTheme.muted)),
        ),
      ),
    );
  }
}
