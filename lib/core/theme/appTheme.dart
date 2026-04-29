import 'package:flutter/material.dart';

class AppTheme {
  // -------------------- Color Palette --------------------
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8902E);
  static const Color emeraldGreen = Color(0xFF2E8B57);
  static const Color darkEmerald = Color(0xFF1E5A3A);
  static const Color pureBlack = Color(0xFF000000);
  static const Color richBlack = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF121212);
  static const Color elevatedSurface = Color(0xFF1A1A1A);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color whiteAccent = Color(0xFFFFFFFF);

  // State colors
  static const Color win = Color(0xFF4CAF50);
  static const Color lose = Color(0xFFE53935);
  static const Color highlightGold = Color(0xFFFFD700);

  // Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [richBlack, Color(0xFF0E1A0E)],
  );

  // Shimmer colors (for loading)
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = primaryGold;

  // -------------------- Typography --------------------
  static const String fontFamily = 'Poppins';
  static const String fallbackFont = 'Montserrat';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryGold,
    letterSpacing: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 0.8,
  );

  // Added headingSmall for game over and similar UI
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 0.6,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: offWhite,
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: pureBlack,
  );

  static const TextStyle captionGold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryGold,
  );

  // -------------------- Theme --------------------
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryGold,
      onPrimary: pureBlack,
      secondary: emeraldGreen,
      onSecondary: whiteAccent,
      error: lose,
      onError: whiteAccent,
      background: richBlack,
      onBackground: offWhite,
      surface: surface,
      onSurface: offWhite,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: richBlack,
      canvasColor: richBlack,
      cardColor: surface,
      dividerColor: primaryGold.withOpacity(0.3),

      appBarTheme: const AppBarTheme(
        backgroundColor: pureBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMedium,
        iconTheme: IconThemeData(color: primaryGold),
      ),

      textTheme: const TextTheme(
        displayLarge: headingLarge,
        headlineMedium: headingMedium,
        titleMedium: headingSmall, // maps to titleMedium
        bodyLarge: bodyText,
        bodyMedium: bodyText,
        labelLarge: buttonText,
        titleSmall: captionGold,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: pureBlack,
          backgroundColor: primaryGold,
          textStyle: buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: primaryGold.withOpacity(0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: buttonText,
          side: const BorderSide(color: primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryGold),
        hintStyle: const TextStyle(color: offWhite, fontSize: 14),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: headingMedium,
        contentTextStyle: bodyText,
        elevation: 8,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: bodyText,
        actionTextColor: primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: bodyText,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGold,
        unselectedLabelColor: offWhite,
        indicatorColor: primaryGold,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureBlack,
        selectedItemColor: primaryGold,
        unselectedItemColor: offWhite,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
