import 'package:flutter/material.dart';

/// Professional SaaS Dark Theme Tokens for Admin Operations & Dashboard
class AdminTheme {
  // --- COLOR PALETTE ---
  static const Color bgWorkspace = Color(0xFF0D1117); // Canvas / Main content area
  static const Color bgSidebar = Color(0xFF080B10); // Persistent navigation sidebar
  static const Color surfaceCard = Color(0xFF161B22); // Cards, data tables, panels
  static const Color surfaceElevated = Color(0xFF21262D); // Modals, popovers, dropdowns
  static const Color surfaceHover = Color(0xFF292E36); // Interactive hover row states

  static const Color borderSubtle = Color(0xFF30363D); // Clean 1px dividers & borders
  static const Color borderStrong = Color(0xFF484F58); // Focused inputs / active boundaries

  // Accent Colors (Electric Sky Blue SaaS Branding)
  static const Color accent = Color(0xFF38BDF8); // Primary action & selection highlight
  static const Color accentHover = Color(0xFF0EA5E9);
  static const Color accentSubtle = Color(0x2638BDF8); // 15% tint for pills/metrics

  // Typography Colors
  static const Color textPrimary = Color(0xFFF0F6FC); // High contrast crisp white
  static const Color textSecondary = Color(0xFF8B949E); // Slate metadata & subheaders
  static const Color textMuted = Color(0xFF6E7681); // Subtle labels & table headers
  static const Color textDisabled = Color(0xFF484F58);

  // Status Indicators
  static const Color statusSuccess = Color(0xFF2EA043); // Vibrant green
  static const Color statusWarning = Color(0xFFD29922); // Amber
  static const Color statusError = Color(0xFFF85149); // Crimson
  static const Color statusInfo = Color(0xFF58A6FF); // Bright blue

  // --- TYPOGRAPHY STYLES ---
  static const TextStyle display = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.4,
    color: textPrimary,
    height: 1.25,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: textPrimary,
    height: 1.35,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textMuted,
    height: 1.4,
  );

  static const TextStyle metricLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textMuted,
  );

  // --- FLUTTER THEMEDATA ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgWorkspace,
      primaryColor: accent,
      canvasColor: bgSidebar,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: bgSidebar,
        secondary: accent,
        onSecondary: bgSidebar,
        surface: surfaceCard,
        onSurface: textPrimary,
        error: statusError,
        onError: textPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSidebar,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: title,
        iconTheme: IconThemeData(color: textPrimary, size: 20),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSidebar,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: statusError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: statusError, width: 1.5),
        ),
        errorStyle: const TextStyle(color: statusError, fontSize: 11),
      ),

      // Elevated Button Theme (Primary Accent)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF080B10),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderSubtle, width: 1),
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: bgSidebar,
        disabledColor: surfaceElevated,
        selectedColor: accentSubtle,
        secondarySelectedColor: accentSubtle,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: borderSubtle),
        ),
        side: const BorderSide(color: borderSubtle),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        titleTextStyle: headline,
        contentTextStyle: body,
      ),

      // DataTable Theme
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(bgSidebar),
        headingTextStyle: const TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return surfaceHover;
          }
          return surfaceCard;
        }),
        dataTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
        ),
        dividerThickness: 1,
      ),
    );
  }
}
