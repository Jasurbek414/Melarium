import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../services/api_service.dart';
import '../app/theme.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _resendOtp();
  }

  Future<void> _resendOtp() async {
    try {
      final data = await apiService.sendOtp(widget.phone);
      setState(() => _devOtp = data['otpCode'] as String?);
    } catch (_) {}
  }

  Future<void> _verifyOtp() async {
    if (_controller.text.length != 6) return;
    setState(() => _loading = true);
    try {
      final data = await apiService.verifyOtp(widget.phone, _controller.text.trim());
      final box = Hive.box('auth');
      await box.put('accessToken',  data['accessToken']);
      await box.put('refreshToken', data['refreshToken']);
      await box.put('role',         data['role']);
      await box.put('userId',       data['userId']);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP'), backgroundColor: MelariumTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Enter the code sent to', style: Theme.of(context).textTheme.bodyMedium),
              Text(widget.phone, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: MelariumTheme.honey400)),
              const SizedBox(height: 32),

              // DEV: Show OTP
              if (_devOtp != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MelariumTheme.honey500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MelariumTheme.honey500.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('[DEV] Your OTP:', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text(_devOtp!, style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        letterSpacing: 8, color: MelariumTheme.honey400,
                      )),
                    ],
                  ),
                ),

              // OTP Input
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 10, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                ),
                onChanged: (v) { if (v.length == 6) _verifyOtp(); },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: (_loading || _controller.text.length != 6) ? null : _verifyOtp,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MelariumTheme.forest700))
                    : const Text('Verify & Login'),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend OTP', style: TextStyle(color: MelariumTheme.honey400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
