import 'package:flutter/material.dart';

import 'app_design_system.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// RAS HOTEL THEME
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Material 3 theme built on the design system tokens.
/// Provides light and dark themes with full customization.

abstract final class RSTheme {
  /// Light theme - primary brand theme
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RSColors.burgundy,
      brightness: Brightness.light,
    ).copyWith(
      // Primary
      primary: RSColors.burgundy,
      onPrimary: RSColors.onPrimary,
      primaryContainer: RSColors.blush,
      onPrimaryContainer: RSColors.burgundy,

      // Secondary
      secondary: RSColors.gold,
      onSecondary: RSColors.onWarning,
      secondaryContainer: RSColors.goldLight,
      onSecondaryContainer: RSColors.ink,

      // Tertiary
      tertiary: RSColors.wine,
      onTertiary: RSColors.onPrimary,
      tertiaryContainer: RSColors.rose200,
      onTertiaryContainer: RSColors.deepBurgundy,

      // Surface
      surface: RSColors.surface,
      onSurface: RSColors.onSurface,
      surfaceContainerLowest: RSColors.surfaceContainerLowest,
      surfaceContainerLow: RSColors.surfaceContainerLow,
      surfaceContainer: RSColors.surfaceContainer,
      surfaceContainerHigh: RSColors.surfaceContainerHigh,
      surfaceContainerHighest: RSColors.surfaceContainerHighest,
      onSurfaceVariant: RSColors.onSurfaceVariant,

      // Error
      error: RSColors.error,
      onError: RSColors.onError,
      errorContainer: RSColors.errorLight,
      onErrorContainer: RSColors.error,

      // Outline
      outline: RSColors.border,
      outlineVariant: RSColors.borderLight,

      // Shadow
      shadow: RSColors.ink.withValues(alpha: 0.08),
      scrim: RSColors.scrim,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RSColors.canvas,
      fontFamily: RSTypography.sans,

      // ── Text Theme ──────────────────────────────────────────────────
      textTheme: _buildTextTheme(colorScheme),

      // ── App Bar Theme ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: RSColors.canvas,
        foregroundColor: RSColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: RSTypography.titleLarge.copyWith(
          color: RSColors.ink,
        ),
        iconTheme: IconThemeData(
          color: RSColors.ink,
          size: RSIconSizes.lg,
        ),
        actionsIconTheme: IconThemeData(
          color: RSColors.ink,
          size: RSIconSizes.md,
        ),
      ),

      // ── Card Theme ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: RSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusCard),
          side: BorderSide(color: RSColors.border, width: RSBorders.thin),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Button Themes ───────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RSColors.burgundy,
          foregroundColor: RSColors.onPrimary,
          disabledBackgroundColor: RSColors.border,
          disabledForegroundColor: RSColors.mutedLight,
          padding: const EdgeInsets.symmetric(
            horizontal: RSSpacing.xl,
            vertical: RSSpacing.md,
          ),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusButton),
          ),
          textStyle: RSTypography.labelLarge,
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return RSColors.deepBurgundy.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return RSColors.burgundy.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return RSColors.burgundy.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RSColors.burgundy,
          foregroundColor: RSColors.onPrimary,
          disabledBackgroundColor: RSColors.border,
          disabledForegroundColor: RSColors.mutedLight,
          padding: const EdgeInsets.symmetric(
            horizontal: RSSpacing.xl,
            vertical: RSSpacing.md,
          ),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusButton),
          ),
          textStyle: RSTypography.labelLarge,
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return RSColors.deepBurgundy.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return RSColors.burgundy.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RSColors.burgundy,
          disabledForegroundColor: RSColors.mutedLight,
          side: BorderSide(color: RSColors.border, width: RSBorders.thin),
          padding: const EdgeInsets.symmetric(
            horizontal: RSSpacing.xl,
            vertical: RSSpacing.md,
          ),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusButton),
          ),
          textStyle: RSTypography.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return RSColors.blush.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return RSColors.blush.withValues(alpha: 0.3);
            }
            if (states.contains(WidgetState.focused)) {
              return RSColors.blush.withValues(alpha: 0.3);
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.focused)) {
              return RSBorders.focusBorder;
            }
            if (states.contains(WidgetState.hovered)) {
              return BorderSide(color: RSColors.burgundy, width: RSBorders.medium);
            }
            return BorderSide(color: RSColors.border, width: RSBorders.thin);
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RSColors.burgundy,
          disabledForegroundColor: RSColors.mutedLight,
          padding: const EdgeInsets.symmetric(
            horizontal: RSSpacing.md,
            vertical: RSSpacing.sm,
          ),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusButton),
          ),
          textStyle: RSTypography.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return RSColors.blush.withValues(alpha: 0.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return RSColors.blush.withValues(alpha: 0.3);
            }
            return null;
          }),
        ),
      ),

      // ── Input Decoration Theme ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RSColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RSSpacing.lg,
          vertical: RSSpacing.md,
        ),
        labelStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.muted,
        ),
        hintStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.mutedLight,
        ),
        errorStyle: RSTypography.bodySmall.copyWith(
          color: RSColors.error,
        ),
        floatingLabelStyle: RSTypography.bodySmall.copyWith(
          color: RSColors.burgundy,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: RSBorders.thinBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: RSBorders.thinBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: RSBorders.focusBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: RSBorders.errorBorder,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: BorderSide(color: RSColors.error, width: RSBorders.thick),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
          borderSide: BorderSide(color: RSColors.borderLight, width: RSBorders.thin),
        ),
      ),

      // ── Chip Theme ──────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: RSColors.surface,
        disabledColor: RSColors.surfaceContainer,
        selectedColor: RSColors.blush,
        secondarySelectedColor: RSColors.goldLight,
        padding: const EdgeInsets.symmetric(
          horizontal: RSSpacing.md,
          vertical: RSSpacing.xs,
        ),
        labelStyle: RSTypography.labelMedium.copyWith(
          color: RSColors.ink,
        ),
        secondaryLabelStyle: RSTypography.labelMedium.copyWith(
          color: RSColors.onPrimary,
        ),
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        checkmarkColor: RSColors.burgundy,
        side: BorderSide(color: RSColors.border, width: RSBorders.thin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusChip),
        ),
      ),

      // ── Tab Bar Theme ───────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: RSColors.ink,
        unselectedLabelColor: RSColors.muted,
        labelStyle: RSTypography.labelLarge,
        unselectedLabelStyle: RSTypography.labelMedium,
        indicator: BoxDecoration(
          color: RSColors.burgundy,
          borderRadius: BorderRadius.circular(RSSpacing.radiusSm),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return RSColors.blush.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.hovered)) {
            return RSColors.blush.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),

      // ── Navigation Bar Theme ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: RSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: RSColors.blush,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSTypography.labelSmall.copyWith(
              color: RSColors.burgundy,
              fontWeight: FontWeight.w700,
            );
          }
          return RSTypography.labelSmall.copyWith(
            color: RSColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: RSColors.burgundy,
              size: RSIconSizes.lg,
            );
          }
          return IconThemeData(
            color: RSColors.muted,
            size: RSIconSizes.lg,
          );
        }),
      ),

      // ── Bottom Sheet Theme ──────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: RSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RSSpacing.radiusSheet),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        modalBackgroundColor: RSColors.surface,
        modalElevation: 0,
      ),

      // ── Dialog Theme ────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: RSColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusModal),
        ),
        titleTextStyle: RSTypography.titleLarge.copyWith(
          color: RSColors.ink,
        ),
        contentTextStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.onSurface,
        ),
      ),

      // ── Snack Bar Theme ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RSColors.ink,
        contentTextStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.onPrimary,
        ),
        actionTextColor: RSColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Divider Theme ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: RSColors.divider,
        thickness: RSBorders.hairline,
        space: RSSpacing.lg,
        indent: 0,
        endIndent: 0,
      ),

      // ── List Tile Theme ─────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RSSpacing.lg,
          vertical: RSSpacing.xs,
        ),
        titleTextStyle: RSTypography.titleMedium.copyWith(
          color: RSColors.ink,
        ),
        subtitleTextStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.muted,
        ),
        leadingAndTrailingTextStyle: RSTypography.bodyMedium.copyWith(
          color: RSColors.muted,
        ),
        iconColor: RSColors.muted,
        textColor: RSColors.ink,
        selectedColor: RSColors.blush,
        selectedTileColor: RSColors.blush,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
        horizontalTitleGap: RSSpacing.md,
        minLeadingWidth: 40,
      ),

      // ── Tooltip Theme ───────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: RSColors.ink.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(RSSpacing.radiusMd),
          boxShadow: RSElevation.tooltip,
        ),
        textStyle: RSTypography.labelSmall.copyWith(
          color: RSColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: RSSpacing.md,
          vertical: RSSpacing.sm,
        ),
        preferBelow: true,
        verticalOffset: 8,
        triggerMode: TooltipTriggerMode.tap,
      ),

      // ── Progress Indicator Theme ────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: RSColors.burgundy,
        linearTrackColor: RSColors.border,
        circularTrackColor: RSColors.border,
        refreshBackgroundColor: RSColors.surface,
      ),

      // ── Slider Theme ────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: RSColors.burgundy,
        inactiveTrackColor: RSColors.border,
        thumbColor: RSColors.burgundy,
        overlayColor: RSColors.blush,
        valueIndicatorColor: RSColors.burgundy,
        valueIndicatorTextStyle: RSTypography.labelSmall.copyWith(
          color: RSColors.onPrimary,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ── Switch Theme ────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return RSColors.mutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.blush;
          }
          return RSColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return RSColors.border;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.blush.withValues(alpha: 0.3);
          }
          return RSColors.border.withValues(alpha: 0.3);
        }),
      ),

      // ── Checkbox Theme ──────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(RSColors.onPrimary),
        side: BorderSide(color: RSColors.border, width: RSBorders.medium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusSm),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.hovered)) {
            return RSColors.blush.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),

      // ── Radio Theme ─────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return RSColors.muted;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.hovered)) {
            return RSColors.blush.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),

      // ── Date Picker Theme ───────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: RSColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: RSColors.burgundy,
        headerForegroundColor: RSColors.onPrimary,
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.onPrimary;
          }
          return RSColors.ink;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.burgundy;
          }
          return null;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return RSColors.onPrimary;
          }
          return RSColors.ink;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
        ),
        todayBorder: BorderSide(color: RSColors.burgundy, width: RSBorders.medium),
        todayForegroundColor: WidgetStateProperty.all(RSColors.burgundy),
      ),

      // ── Time Picker Theme ───────────────────────────────────────────
      timePickerTheme: TimePickerThemeData(
        backgroundColor: RSColors.surface,
        hourMinuteTextColor: RSColors.ink,
        hourMinuteColor: RSColors.surfaceContainer,
        dayPeriodTextColor: RSColors.ink,
        dayPeriodColor: RSColors.surfaceContainer,
        dialHandColor: RSColors.burgundy,
        dialBackgroundColor: RSColors.blush,
        entryModeIconColor: RSColors.burgundy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusXl),
        ),
      ),

      // ── Expansion Tile Theme ────────────────────────────────────────
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: RSColors.surface,
        collapsedBackgroundColor: RSColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
          side: BorderSide(color: RSColors.border, width: RSBorders.thin),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
          side: BorderSide(color: RSColors.border, width: RSBorders.thin),
        ),
        textColor: RSColors.ink,
        collapsedTextColor: RSColors.ink,
        iconColor: RSColors.muted,
        collapsedIconColor: RSColors.muted,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: RSSpacing.lg,
          vertical: RSSpacing.sm,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          RSSpacing.lg,
          0,
          RSSpacing.lg,
          RSSpacing.lg,
        ),
      ),

      // ── Search Bar Theme ────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(RSColors.surface),
        hintStyle: WidgetStateProperty.all(
          RSTypography.bodyMedium.copyWith(color: RSColors.mutedLight),
        ),
        textStyle: WidgetStateProperty.all(
          RSTypography.bodyMedium.copyWith(color: RSColors.ink),
        ),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RSSpacing.radiusInput),
            side: BorderSide(color: RSColors.border, width: RSBorders.thin),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: RSSpacing.lg),
        ),
        constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
      ),

      // ── Segmented Button Theme ──────────────────────────────────────
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return RSColors.blush;
            }
            return RSColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return RSColors.burgundy;
            }
            return RSColors.ink;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: RSColors.burgundy, width: RSBorders.medium);
            }
            return BorderSide(color: RSColors.border, width: RSBorders.thin);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: RSSpacing.md,
              vertical: RSSpacing.sm,
            ),
          ),
          textStyle: WidgetStateProperty.all(RSTypography.labelMedium),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  /// Dark theme - for future use
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RSColors.burgundy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: RSColors.wine,
      onPrimary: RSColors.onPrimary,
      primaryContainer: RSColors.deepBurgundy,
      onPrimaryContainer: RSColors.rose50,
      secondary: RSColors.gold,
      onSecondary: RSColors.ink,
      secondaryContainer: RSColors.goldDark,
      onSecondaryContainer: RSColors.onPrimary,
      surface: Color(0xFF1A1516),
      onSurface: RSColors.rose50,
      error: RSColors.errorContainer,
      onError: RSColors.ink,
      outline: Color(0xFF3D3334),
      outlineVariant: Color(0xFF2A2021),
    );

    return light.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Color(0xFF1A1516),
      cardTheme: CardThemeData(
        color: Color(0xFF231C1D),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: _buildTextTheme(colorScheme, isDark: true),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme scheme, {bool isDark = false}) {
    final onSurface = isDark ? RSColors.rose50 : RSColors.ink;
    final onSurfaceVariant = isDark ? RSColors.mutedLight : RSColors.muted;

    return RSTypography.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
      decorationColor: onSurface,
      fontFamily: RSTypography.sans,
    ).copyWith(
      bodyMedium: RSTypography.bodyMedium.copyWith(color: onSurfaceVariant),
      bodySmall: RSTypography.bodySmall.copyWith(color: onSurfaceVariant),
      labelLarge: RSTypography.labelLarge.copyWith(color: onSurface),
      labelMedium: RSTypography.labelMedium.copyWith(color: onSurfaceVariant),
      labelSmall: RSTypography.labelSmall.copyWith(color: onSurfaceVariant),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// THEME EXTENSIONS
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Custom theme extension for brand-specific tokens
@immutable
class RSBrandThemeExtension extends ThemeExtension<RSBrandThemeExtension> {
  const RSBrandThemeExtension({
    required this.gradientPrimary,
    required this.gradientHero,
    required this.gradientCard,
    required this.gradientGold,
    required this.shadowBrand1,
    required this.shadowBrand2,
    required this.shadowGold1,
    required this.shadowGold2,
    required this.borderColor,
    required this.borderColorLight,
    required this.dividerColor,
  });

  final LinearGradient gradientPrimary;
  final LinearGradient gradientHero;
  final LinearGradient gradientCard;
  final LinearGradient gradientGold;
  final List<BoxShadow> shadowBrand1;
  final List<BoxShadow> shadowBrand2;
  final List<BoxShadow> shadowGold1;
  final List<BoxShadow> shadowGold2;
  final Color borderColor;
  final Color borderColorLight;
  final Color dividerColor;

  @override
  RSBrandThemeExtension copyWith({
    LinearGradient? gradientPrimary,
    LinearGradient? gradientHero,
    LinearGradient? gradientCard,
    LinearGradient? gradientGold,
    List<BoxShadow>? shadowBrand1,
    List<BoxShadow>? shadowBrand2,
    List<BoxShadow>? shadowGold1,
    List<BoxShadow>? shadowGold2,
    Color? borderColor,
    Color? borderColorLight,
    Color? dividerColor,
  }) {
    return RSBrandThemeExtension(
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      gradientHero: gradientHero ?? this.gradientHero,
      gradientCard: gradientCard ?? this.gradientCard,
      gradientGold: gradientGold ?? this.gradientGold,
      shadowBrand1: shadowBrand1 ?? this.shadowBrand1,
      shadowBrand2: shadowBrand2 ?? this.shadowBrand2,
      shadowGold1: shadowGold1 ?? this.shadowGold1,
      shadowGold2: shadowGold2 ?? this.shadowGold2,
      borderColor: borderColor ?? this.borderColor,
      borderColorLight: borderColorLight ?? this.borderColorLight,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  RSBrandThemeExtension lerp(
    ThemeExtension<RSBrandThemeExtension>? other,
    double t,
  ) {
    if (other is! RSBrandThemeExtension) return this;
    return copyWith(
      gradientPrimary: Gradient.lerp(gradientPrimary, other.gradientPrimary, t)! as LinearGradient,
      gradientHero: Gradient.lerp(gradientHero, other.gradientHero, t)! as LinearGradient,
      gradientCard: Gradient.lerp(gradientCard, other.gradientCard, t)! as LinearGradient,
      gradientGold: Gradient.lerp(gradientGold, other.gradientGold, t)! as LinearGradient,
      shadowBrand1: _lerpShadows(shadowBrand1, other.shadowBrand1, t),
      shadowBrand2: _lerpShadows(shadowBrand2, other.shadowBrand2, t),
      shadowGold1: _lerpShadows(shadowGold1, other.shadowGold1, t),
      shadowGold2: _lerpShadows(shadowGold2, other.shadowGold2, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderColorLight: Color.lerp(borderColorLight, other.borderColorLight, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }

  List<BoxShadow> _lerpShadows(
    List<BoxShadow> a,
    List<BoxShadow> b,
    double t,
  ) {
    if (a.length != b.length) return a;
    return List.generate(a.length, (i) => BoxShadow.lerp(a[i], b[i], t)!);
  }

  static final RSBrandThemeExtension light = RSBrandThemeExtension(
    gradientPrimary: RSColors.primaryGradient,
    gradientHero: RSColors.heroGradient,
    gradientCard: RSColors.cardGradient,
    gradientGold: RSColors.goldGradient,
    shadowBrand1: RSElevation.brandLevel1(RSColors.burgundy),
    shadowBrand2: RSElevation.brandLevel2(RSColors.burgundy),
    shadowGold1: RSElevation.brandLevel1(RSColors.gold),
    shadowGold2: RSElevation.brandLevel2(RSColors.gold),
    borderColor: RSColors.border,
    borderColorLight: RSColors.borderLight,
    dividerColor: RSColors.divider,
  );

  static final RSBrandThemeExtension dark = RSBrandThemeExtension(
    gradientPrimary: LinearGradient(
      colors: [RSColors.deepBurgundy, RSColors.wine],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientHero: RSColors.heroGradient,
    gradientCard: LinearGradient(
      colors: [Color(0xFF231C1D), Color(0xFF1A1516)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientGold: RSColors.goldGradient,
    shadowBrand1: RSElevation.brandLevel1(RSColors.wine, opacity: 0.3),
    shadowBrand2: RSElevation.brandLevel2(RSColors.wine, opacity: 0.4),
    shadowGold1: RSElevation.brandLevel1(RSColors.gold, opacity: 0.3),
    shadowGold2: RSElevation.brandLevel2(RSColors.gold, opacity: 0.4),
    borderColor: Color(0xFF3D3334),
    borderColorLight: Color(0xFF2A2021),
    dividerColor: Color(0xFF2A2021),
  );
}

/// Helper to access brand extension
extension BrandThemeExtension on BuildContext {
  RSBrandThemeExtension get brand => Theme.of(this).extension<RSBrandThemeExtension>()!;
}