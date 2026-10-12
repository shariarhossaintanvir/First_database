import 'package:flutter/material.dart';

/// Premium Minimal Dark Theme Tokens for Customer Storefront
class AppTheme {
  // --- COLOR PALETTE ---
  static const Color bgPrimary = Color(0xFF0A0A0C); // Deep Obsidian
  static const Color bgSecondary = Color(0xFF121215); // Layer 2 background
  static const Color surfaceCard = Color(0xFF18181C); // Card and container surface
  static const Color surfaceElevated = Color(0xFF222228); // Elevated cards, modals, hovers
  static const Color surfaceHover = Color(0xFF2A2A32); // Interactive hover state

  static const Color borderSubtle = Color(0xFF26262D); // 1px borders & dividers
  static const Color borderStrong = Color(0xFF383842); // Active or hover borders

  // Accent Colors (Refined Champagne Gold & Warm Metallic)
  static const Color accent = Color(0xFFE2B93B); // Primary brand CTA & highlight
  static const Color accentHover = Color(0xFFC9A227);
  static const Color accentSubtle = Color(0x26E2B93B); // 15% tint for pills/badges

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // High contrast white
  static const Color textSecondary = Color(0xFFCBD5E1); // Slate 300 for descriptions
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400 for metadata & hints
  static const Color textDisabled = Color(0xFF64748B);

  // Status Indicators
  static const Color statusSuccess = Color(0xFF10B981); // Emerald
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  static const Color statusError = Color(0xFFEF4444); // Crimson
  static const Color statusInfo = Color(0xFF38BDF8); // Sky

  // --- SPACING SCALE (4px base grid) ---
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // --- CORNER RADIUS TOKENS ---
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // --- SHADOW & ELEVATION TOKENS ---
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: Color(0x2BE2B93B),
      offset: Offset(0, 4),
      blurRadius: 14,
      spreadRadius: -2,
    ),
  ];

  // --- ANIMATION & MOTION TOKENS ---
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;

  // --- TYPOGRAPHY STYLES ---
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
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
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textMuted,
    height: 1.4,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle priceOriginal = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.lineThrough,
    color: textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: textMuted,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: textMuted,
  );

  // --- FLUTTER THEMEDATA ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: accent,
      canvasColor: bgSecondary,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        onPrimary: bgPrimary,
        secondary: accent,
        onSecondary: bgPrimary,
        surface: surfaceCard,
        onSurface: textPrimary,
        error: statusError,
        onError: textPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headline,
        iconTheme: IconThemeData(color: textPrimary, size: 22),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: roundedMd,
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        border: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: statusError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: roundedMd,
          borderSide: const BorderSide(color: statusError, width: 1.5),
        ),
        errorStyle: const TextStyle(color: statusError, fontSize: 12),
      ),

      // Elevated Button Theme (Primary Accent)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF0A0A0C), // Dark label for maximum contrast against gold
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: roundedMd,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderSubtle, width: 1),
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: roundedMd,
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
        backgroundColor: bgSecondary,
        disabledColor: surfaceElevated,
        selectedColor: accentSubtle,
        secondarySelectedColor: accentSubtle,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: roundedSm,
          side: const BorderSide(color: borderSubtle),
        ),
        side: const BorderSide(color: borderSubtle),
      ),

      // Navigation Bar (Bottom Mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSecondary,
        elevation: 0,
        indicatorColor: accentSubtle,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500);
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: roundedLg,
          side: const BorderSide(color: borderSubtle),
        ),
        titleTextStyle: title,
        contentTextStyle: body,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: roundedMd,
          side: const BorderSide(color: borderSubtle),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // BottomSheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: borderSubtle),
        ),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: roundedSm,
          border: Border.all(color: borderSubtle),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: surfaceElevated,
        circularTrackColor: Colors.transparent,
      ),
    );
  }
}
