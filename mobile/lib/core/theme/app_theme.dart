import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color honey = Color(0xFFEEB012);
  static const Color honeyLight = Color(0xFFFFCF33);
  static const Color honeyDark = Color(0xFFCB8504);
  static const Color darkBg = Color(0xFF08080A);
  static const Color darkCard = Color(0xFF111115);
  static const Color darkBorder = Color(0xFF1C1C22);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color muted = Color(0xFF55555F);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: honey,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: honey,
        secondary: honeyLight,
        surface: darkCard,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF15151A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF33333A), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF3A3A44), fontSize: 15),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CUSTOM BUTTON — replaces ElevatedButton to avoid
//  diagonal stripe rendering artifact on some devices
// ═══════════════════════════════════════════════════════
class MelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool outlined;

  const MelButton({Key? key, required this.onPressed, required this.child, this.outlined = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (disabled ? AppTheme.honey.withAlpha(80) : AppTheme.honey),
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: AppTheme.darkBorder) : null,
        ),
        child: DefaultTextStyle(
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: outlined ? Colors.white : Colors.black,
          ),
          child: IconTheme(
            data: IconThemeData(color: outlined ? Colors.white : Colors.black, size: 18),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── REUSABLE GLASS CARD ──────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({Key? key, required this.child, this.padding, this.margin, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: child,
      ),
    );
  }
}

// ─── STAT BOX ─────────────────────────────────────────
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const StatBox({Key? key, required this.label, required this.value, this.valueColor, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.muted),
            const SizedBox(height: 10),
          ],
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.muted, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}
