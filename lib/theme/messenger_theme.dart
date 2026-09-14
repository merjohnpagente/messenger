import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:messenger/theme/app_tokens.dart';

class MessengerTheme {
  // Brand tokens — refreshed modern
  static const Color messengerBlue = Color(0xFF0084FF);
  static const Color messengerBlueDark = Color(0xFF0B84FF);
  static const Color messengerBlueLight = Color(0xFF339DFF);
  static const Color messengerGreen = Color(0xFF31A24C);
  static const Color messengerRed = Color(0xFFE04545);
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSecondaryBg = Color(0xFFF0F2F5);
  static const Color lightTertiaryBg = Color(0xFFE4E6EB);
  static const Color incomingBubble = Color(0xFFE4E6EB);
  static const Color textPrimary = Color(0xFF050505);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color dividerColor = Color(0xFFD8DADF);
  static const Color darkBg = Color(0xFF121214);
  static const Color darkSecondaryBg = Color(0xFF232324);
  static const Color darkTertiaryBg = Color(0xFF2D2D2F);
  static const Color darkIncomingBubble = Color(0xFF3A3B3C);
  static const Color darkDividerColor = Color(0xFF2A2A2E);
  static const Color storyGradientStart = Color(0xFF0084FF);
  static const Color storyGradientEnd = Color(0xFF1B74E4);
  static const Color glassBorderLight = Color(0x1A000000);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  static const List<Color> storyRing = [
    Color(0xFF00C6FF),
    Color(0xFF0084FF),
    Color(0xFF7F00FF),
  ];

  // Light Theme — modern M3 expressive, Inter font, refined tokens
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: messengerBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3F2FF),
      onPrimaryContainer: Color(0xFF001E3A),
      secondary: lightSecondaryBg,
      onSecondary: textPrimary,
      tertiary: Color(0xFF7F00FF),
      surface: lightBg,
      onSurface: textPrimary,
      surfaceContainerHighest: lightSecondaryBg,
      outline: dividerColor,
      outlineVariant: Color(0xFFE4E6EB),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFF),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.45, color: textSecondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3, color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF8FAFF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: const BorderSide(color: Color(0x0F000000))),
      shadowColor: const Color(0x14000000),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: messengerBlue,
      unselectedItemColor: textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0x140084FF),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: messengerBlue);
        }
        return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: messengerBlue, size: 24);
        return const IconThemeData(color: textSecondary, size: 24);
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0x140084FF),
      selectedIconTheme: IconThemeData(color: messengerBlue),
      unselectedIconTheme: IconThemeData(color: textSecondary),
      selectedLabelTextStyle: TextStyle(color: messengerBlue, fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelTextStyle: TextStyle(color: textSecondary, fontSize: 13),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSecondaryBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: messengerBlue, width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: messengerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: const Color(0x330084FF),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightSecondaryBg,
      selectedColor: messengerBlue,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE4E6EB), thickness: 1, space: 1),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(lightSecondaryBg),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
      hintStyle: WidgetStateProperty.all(GoogleFonts.inter(color: textSecondary, fontSize: 14)),
      textStyle: WidgetStateProperty.all(GoogleFonts.inter(fontSize: 14)),
    ),
  );

  // Dark Theme — deeper, M3, glass + Inter
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: messengerBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF004A8C),
      secondary: darkSecondaryBg,
      onSecondary: Colors.white,
      tertiary: Color(0xFFCE93FF),
      surface: darkBg,
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF232324),
      outline: darkDividerColor,
      outlineVariant: Color(0xFF3A3B3C),
    ),
    scaffoldBackgroundColor: darkBg,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white),
      displayMedium: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
      headlineSmall: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: Colors.white),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFB0B3B8)),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFB0B3B8)),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF8A8D91)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white, size: 22),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: const BorderSide(color: Color(0x14FFFFFF))),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: messengerBlue,
      unselectedItemColor: Color(0xFF8A8D91),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1C1C1E),
      indicatorColor: const Color(0x1A0084FF),
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: messengerBlue);
        return GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8A8D91));
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkBg,
      indicatorColor: Color(0x1A0084FF),
      selectedIconTheme: IconThemeData(color: messengerBlue),
      unselectedIconTheme: IconThemeData(color: Color(0xFF8A8D91)),
      selectedLabelTextStyle: TextStyle(color: messengerBlue, fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFF8A8D91), fontSize: 13),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSecondaryBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: messengerBlue, width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF8A8D91), fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: messengerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSecondaryBg,
      selectedColor: messengerBlue,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2A2A2E), thickness: 1, space: 1),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(darkSecondaryBg),
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
      hintStyle: WidgetStateProperty.all(GoogleFonts.inter(color: Color(0xFF8A8D91), fontSize: 14)),
    ),
  );
}