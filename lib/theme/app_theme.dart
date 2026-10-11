import 'package:flutter/material.dart';

/// AniWorthy's dark "midnight arcade" theme.
class AppTheme {
  const AppTheme._();

  static const Color bg = Color(0xFF0E0B1F);
  static const Color surface = Color(0xFF181330);
  static const Color surfaceAlt = Color(0xFF221B44);
  static const Color divider = Color(0xFF2E2656);
  static const Color text = Color(0xFFF1ECFF);
  static const Color muted = Color(0xFFA79FD0);
  static const Color accent = Color(0xFFFF4F9D); // pink
  static const Color accent2 = Color(0xFF7C5CFF); // violet
  static const Color gold = Color(0xFFFFC24B);
  static const Color good = Color(0xFF34D399);
  static const Color bad = Color(0xFFF87171);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[accent, accent2],
  );

  static ThemeData dark() {
    final ColorScheme scheme = const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      surface: surface,
      onSurface: text,
    );

    final TextTheme textTheme = Typography.whiteMountainView.apply(
      bodyColor: text,
      displayColor: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: divider,
      iconTheme: const IconThemeData(color: text),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0B0919),
        indicatorColor: accent.withValues(alpha: 0.22),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? text : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent2 : muted,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
