import 'package:flutter/material.dart';

/// Palette sampled from the reference recording.
///
/// The warm off-white ground and the single orange accent are what make the
/// product photography read as food rather than as UI chrome — everything
/// structural is neutral so the pizzas carry all of the colour.
class AppColors {
  const AppColors._();

  static const Color orange = Color(0xFFFF6A2B);
  static const Color orangeSoft = Color(0xFFFFE7DB);
  static const Color ink = Color(0xFF15130F);
  static const Color inkSoft = Color(0xFF3A3733);
  static const Color muted = Color(0xFF9A948C);
  static const Color hairline = Color(0xFFE8E4DE);
  static const Color background = Color(0xFFF7F5F1);
  static const Color panel = Color(0xFFEDEAE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color navBar = Color(0xFF1B1917);
  static const Color success = Color(0xFF22B473);
  static const Color star = Color(0xFFFFA51F);
}

/// Corner radii. Pizzafy uses a small set of large radii — mixing many radii is
/// the fastest way to make a food app look generic.
class Radii {
  const Radii._();
  static const double card = 26;
  static const double chip = 100;
  static const double sheet = 32;
  static const double field = 18;
}

/// Soft, low-contrast elevation. Food UI wants light to feel ambient; hard
/// drop shadows read as Material chrome and fight the photography.
class Shadows {
  const Shadows._();

  static List<BoxShadow> get card => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF6B5A47).withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get lifted => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF6B5A47).withValues(alpha: 0.13),
          blurRadius: 34,
          offset: const Offset(0, 16),
        ),
      ];

  /// Cast under a flying or floating pizza.
  static List<BoxShadow> get pizza => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF4A2F16).withValues(alpha: 0.22),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ];
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    const ColorScheme scheme = ColorScheme.light(
      primary: AppColors.orange,
      onPrimary: Colors.white,
      secondary: AppColors.ink,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: Color(0xFFD64545),
      onError: Colors.white,
    );

    final TextTheme text = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        height: 1.12,
        letterSpacing: -1.0,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 23,
        height: 1.2,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.25,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: AppColors.inkSoft,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        height: 1.45,
        color: AppColors.muted,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: AppColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      // Every route in the app uses an explicit transition from
      // `page_transitions.dart`; the platform default would flatten them.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{},
      ),
    );
  }
}
