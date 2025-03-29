import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppThemeConfig {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(AppTheme.primaryColor),
          secondary: Color(AppTheme.accentColor),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          background: Color(AppTheme.backgroundColor),
          surface: Color(AppTheme.surfaceColor),
          error: Color(AppTheme.errorColor),
        ),
        textTheme: _getTextTheme(),
        fontFamily: GoogleFonts.roboto().fontFamily,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(AppTheme.primaryColor),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: UiConstants.fontSizeXl,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppTheme.primaryColor),
            side: const BorderSide(color: Color(AppTheme.primaryColor)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.cardRadius),
          ),
          margin: const EdgeInsets.all(UiConstants.paddingS),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide: const BorderSide(color: Color(AppTheme.textSecondary)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide:
                const BorderSide(color: Color(AppTheme.primaryColor), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide: const BorderSide(color: Color(AppTheme.errorColor)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: UiConstants.paddingM,
            horizontal: UiConstants.paddingM,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(AppTheme.surfaceColor),
          contentTextStyle: const TextStyle(color: Color(AppTheme.textPrimary)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.cardRadius),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(AppTheme.primaryColor),
          secondary: Color(AppTheme.accentColor),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          error: Color(AppTheme.errorColor),
        ),
        textTheme: _getTextTheme(isDark: true),
        fontFamily: GoogleFonts.roboto().fontFamily,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: UiConstants.fontSizeXl,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(AppTheme.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppTheme.primaryColor),
            side: const BorderSide(color: Color(AppTheme.primaryColor)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: UiConstants.paddingM,
              horizontal: UiConstants.paddingL,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.cardRadius),
          ),
          margin: const EdgeInsets.all(UiConstants.paddingS),
          color: const Color(0xFF1E1E1E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide: const BorderSide(color: Color(0xFF666666)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide:
                const BorderSide(color: Color(AppTheme.primaryColor), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.buttonRadius),
            borderSide: const BorderSide(color: Color(AppTheme.errorColor)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: UiConstants.paddingM,
            horizontal: UiConstants.paddingM,
          ),
          fillColor: const Color(0xFF2C2C2C),
          filled: true,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF2C2C2C),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.cardRadius),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static TextTheme _getTextTheme({bool isDark = false}) {
    final Color textColor =
        isDark ? Colors.white : const Color(AppTheme.textPrimary);
    final Color secondaryTextColor =
        isDark ? const Color(0xFFB0B0B0) : const Color(AppTheme.textSecondary);

    return TextTheme(
      displayLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 12,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
