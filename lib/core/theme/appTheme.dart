import 'package:flutter/material.dart';

class AppTheme {
  // -------------------- Color Palette (Extended for Web Felt UI) --------------------
  static const Color primaryGold = Color(
    0xFFD4AF37,
  ); // Luxury typography, branding
  static const Color darkGold = Color(0xFFB8902E);

  // Primary Action Color – Glowing Emerald (JOIN buttons)
  static const Color emeraldGreen = Color(
    0xFF0F6244,
  ); // Solid emerald for buttons
  static const Color emeraldHover = Color(0xFF138058); // Lighter hover state
  static const Color darkEmerald = Color(0xFF1E5A3A);

  // Felt Background Gradient Colors (Radial)
  static const Color feltCenter = Color(
    0xFF0F6244,
  ); // Vibrant forest green center
  static const Color feltEdge = Color(0xFF020A06); // Near‑black outer edges

  // Surface Layers (as per web design)
  static const Color panelSurface = Color(
    0xFF0A1811,
  ); // Dark olive‑charcoal panels
  static const Color rowSurface = Color(
    0xFF0E1F16,
  ); // Slightly lighter for rows
  static const Color panelBorder = Color(0xFF1A3326); // Thin borders

  // Legacy aliases (keep existing code working)
  static const Color pureBlack = Color(0xFF000000);
  static const Color richBlack = Color(0xFF0A0A0A);
  static const Color surface = panelSurface; // Alias for panelSurface
  static const Color elevatedSurface = rowSurface; // Alias for rowSurface
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color whiteAccent = Color(0xFFFFFFFF);

  // System Status Color (Online indicators)
  static const Color statusGreen = Color(
    0xFF4ADE80,
  ); // Bright green for online count

  // State colors
  static const Color win = Color(0xFF4CAF50);
  static const Color lose = Color(0xFFE53935);
  static const Color highlightGold = Color(0xFFFFD700);

  // Shimmer colors (for loading)
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = primaryGold;

  // -------------------- New: Radial Felt Background --------------------
  static const RadialGradient feltBackgroundGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.7,
    colors: [
      Color.fromARGB(255, 3, 78, 50), // Vibrant green center
      Color(0xFF061A10), // Transition olive‑dark
      feltEdge, // Near‑black edges
    ],
    stops: [0.0, 0.6, 1.0],
  );

  // Keep old linear gradient for backwards compatibility if needed
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121212), Color(0xFF0A0A0A), Color(0xFF1C3A27)],
    stops: [0.0, 0.5, 1.0],
  );

  // -------------------- Typography --------------------
  static const String fontFamily = 'Poppins';
  static const String fallbackFont = 'Montserrat';

  static const TextStyle tableHeaderStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF8A7A5F),
    letterSpacing: 1.0,
  );

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
    color: whiteAccent, // White text on emerald buttons
  );

  static const TextStyle captionGold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryGold,
  );

  // -------------------- Theme Generation --------------------
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryGold,
      onPrimary: pureBlack,
      secondary: emeraldGreen, // Emerald for secondary actions
      onSecondary: whiteAccent,
      error: lose,
      onError: whiteAccent,
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
        titleMedium: headingSmall,
        bodyLarge: bodyText,
        bodyMedium: bodyText,
        labelLarge: buttonText,
        titleSmall: captionGold,
      ),

      // ✨ UPDATED: Emerald JOIN buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: whiteAccent,
          backgroundColor: emeraldGreen,
          textStyle: buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Pill‑shaped like web
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: buttonText.copyWith(color: primaryGold),
          side: const BorderSide(color: primaryGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureBlack.withOpacity(0.3),
        hintStyle: const TextStyle(color: Color(0xFF718096), fontSize: 14),
        prefixIconColor: const Color(0xFF718096),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF1A3326)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF1A3326)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryGold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: primaryGold),
      ),

      // Card theme matches panel surface with subtle border
      cardTheme: CardThemeData(
        color: panelSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF11251A), width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: panelSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: headingMedium,
        contentTextStyle: bodyText,
        elevation: 8,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: rowSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: panelSurface,
        contentTextStyle: bodyText,
        actionTextColor: primaryGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: panelSurface,
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
