import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const brand = Color(0xFF2966C7);
  static const brandDark = Color(0xFF174B9C);
  static const secondary = Color(0xFFE8F0FE);
  static const canvas = Color(0xFFF5F7FB);
  static const ink = Color(0xFF172B4D);
  static const muted = Color(0xFF7A8799);
  static const green = Color(0xFF16A36A);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFE05252);
  static const border = Color(0xFFE8EDF4);
  static const paid = Color(0xFFE5F6ED);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      surface: Colors.white,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
    );
    return _base(scheme, scaffold: AppColors.canvas);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.dark,
      primary: const Color(0xFF9DC0FF),
      surface: const Color(0xFF1A2333),
    );
    return _base(scheme, scaffold: const Color(0xFF0E141D));
  }

  static ThemeData _base(ColorScheme scheme, {required Color scaffold}) {
    final isDark = scheme.brightness == Brightness.dark;
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: isDark ? scheme.outlineVariant : AppColors.border,
      ),
    );
    final text = Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: isDark ? null : text,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: rounded,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? scheme.outlineVariant : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? scheme.outlineVariant : AppColors.border,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.brand, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 8,
        height: 72,
        indicatorColor: isDark
            ? AppColors.brand.withValues(alpha: 0.28)
            : AppColors.secondary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }
}
