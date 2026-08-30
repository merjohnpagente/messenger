import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessengerTheme {
  // Exact Messenger color tokens
  static const Color messengerBlue = Color(0xFF0084FF);
  static const Color messengerBlueDark = Color(0xFF0B84FF);
  static const Color messengerGreen = Color(0xFF31A24C);
  static const Color messengerRed = Color(0xFFE04545);
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSecondaryBg = Color(0xFFF0F2F5);
  static const Color incomingBubble = Color(0xFFE4E6EB);
  static const Color textPrimary = Color(0xFF050505);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color dividerColor = Color(0xFFD8DADF);
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color darkSecondaryBg = Color(0xFF262626);
  static const Color darkIncomingBubble = Color(0xFF3A3B3C);
  static const Color darkDividerColor = Color(0xFF303031);
  static const Color storyGradientStart = Color(0xFF0084FF);
  static const Color storyGradientEnd = Color(0xFF1B74E4);

  static const List<Color> storyRing = [
    Color(0xFF00C6FF),
    Color(0xFF0084FF),
    Color(0xFF7F00FF),
  ];

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: messengerBlue,
      onPrimary: Colors.white,
      secondary: lightSecondaryBg,
      onSecondary: textPrimary,
      surface: lightBg,
      onSurface: textPrimary,
      outline: dividerColor,
    ),
    scaffoldBackgroundColor: lightBg,
    textTheme: GoogleFonts.robotoTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.roboto(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBg,
      selectedItemColor: messengerBlue,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(lightSecondaryBg),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: messengerBlue,
      onPrimary: Colors.white,
      secondary: darkSecondaryBg,
      onSecondary: Colors.white,
      surface: darkBg,
      onSurface: Colors.white,
      outline: darkDividerColor,
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.robotoTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.roboto(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFB0B3B8),
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFB0B3B8),
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF8A8D91),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: messengerBlue,
      unselectedItemColor: Color(0xFF8A8D91),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(darkSecondaryBg),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
    ),
  );
}