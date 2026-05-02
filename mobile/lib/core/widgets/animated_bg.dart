import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated hexagonal grid + floating particles background
class AnimatedBg extends StatefulWidget {
  final Widget child;
  const AnimatedBg({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBg> createState() => _AnimatedBgState();
}

class _AnimatedBgState extends State<AnimatedBg> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Base gradient
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 1.5,
              colors: [Color(0xFF111115), Color(0xFF08080A), Color(0xFF050507)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
      // Animated glow orbs
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BgPainter(_ctrl.value),
        ),
      ),
      // Content
      widget.child,
    ]);
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle golden glow orbs
    final orbPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Orb 1 — top right
    orbPaint.color = AppTheme.honey.withAlpha(8);
    canvas.drawCircle(
      Offset(w * 0.8 + sin(t * 2 * pi) * 30, h * 0.15 + cos(t * 2 * pi) * 20),
      120, orbPaint,
    );

    // Orb 2 — bottom left
    orbPaint.color = AppTheme.honey.withAlpha(6);
    canvas.drawCircle(
      Offset(w * 0.2 + cos(t * 2 * pi + 1) * 25, h * 0.7 + sin(t * 2 * pi + 1) * 30),
      150, orbPaint,
    );

    // Floating particles
    final dotPaint = Paint()..color = AppTheme.honey.withAlpha(30);
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * w;
      final baseY = rng.nextDouble() * h;
      final speed = 0.5 + rng.nextDouble() * 1.5;
      final y = (baseY + t * h * speed) % (h + 20) - 10;
      final radius = 1.0 + rng.nextDouble() * 1.5;
      dotPaint.color = AppTheme.honey.withAlpha(15 + rng.nextInt(25));
      canvas.drawCircle(Offset(x + sin(t * 2 * pi + i) * 5, y), radius, dotPaint);
    }

    // Subtle hexagon outlines
    final hexPaint = Paint()
      ..color = AppTheme.honey.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 5; i++) {
      final cx = rng.nextDouble() * w;
      final cy = rng.nextDouble() * h;
      final r = 30.0 + rng.nextDouble() * 40;
      final angle = t * 2 * pi * 0.1 + i;
      _drawHex(canvas, Offset(cx, cy), r, angle, hexPaint);
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius, double rotation, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = rotation + (pi / 3) * i;
      final p = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
