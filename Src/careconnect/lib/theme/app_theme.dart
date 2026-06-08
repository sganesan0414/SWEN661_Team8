import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1A3FB0);       // Deep blue - high contrast
  static const Color primaryLight = Color(0xFFE8EEFF);
  static const Color accent = Color(0xFF2D7DD2);

  // States
  static const Color success = Color(0xFF1A7A4A);       // Taken / complete
  static const Color successBg = Color(0xFFE6F5EE);
  static const Color warning = Color(0xFFB85C00);       // Due soon
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1A3FB0);
  static const Color infoBg = Color(0xFFE8EEFF);

  // Neutral colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F7);
  static const Color border = Color(0xFFCDD2E0);

  // Text with WCAG contrast
  static const Color textPrimary = Color(0xFF111827);   // 16:1 on white
  static const Color textSecondary = Color(0xFF374151); // 9:1 on white
  static const Color textMuted = Color(0xFF6B7280);     // 4.6:1 on white
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Alerts / Notifications
  static const Color alertBg = Color(0xFFFFF8E1);
  static const Color alertBorder = Color(0xFFE6A817);
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3,
    letterSpacing: -0.3,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, height: 1.4,
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      // Touch targets: >= 48dp 
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border, thickness: 1, space: 0,
      ),
    );
  }
}