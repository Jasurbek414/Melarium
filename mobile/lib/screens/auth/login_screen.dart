import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 5) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().sendOtp(phone);
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpScreen()));
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
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.hexagon_outlined, size: 30, color: AppTheme.honey),
                      const SizedBox(width: 10),
                      Text('MELARIUM', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 6)),
                    ]),
                  ),
                  const SizedBox(height: 56),
                  Text('Xush\nKelibsiz', style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.w800, height: 1.15)),
                  const SizedBox(height: 8),
                  const Text('Hisobingizga kirish uchun telefon raqamingizni kiriting.', style: TextStyle(fontSize: 15, color: AppTheme.muted)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '+998 90 123 45 67',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.phone_outlined, size: 20, color: AppTheme.muted),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  MelButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('Davom etish'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18),
                          ]),
                  ),
                  const Spacer(flex: 3),
                  const Center(child: Text('Davom etish orqali Foydalanish shartlariga rozilik bildirasiz', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF333338)))),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
