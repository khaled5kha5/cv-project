import 'package:flutter/material.dart';

class AppTheme {
  // ─── Light Palette ────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF111318);
  static const Color accent       = Color(0xFF0ABFBC);
  static const Color background   = Color(0xFFF5F6F8);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color border       = Color(0xFFE2E5EA);
  static const Color textPrimary  = Color(0xFF0D0F14);
  static const Color textMuted    = Color(0xFF6B7280);

  // ─── Dark Palette ─────────────────────────────────────────────────────────
  static const Color darkPrimary     = Color(0xFF0ABFBC);   // accent becomes primary CTA
  static const Color darkAccent      = Color(0xFF0ABFBC);
  static const Color darkBackground  = Color(0xFF0D0F14);
  static const Color darkSurface     = Color(0xFF161A22);
  static const Color darkSurface2    = Color(0xFF1E2330);   // elevated cards
  static const Color darkBorder      = Color(0xFF2A2F3D);
  static const Color darkTextPrimary = Color(0xFFF0F2F5);
  static const Color darkTextMuted   = Color(0xFF8B93A5);

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    scaffoldBg: background,
    appBarBg: surface,
    appBarFg: textPrimary,
    labelColor: textMuted,
    hintColor: textMuted,
    fieldFill: surface,
    fieldBorder: border,
    cardColor: surface,
    cardBorder: border,
    dividerColor: border,
    snackBg: primary,
    switchThumb: (s) =>
        s.contains(WidgetState.selected) ? accent : const Color(0xFFD1D5DB),
    switchTrack: (s) =>
        s.contains(WidgetState.selected) ? accent.withOpacity(0.25) : const Color(0xFFEFF1F5),
    progressTrack: const Color(0xFFEFF1F5),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge:     TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge:      TextStyle(fontSize: 16, color: textPrimary, height: 1.6),
      bodyMedium:     TextStyle(fontSize: 14, color: textMuted,   height: 1.5),
      labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
    ),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: darkAccent,
      secondary: darkAccent,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    scaffoldBg: darkBackground,
    appBarBg: darkSurface,
    appBarFg: darkTextPrimary,
    labelColor: darkTextMuted,
    hintColor: darkTextMuted,
    fieldFill: darkSurface2,
    fieldBorder: darkBorder,
    cardColor: darkSurface,
    cardBorder: darkBorder,
    dividerColor: darkBorder,
    snackBg: darkSurface2,
    switchThumb: (s) =>
        s.contains(WidgetState.selected) ? darkAccent : const Color(0xFF3A3F4E),
    switchTrack: (s) =>
        s.contains(WidgetState.selected) ? darkAccent.withOpacity(0.25) : const Color(0xFF252A38),
    progressTrack: const Color(0xFF252A38),
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: darkTextPrimary, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkTextPrimary),
      titleLarge:     TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: darkTextPrimary),
      bodyLarge:      TextStyle(fontSize: 16, color: darkTextPrimary, height: 1.6),
      bodyMedium:     TextStyle(fontSize: 14, color: darkTextMuted,   height: 1.5),
      labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPrimary),
    ),
  );

  // ─── Shared Builder ───────────────────────────────────────────────────────
  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color appBarBg,
    required Color appBarFg,
    required Color labelColor,
    required Color hintColor,
    required Color fieldFill,
    required Color fieldBorder,
    required Color cardColor,
    required Color cardBorder,
    required Color dividerColor,
    required Color snackBg,
    required Color Function(Set<WidgetState>) switchThumb,
    required Color Function(Set<WidgetState>) switchTrack,
    required Color progressTrack,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: appBarFg,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: appBarFg),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        labelStyle: TextStyle(color: labelColor, fontSize: 14),
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIconColor: labelColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appBarFg,
          side: BorderSide(color: fieldBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorder),
        ),
      ),

      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(switchThumb),
        trackColor: WidgetStateProperty.resolveWith(switchTrack),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: progressTrack,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBg,
        contentTextStyle: TextStyle(
          color: brightness == Brightness.dark ? darkTextPrimary : Colors.white,
          fontSize: 14,
        ),
        actionTextColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
