import 'package:flutter/material.dart';

class VeluneColors {
  static const Color primaryNavy = Color(0xFF1B2F5B);
  static const Color deepNavy = Color(0xFF0F1F44);
  static const Color accentBlue = Color(0xFF2F6BFF);
  static const Color skyBlue = Color(0xFFEBF2FF);
  static const Color background = Color(0xFFF4F7FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF475467);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color border = Color(0xFFE3E9F4);

  static const Color success = Color(0xFF12B76A);
  static const Color successBg = Color(0xFFE6F8EF);
  static const Color warning = Color(0xFFF79009);
  static const Color warningBg = Color(0xFFFFF4E0);
  static const Color danger = Color(0xFFD92D20);
  static const Color dangerBg = Color(0xFFFEECEB);

  // Gradient
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF1B2F5B), Color(0xFF0F1F44)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2F6BFF), Color(0xFF1E4FD9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class VeluneTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VeluneColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VeluneColors.primaryNavy,
        primary: VeluneColors.primaryNavy,
        secondary: VeluneColors.accentBlue,
        surface: VeluneColors.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: VeluneColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: VeluneColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: VeluneColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: VeluneColors.border, width: 1),
        ),
      ),
    );
  }
}
