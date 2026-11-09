import 'package:flutter/material.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// RAS HOTEL DESIGN SYSTEM
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// A complete design token system for the Ras Hotel app.
/// Built for consistency, accessibility, and developer experience.

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ COLOR TOKENS                                                        │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSColors {
  // ── Brand Primaries ────────────────────────────────────────────────
  static const burgundy = Color(0xFF741E2D);
  static const deepBurgundy = Color(0xFF4C101D);
  static const wine = Color(0xFF9D3C4E);
  static const blush = Color(0xFFF7E7E7);
  static const rose50 = Color(0xFFFCF9F6);
  static const rose100 = Color(0xFFFDF5F4);
  static const rose200 = Color(0xFFFCEBE8);

  // ── Neutral Scale ──────────────────────────────────────────────────
  static const canvas = Color(0xFFFCF9F6);
  static const ink = Color(0xFF1A1516);
  static const inkLight = Color(0xFF2A2021);
  static const muted = Color(0xFF806F70);
  static const mutedLight = Color(0xFF9E8D8E);
  static const border = Color(0xFFECE2DE);
  static const borderLight = Color(0xFFF2E9E5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAF7F5);
  static const divider = Color(0xFFEFE5E0);

  // ── Accent / Semantic ──────────────────────────────────────────────
  static const gold = Color(0xFFC89B5D);
  static const goldLight = Color(0xFFE8D5C0);
  static const goldDark = Color(0xFFB88A4D);

  static const success = Color(0xFF2E7D32);
  static const successLight = Color(0xFFE8F5E9);
  static const successContainer = Color(0xFFC8E6C9);

  static const warning = Color(0xFFE65100);
  static const warningLight = Color(0xFFFFF3E0);
  static const warningContainer = Color(0xFFFFE0B2);

  static const error = Color(0xFFC62828);
  static const errorLight = Color(0xFFFFEBEE);
  static const errorContainer = Color(0xFFEF9A9A);

  static const info = Color(0xFF1565C0);
  static const infoLight = Color(0xFFE3F2FD);
  static const infoContainer = Color(0xFFBBDEFB);

  // ── On-colors (accessible text/icon colors) ───────────────────────
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1516);
  static const onSurfaceVariant = Color(0xFF4A3F40);
  static const onBackground = Color(0xFF1A1516);
  static const onError = Color(0xFFFFFFFF);
  static const onSuccess = Color(0xFFFFFFFF);
  static const onWarning = Color(0xFF1A1516);
  static const onInfo = Color(0xFFFFFFFF);

  // ── Overlay / Scrim ────────────────────────────────────────────────
  static const scrim = Color(0x80000000);
  static const modalBarrier = Color(0x99000000);

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepBurgundy, burgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0x66000000), Color(0x99000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF7F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Surface Variants for elevation layering ────────────────────────
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFDF5F4);
  static const surfaceContainer = Color(0xFFFCEBE8);
  static const surfaceContainerHigh = Color(0xFFF7E1DE);
  static const surfaceContainerHighest = Color(0xFFF1DBD6);
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ TYPOGRAPHY SCALE                                                    │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSTypography {
  // Font families
  static const serif = 'serif';
  static const sans = 'sans';
  static const mono = 'monospace';

  // Scale ratios (1.25 = Major Third, harmonious) - reserved for future programmatic scaling
  // static const double _scaleRatio = 1.25;
  // static const double _baseSize = 14;

  // ── Display (Marketing/hero) ──────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: serif,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.5,
    color: RSColors.ink,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: serif,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -0.25,
    color: RSColors.ink,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: serif,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: 0,
    color: RSColors.ink,
  );

  // ── Headline (Section headers) ────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: serif,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: 0,
    color: RSColors.ink,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: serif,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
    color: RSColors.ink,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: serif,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: RSColors.ink,
  );

  // ── Title (Cards, dialogs) ────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: sans,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    color: RSColors.ink,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.1,
    color: RSColors.ink,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.1,
    color: RSColors.ink,
  );

  // ── Label (Buttons, chips, small UI) ──────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.2,
    color: RSColors.ink,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
    color: RSColors.ink,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: RSColors.ink,
  );

  // ── Body (Content) ────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: RSColors.ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: RSColors.muted,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: RSColors.muted,
  );

  // ── Specialized ────────────────────────────────────────────────────
  static const TextStyle priceLarge = TextStyle(
    fontFamily: sans,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: RSColors.burgundy,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: sans,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    color: RSColors.burgundy,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
    color: RSColors.burgundy,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.4,
    color: RSColors.muted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: sans,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 1.0,
    color: RSColors.muted,
  );

  /// Build a complete TextTheme from tokens
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ SPACING & LAYOUT RHYTHM                                             │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSSpacing {
  // 4px base unit - everything scales from this
  static const double unit = 4;

  // Semantic spacing tokens
  static const double xs = unit;        // 4
  static const double sm = unit * 2;    // 8
  static const double md = unit * 3;    // 12
  static const double lg = unit * 4;    // 16
  static const double xl = unit * 5;    // 20
  static const double xxl = unit * 6;   // 24
  static const double xxxl = unit * 8;  // 32
  static const double huge = unit * 10; // 40
  static const double massive = unit * 12; // 48

  // Component-specific
  static const double screenPadding = lg;        // 16
  static const double screenPaddingLarge = xl;   // 20
  static const double cardPadding = lg;          // 16
  static const double cardPaddingLarge = xl;     // 20
  static const double sectionGap = xxl;          // 24
  static const double componentGap = lg;         // 16
  static const double inlineGap = sm;            // 8
  static const double tightGap = xs;             // 4

  // Border radius scale
  static const double radiusNone = 0;
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusXxxl = 28;
  static const double radiusFull = 999;

  // Component radius
  static const double radiusButton = radiusLg;       // 16
  static const double radiusCard = radiusXxl;        // 24
  static const double radiusCardSmall = radiusXl;    // 20
  static const double radiusChip = radiusFull;       // 999
  static const double radiusInput = radiusLg;        // 16
  static const double radiusSheet = radiusXxxl;      // 28
  static const double radiusModal = radiusXxxl;      // 28
  static const double radiusFab = radiusFull;        // 999
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ ELEVATION & SHADOWS                                                 │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSElevation {
  // Elevation levels (0-5)
  static const List<BoxShadow> level0 = [];
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];
  static const List<BoxShadow> level5 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Colored shadows for brand elements
  static List<BoxShadow> brandLevel1(Color color, {double opacity = 0.25}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity * 0.4),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: color.withValues(alpha: opacity * 0.2),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> brandLevel2(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity * 0.5),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: color.withValues(alpha: opacity * 0.25),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Semantic elevation assignments
  static const List<BoxShadow> card = level1;
  static const List<BoxShadow> cardHover = level2;
  static const List<BoxShadow> cardPressed = level1;
  static const List<BoxShadow> sheet = level3;
  static const List<BoxShadow> modal = level4;
  static const List<BoxShadow> fab = level3;
  static const List<BoxShadow> dropdown = level3;
  static const List<BoxShadow> tooltip = level2;
  static const List<BoxShadow> navBar = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, -2),
    ),
  ];
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ ANIMATION & MOTION                                                  │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSMotion {
  // Duration tokens
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 450);
  static const Duration slowest = Duration(milliseconds: 600);

  // Curve tokens
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeOutQuart = Curves.easeOutQuart;
  static const Curve easeOutQuint = Curves.easeOutQuint;
  static const Curve sharp = Curves.easeInOutCirc;
  static const Curve expressive = Curves.elasticOut;
  static const Curve spring = Curves.bounceOut;

  // Standard transitions
  static const Duration standardDuration = normal;
  static const Curve standardCurve = easeOutCubic;
  static const Duration emphasizedDuration = slow;
  static const Curve emphasizedCurve = easeOutQuart;

  // Stagger
  static const Duration staggerBase = Duration(milliseconds: 60);
  static const Duration staggerMax = Duration(milliseconds: 300);
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ BORDER & DIVIDER TOKENS                                             │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSBorders {
  static const double hairline = 0.5;
  static const double thin = 1;
  static const double medium = 1.5;
  static const double thick = 2;
  static const double heavy = 3;

  static const BorderSide hairlineBorder = BorderSide(
    color: RSColors.border,
    width: hairline,
  );
  static const BorderSide thinBorder = BorderSide(
    color: RSColors.border,
    width: thin,
  );
  static const BorderSide mediumBorder = BorderSide(
    color: RSColors.border,
    width: medium,
  );
  static const BorderSide thickBorder = BorderSide(
    color: RSColors.border,
    width: thick,
  );
  static const BorderSide focusBorder = BorderSide(
    color: RSColors.burgundy,
    width: thick,
  );
  static const BorderSide errorBorder = BorderSide(
    color: RSColors.error,
    width: thick,
  );
  static const BorderSide successBorder = BorderSide(
    color: RSColors.success,
    width: thick,
  );
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ BREAKPOINTS (Responsive)                                            │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSBreakpoints {
  static const double compact = 360;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;
  static const double xlarge = 1600;

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < medium;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= medium &&
      MediaQuery.of(context).size.width < expanded;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= expanded;
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ ICON SIZES                                                          │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSIconSizes {
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ Z-INDEX LAYERING                                                    │
/// └─────────────────────────────────────────────────────────────────────┘

abstract final class RSZIndex {
  static const int base = 0;
  static const int raised = 1;
  static const int dropdown = 100;
  static const int sticky = 200;
  static const int modal = 300;
  static const int toast = 400;
  static const int tooltip = 500;
  static const int overlay = 600;
}