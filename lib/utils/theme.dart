import 'package:flutter/material.dart';

class AppTheme {
  // iOS-style dark theme based on Penpot design
  static const Color iosBackground = Color(0xFF000000); // black
  static const Color iosSecondaryBackground = Color(0xFF1C1C1E); // dark gray
  static const Color iosTertiaryBackground = Color(0xFF2C2C2E); // darker gray
  static const Color iosAccentPurple = Color(0xFF896CFE); // purple accent
  static const Color iosAccentLime = Color(0xFFE2F163); // lime green accent
  static const Color iosLabel = Color(0xFFFFFFFF); // white text
  static const Color iosSecondaryLabel = Color(0xFFEBEBF5); // light gray text
  static const Color iosTertiaryLabel = Color(0x99EBEBF5); // lighter gray text (with alpha)
  static const Color iosSeparator = Color(0xFF38383A); // separator color
  static const Color iosSystemBlue = Color(0xFF0A84FF);
  static const Color iosSystemGreen = Color(0xFF30D158);
  static const Color errorColor = Color(0xFFE53935);
  
  // Legacy colors for compatibility
  static const Color primaryColor = iosAccentPurple;
  static const Color primaryDark = iosBackground;
  static const Color backgroundColor = iosBackground;
  static const Color surfaceColor = iosSecondaryBackground;
  static const Color textMain = iosLabel;
  static const Color textSub = iosSecondaryLabel;
  static const Color borderIndigo = iosSeparator;
  static const Color successColor = iosSystemGreen;
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: iosAccentPurple,
      secondary: iosAccentLime,
      surface: iosSecondaryBackground,
      background: iosBackground,
      error: errorColor,
      onPrimary: iosLabel,
      onSecondary: iosBackground,
      onSurface: iosLabel,
      onBackground: iosLabel,
    ),
    scaffoldBackgroundColor: iosBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: iosLabel,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: iosLabel),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: iosSecondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: iosSeparator, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: iosAccentLime,
        foregroundColor: iosBackground,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          fontFamily: 'Inter',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: iosSecondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: iosSeparator, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: iosSeparator, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: iosAccentPurple, width: 1),
      ),
      labelStyle: const TextStyle(
        color: iosLabel,
        fontSize: 13,
        fontFamily: 'Inter',
      ),
      hintStyle: const TextStyle(
        color: iosTertiaryLabel,
        fontSize: 17,
        fontFamily: 'Inter',
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: iosLabel,
        letterSpacing: 0.37,
        fontFamily: 'Inter',
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: iosLabel,
        letterSpacing: 0.36,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: iosLabel,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: iosLabel,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        color: iosLabel,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: iosSecondaryLabel,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: iosTertiaryLabel,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: iosLabel,
        fontFamily: 'Inter',
      ),
    ),
    fontFamily: 'Inter',
  );
  
  // Use same theme for dark mode (iOS-style dark theme)
  static ThemeData darkTheme = lightTheme;
}
