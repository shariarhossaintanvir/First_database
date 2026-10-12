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
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
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
      offset: Offset(0, 1),
      blurRadius: 4,
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
      color: Color(0x2B38BDF8),
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

  static const TextStyle metricSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static const TextStyle tableHeader = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle tableCell = TextStyle(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle tableCellMuted = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
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

  static const TextStyle codeSnippet = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: accent,
    letterSpacing: 0.2,
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
          borderRadius: roundedMd,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        backgroundColor: bgSidebar,
        disabledColor: surfaceElevated,
        selectedColor: accentSubtle,
        secondarySelectedColor: accentSubtle,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: roundedSm,
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
          borderRadius: roundedLg,
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        titleTextStyle: headline,
        contentTextStyle: body,
      ),

      // DataTable Theme
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(bgSidebar),
        headingTextStyle: tableHeader,
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return surfaceHover;
          }
          return surfaceCard;
        }),
        dataTextStyle: tableCell,
        dividerThickness: 1,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: roundedSm,
          border: Border.all(color: borderSubtle),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 12),
        waitDuration: const Duration(milliseconds: 300),
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
