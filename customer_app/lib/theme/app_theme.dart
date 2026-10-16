import 'package:flutter/material.dart';

/// ShopEase Customer Storefront — Light Theme Design System
/// Brand: Coral (#FF6B35) primary, Teal (#00D4A8) secondary
class AppTheme {
  // --- CORE COLOR PALETTE ---
  static const Color primary = Color(0xFFFF6B35); // Coral – CTA, brand
  static const Color primaryLight = Color(0xFFFFF0EB); // Coral tint background
  static const Color primaryMedium = Color(0xFFFFD5C3); // Coral medium tint
  static const Color secondary = Color(0xFF00D4A8); // Teal – availability
  static const Color secondaryLight = Color(0xFFE6FBF7); // Teal tint background

  // Background tokens
  static const Color bgPrimary = Color(0xFFFFFFFF); // Main scaffold
  static const Color bgSecondary = Color(0xFFF8F9FB); // Section / alt bg
  static const Color surfaceCard = Color(0xFFFFFFFF); // Card bg
  static const Color surfaceElevated = Color(0xFFF3F4F6); // Elevated panels

  // Border tokens
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFD1D5DB);

  // Legacy aliases used in various screens (mapped to new palette)
  static const Color accent = primary;
  static const Color accentSubtle = primaryLight;
  static const Color accentHover = Color(0xFFE55A24);
  static const Color secondaryWarm = Color(0xFFD97706); // Warning orange
  static const Color secondaryWarmSubtle = Color(0xFFFEF3C7);

  // Typography
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Status colors
  static const Color statusSuccess = Color(0xFF059669);
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusInfo = Color(0xFF2563EB);

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

  // --- SHADOWS ---
  static const List<BoxShadow> shadowSubtle = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: Color(0x33FF6B35),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // --- ANIMATION TOKENS ---
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

  // --- FLUTTER THEMEDATA (LIGHT) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: primary,
      canvasColor: bgSecondary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surfaceCard,
        onSurface: textPrimary,
        error: statusError,
        onError: Colors.white,
        outline: borderSubtle,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x1A000000),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
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
          borderSide: const BorderSide(color: primary, width: 1.5),
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

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
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
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
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
          foregroundColor: primary,
          textStyle: button,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: bgSecondary,
        disabledColor: surfaceElevated,
        selectedColor: primaryLight,
        secondarySelectedColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: roundedSm,
          side: const BorderSide(color: borderSubtle),
        ),
        side: const BorderSide(color: borderSubtle),
      ),

      // Navigation Bar (Bottom Mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgPrimary,
        elevation: 0,
        shadowColor: const Color(0x1A000000),
        indicatorColor: primaryLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500);
        }),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: roundedLg,
          side: const BorderSide(color: borderSubtle),
        ),
        titleTextStyle: title,
        contentTextStyle: body,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: roundedMd,
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: primary,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // BottomSheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceCard,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        elevation: 8,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: roundedSm,
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primaryLight,
        circularTrackColor: Colors.transparent,
      ),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: surfaceCard,
        iconColor: textMuted,
        textColor: textPrimary,
      ),
    );
  }

  // Keep darkTheme alias pointing to lightTheme for backward compat
  static ThemeData get darkTheme => lightTheme;
}
