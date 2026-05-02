import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../app/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController(text: '+998');
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      await apiService.sendOtp(_controller.text.trim());
      if (mounted) {
        context.go('/otp', extra: _controller.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: MelariumTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: MelariumTheme.honey500.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MelariumTheme.honey500.withOpacity(0.3)),
                ),
                child: const Center(child: Text('🍯', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 24),
              const Text('MELARIUM', style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800,
                letterSpacing: 2, color: MelariumTheme.honey400,
              )),
              const SizedBox(height: 8),
              Text(
                'Invest in beekeeping colonies.\nEarn honey-backed returns.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),

              // Phone input
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Phone Number', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: MelariumTheme.honey500),
                  hintText: '+998901234567',
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _sendOtp,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MelariumTheme.forest700))
                    : const Text('Send OTP'),
              ),

              const SizedBox(height: 48),

              // Features
              Row(
                children: [
                  _featureTile('🐝', 'Live Tracking'),
                  const SizedBox(width: 12),
                  _featureTile('📈', 'Up to 25% ROI'),
                  const SizedBox(width: 12),
                  _featureTile('🍯', 'Honey or Cash'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center),
          ],
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
