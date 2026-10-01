import 'package:flutter/material.dart';

/// Taper design tokens — warm coffee-inspired palette.
class AppColors {
  final Color bg, surface, surface2, ink, inkMuted, line, line2;
  final Color coffee, coffeeSoft, accent, accentSoft;
  final Color warn, warnSoft, danger, dangerSoft, ring;
  final Brightness brightness;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.line2,
    required this.coffee,
    required this.coffeeSoft,
    required this.accent,
    required this.accentSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.ring,
    required this.brightness,
  });

  static const light = AppColors(
    bg: Color(0xFFF6F1E9),
    surface: Color(0xFFFFFCF7),
    surface2: Color(0xFFEFE6D8),
    ink: Color(0xFF2A211B),
    inkMuted: Color(0xFF8A7B6D),
    line: Color(0x172A211B),
    line2: Color(0x242A211B),
    coffee: Color(0xFF7A5B44),
    coffeeSoft: Color(0xFFE7D9C8),
    accent: Color(0xFF2F7D62),
    accentSoft: Color(0xFFD9EBE2),
    warn: Color(0xFFB5762F),
    warnSoft: Color(0xFFF3E6D2),
    danger: Color(0xFFA8483C),
    dangerSoft: Color(0xFFF4DFDB),
    ring: Color(0xFFE4D8C6),
    brightness: Brightness.light,
  );

  static const dark = AppColors(
    bg: Color(0xFF171310),
    surface: Color(0xFF211C18),
    surface2: Color(0xFF2B2520),
    ink: Color(0xFFF2EBE2),
    inkMuted: Color(0xFF9E9083),
    line: Color(0x17F2EBE2),
    line2: Color(0x26F2EBE2),
    coffee: Color(0xFFC9A183),
    coffeeSoft: Color(0xFF342A22),
    accent: Color(0xFF5AAE8B),
    accentSoft: Color(0xFF1E332B),
    warn: Color(0xFFD79A4E),
    warnSoft: Color(0xFF332818),
    danger: Color(0xFFD4756A),
    dangerSoft: Color(0xFF33201D),
    ring: Color(0xFF332C25),
    brightness: Brightness.dark,
  );
}

class AppTheme extends InheritedWidget {
  final AppColors colors;
  const AppTheme({super.key, required this.colors, required super.child});

  static AppColors of(BuildContext context) {
    final t = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    return t?.colors ?? AppColors.light;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => oldWidget.colors != colors;
}

extension AppColorsX on BuildContext {
  AppColors get colors => AppTheme.of(this);
}

class AppText {
  static TextStyle display(Color c) => TextStyle(
      fontSize: 52,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.6,
      height: 1.0,
      color: c);
  static TextStyle h1(Color c) => TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.15,
      color: c);
  static TextStyle h2(Color c) => TextStyle(
      fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: c);
  static TextStyle h3(Color c) => TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
      color: c);
  static TextStyle body(Color c) =>
      TextStyle(fontSize: 14.5, height: 1.45, color: c);
  static TextStyle label(Color c) =>
      TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c);
  static TextStyle tiny(Color c) =>
      TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c);
  static TextStyle button(Color c) => TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.1, color: c);
  static TextStyle num(Color c, double size) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      height: 1.0,
      color: c);
}

const rXL = Radius.circular(22);
const rSheet = Radius.circular(28);
const rBtn = Radius.circular(18);
const rChip = Radius.circular(99);
