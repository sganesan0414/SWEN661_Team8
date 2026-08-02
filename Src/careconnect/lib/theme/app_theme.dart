import 'package:flutter/material.dart';

import 'app_motion.dart';

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

  // Destructive actions (cancel, delete, emergency). Darker than Colors.red so
  // it clears 4.5:1 on white for the small text it labels.
  static const Color danger = Color(0xFFC62828);
  static const Color dangerBg = Color(0xFFFDECEA);

  // Accent used for appointment-flavoured surfaces across screens.
  static const Color appointment = Color(0xFF7B3FA0);
}

/// Corner radii. Cards and sheets share one scale so surfaces at the same
/// altitude read as the same kind of object.
class AppRadius {
  /// Chips, badges, small inline containers.
  static const double small = 8;

  /// Buttons, inputs, inner containers.
  static const double medium = 12;

  /// Cards and list items — the app's default surface.
  static const double large = 16;

  /// Hero panels and bottom sheets.
  static const double xLarge = 20;

  /// Fully rounded pills.
  static const double pill = 999;
}

/// Vertical/horizontal rhythm on a 4pt grid.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 32;

  /// Standard screen edge padding.
  static const EdgeInsets screen = EdgeInsets.all(xl);
}

/// Sizing constants shared across screens.
class AppSizing {
  /// Minimum interactive target (WCAG 2.1 SC 2.5.5).
  static const double minTouchTarget = 48;

  /// Primary action button height.
  static const double buttonHeight = 56;

  /// Width reserved in an AppBar for [LabeledBackButton]'s "Return to X" label.
  /// Shared so every screen's back affordance lines up and none of them clip.
  static const double backButtonWidth = 170;
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
        surface: AppColors.surface,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      // One navigation transition on every platform, so a push feels the same
      // wherever the app runs.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
          TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
        },
      ),
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
      // Every snackbar in the app was styled at its call site, so some floated
      // with rounded corners and most were square and edge-to-edge. Setting it
      // once here makes them uniform.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        actionTextColor: const Color(0xFF9FC0FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xLarge),
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xLarge),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMedium,
          minimumSize: const Size(AppSizing.minTouchTarget, AppSizing.minTouchTarget),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : null,
        ),
      ),
    );
  }
}