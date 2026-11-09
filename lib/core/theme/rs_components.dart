import 'package:flutter/material.dart';

import 'app_design_system.dart';
import 'app_theme_v2.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// REUSABLE UI COMPONENTS
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Modern, accessible, and consistent components built on the design system.

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS CARD - Base card component with variants                         │
/// └─────────────────────────────────────────────────────────────────────┘

enum RSCardVariant {
  elevated,
  outlined,
  filled,
  tonal,
}

class RSCard extends StatelessWidget {
  const RSCard({
    super.key,
    required this.child,
    this.variant = RSCardVariant.elevated,
    this.padding = const EdgeInsets.all(RSSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
    this.borderRadius = RSSpacing.radiusCard,
    this.elevation = 1,
    this.color,
    this.borderColor,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  });

  final Widget child;
  final RSCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final int elevation;
  final Color? color;
  final Color? borderColor;
  final Clip clipBehavior;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = context.brand;

    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: _buildDecoration(context),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final brand = context.brand;

    switch (variant) {
      case RSCardVariant.elevated:
        return BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: RSElevation.level1,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: RSBorders.thin)
              : null,
        );
      case RSCardVariant.outlined:
        return BoxDecoration(
          color: color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline,
            width: RSBorders.thin,
          ),
        );
      case RSCardVariant.filled:
        return BoxDecoration(
          color: color ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case RSCardVariant.tonal:
        return BoxDecoration(
          color: color ?? theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
        );
    }
  }
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS BUTTON - Enhanced button with loading state                      │
/// └─────────────────────────────────────────────────────────────────────┘

enum RSButtonStyle {
  primary,
  secondary,
  outline,
  text,
  tonal,
}

class RSButton extends StatelessWidget {
  const RSButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAlignment = IconAlignment.end,
    this.style = RSButtonStyle.primary,
    this.size = RSButtonSize.medium,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.fullWidth = false,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
  });

  final String label;
  final Widget? icon;
  final IconAlignment iconAlignment;
  final RSButtonStyle style;
  final RSButtonSize size;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final bool fullWidth;
  final bool enabled;
  final String? semanticLabel;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveEnabled = enabled && !isLoading && onPressed != null;

    Widget button = _buildButton(context, effectiveEnabled);

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: effectiveEnabled,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context, bool effectiveEnabled) {
    final theme = Theme.of(context);
    final brand = context.brand;
    final (bgColor, fgColor, borderColor, overlayColor) = _resolveColors(context);
    final padding = _resolvePadding();
    final textStyle = _resolveTextStyle(context);
    final borderRadius = _resolveBorderRadius();
    final minSize = _resolveMinSize();

    final child = isLoading
        ? SizedBox(
            width: _iconSize(),
            height: _iconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && iconAlignment == IconAlignment.start) ...[
                IconTheme(
                  data: IconThemeData(color: fgColor, size: _iconSize()),
                  child: icon!,
                ),
                SizedBox(width: RSSpacing.sm),
              ],
              Flexible(
                child: Text(
                  isLoading ? (loadingText ?? label) : label,
                  style: textStyle.copyWith(color: fgColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null && iconAlignment == IconAlignment.end) ...[
                SizedBox(width: RSSpacing.sm),
                IconTheme(
                  data: IconThemeData(color: fgColor, size: _iconSize()),
                  child: icon!,
                ),
              ],
            ],
          );

    final button = FilledButton(
      onPressed: effectiveEnabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: theme.colorScheme.outlineVariant,
        disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
        padding: padding,
        minimumSize: minSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: RSBorders.thin)
              : BorderSide.none,
        ),
        textStyle: textStyle,
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return overlayColor;
          }
          if (states.contains(WidgetState.hovered)) {
            return overlayColor.withValues(alpha: 0.5);
          }
          if (states.contains(WidgetState.focused)) {
            return overlayColor.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  (Color, Color, Color?, Color) _resolveColors(BuildContext context) {
    final theme = Theme.of(context);
    final brand = context.brand;

    switch (style) {
      case RSButtonStyle.primary:
        return (
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
          null,
          theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        );
      case RSButtonStyle.secondary:
        return (
          theme.colorScheme.secondary,
          theme.colorScheme.onSecondary,
          null,
          theme.colorScheme.onSecondary.withValues(alpha: 0.12),
        );
      case RSButtonStyle.outline:
        return (
          Colors.transparent,
          theme.colorScheme.primary,
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.1),
        );
      case RSButtonStyle.text:
        return (
          Colors.transparent,
          theme.colorScheme.primary,
          null,
          theme.colorScheme.primary.withValues(alpha: 0.1),
        );
      case RSButtonStyle.tonal:
        return (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
          null,
          theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
        );
    }
  }

  EdgeInsetsGeometry _resolvePadding() {
    switch (size) {
      case RSButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: RSSpacing.md,
          vertical: RSSpacing.xs,
        );
      case RSButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: RSSpacing.xl,
          vertical: RSSpacing.md,
        );
      case RSButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: RSSpacing.xxl,
          vertical: RSSpacing.lg,
        );
    }
  }

  TextStyle _resolveTextStyle(BuildContext context) {
    switch (size) {
      case RSButtonSize.small:
        return RSTypography.labelSmall;
      case RSButtonSize.medium:
        return RSTypography.labelLarge;
      case RSButtonSize.large:
        return RSTypography.titleSmall.copyWith(fontWeight: FontWeight.w700);
    }
  }

  double _resolveBorderRadius() {
    return RSSpacing.radiusButton;
  }

  Size _resolveMinSize() {
    switch (size) {
      case RSButtonSize.small:
        return const Size(64, 36);
      case RSButtonSize.medium:
        return const Size(88, 48);
      case RSButtonSize.large:
        return const Size(104, 56);
    }
  }

  double _iconSize() {
    switch (size) {
      case RSButtonSize.small:
        return RSIconSizes.sm;
      case RSButtonSize.medium:
        return RSIconSizes.md;
      case RSButtonSize.large:
        return RSIconSizes.lg;
    }
  }
}

enum RSButtonSize { small, medium, large }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS ICON BUTTON                                                      │
/// └─────────────────────────────────────────────────────────────────────┘

class RSIconButton extends StatelessWidget {
  const RSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = RSIconButtonSize.medium,
    this.style = RSIconButtonStyle.tonal,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
    this.padding,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final RSIconButtonSize size;
  final RSIconButtonStyle style;
  final bool enabled;
  final String? tooltip;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveEnabled = enabled && onPressed != null;
    final (bgColor, fgColor, borderColor, overlayColor) = _resolveColors(context);
    final buttonSize = _resolveSize();
    final iconSize = _resolveIconSize();
    final borderRadius = _resolveBorderRadius();

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effectiveEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: effectiveEnabled ? bgColor : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null
                ? Border.all(color: borderColor, width: RSBorders.thin)
                : null,
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: effectiveEnabled ? fgColor : theme.colorScheme.onSurfaceVariant,
                size: iconSize,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: effectiveEnabled,
        child: button,
      );
    }

    return button;
  }

  (Color, Color, Color?, Color) _resolveColors(BuildContext context) {
    final theme = Theme.of(context);

    switch (style) {
      case RSIconButtonStyle.tonal:
        return (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
          null,
          theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
        );
      case RSIconButtonStyle.outline:
        return (
          Colors.transparent,
          theme.colorScheme.primary,
          theme.colorScheme.outline,
          theme.colorScheme.primary.withValues(alpha: 0.1),
        );
      case RSIconButtonStyle.filled:
        return (
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
          null,
          theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        );
      case RSIconButtonStyle.ghost:
        return (
          Colors.transparent,
          theme.colorScheme.onSurface,
          null,
          theme.colorScheme.onSurface.withValues(alpha: 0.1),
        );
    }
  }

  double _resolveSize() {
    switch (size) {
      case RSIconButtonSize.small:
        return 36;
      case RSIconButtonSize.medium:
        return 44;
      case RSIconButtonSize.large:
        return 52;
    }
  }

  double _resolveIconSize() {
    switch (size) {
      case RSIconButtonSize.small:
        return RSIconSizes.sm;
      case RSIconButtonSize.medium:
        return RSIconSizes.md;
      case RSIconButtonSize.large:
        return RSIconSizes.lg;
    }
  }

  double _resolveBorderRadius() {
    switch (size) {
      case RSIconButtonSize.small:
        return RSSpacing.radiusMd;
      case RSIconButtonSize.medium:
        return RSSpacing.radiusLg;
      case RSIconButtonSize.large:
        return RSSpacing.radiusXl;
    }
  }
}

enum RSIconButtonSize { small, medium, large }
enum RSIconButtonStyle { tonal, outline, filled, ghost }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS CHIP - Selectable chip                                           │
/// └─────────────────────────────────────────────────────────────────────┘

class RSChip extends StatelessWidget {
  const RSChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
    this.enabled = true,
    this.style = RSChipStyle.filter,
    this.semanticLabel,
  });

  final String label;
  final Widget? icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final bool enabled;
  final RSChipStyle style;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveEnabled = enabled && onSelected != null;

    final (bgColor, fgColor, borderColor, checkColor) = _resolveColors(context);

    Widget chip = FilterChip(
      label: Text(label, style: RSTypography.labelMedium.copyWith(color: fgColor)),
      avatar: icon != null
          ? IconTheme(
              data: IconThemeData(color: fgColor, size: RSIconSizes.sm),
              child: icon!,
            )
          : null,
      selected: selected,
      onSelected: effectiveEnabled ? onSelected : null,
      showCheckmark: style == RSChipStyle.filter,
      checkmarkColor: checkColor,
      selectedColor: bgColor,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: selected ? borderColor : theme.colorScheme.outline,
        width: selected ? RSBorders.medium : RSBorders.thin,
      ),
      labelStyle: RSTypography.labelMedium.copyWith(
        color: fgColor,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: RSSpacing.md,
        vertical: RSSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RSSpacing.radiusChip),
      ),
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );

    if (semanticLabel != null) {
      chip = Semantics(
        label: semanticLabel,
        button: effectiveEnabled,
        selected: selected,
        enabled: effectiveEnabled,
        child: chip,
      );
    }

    return chip;
  }

  (Color, Color, Color, Color) _resolveColors(BuildContext context) {
    final theme = Theme.of(context);

    switch (style) {
      case RSChipStyle.filter:
        return (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          theme.colorScheme.primary,
          theme.colorScheme.onPrimaryContainer,
        );
      case RSChipStyle.input:
        return (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
          theme.colorScheme.secondary,
          theme.colorScheme.onSecondaryContainer,
        );
      case RSChipStyle.choice:
        return (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          theme.colorScheme.tertiary,
          theme.colorScheme.onTertiaryContainer,
        );
      case RSChipStyle.action:
        return (
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
        );
    }
  }
}

enum RSChipStyle { filter, input, choice, action }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS BADGE - Status/badge indicator                                   │
/// └─────────────────────────────────────────────────────────────────────┘

enum RSBadgeVariant {
  primary,
  success,
  warning,
  error,
  info,
  neutral,
}

class RSBadge extends StatelessWidget {
  const RSBadge({
    super.key,
    required this.label,
    this.variant = RSBadgeVariant.primary,
    this.size = RSBadgeSize.medium,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final RSBadgeVariant variant;
  final RSBadgeSize size;
  final Widget? icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bgColor, fgColor) = _resolveColors(context);
    final (padding, fontSize, iconSize, borderRadius) = _resolveMetrics();

    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: fgColor, size: iconSize),
              child: icon!,
            ),
            SizedBox(width: RSSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (semanticLabel != null) {
      badge = Semantics(
        label: semanticLabel,
        child: badge,
      );
    }

    return badge;
  }

  (Color, Color) _resolveColors(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case RSBadgeVariant.primary:
        return (theme.colorScheme.primaryContainer, theme.colorScheme.onPrimaryContainer);
      case RSBadgeVariant.success:
        return (RSColors.successLight, RSColors.success);
      case RSBadgeVariant.warning:
        return (RSColors.warningLight, RSColors.warning);
      case RSBadgeVariant.error:
        return (RSColors.errorLight, RSColors.error);
      case RSBadgeVariant.info:
        return (RSColors.infoLight, RSColors.info);
      case RSBadgeVariant.neutral:
        return (theme.colorScheme.surfaceContainerHighest, theme.colorScheme.onSurfaceVariant);
    }
  }

  (EdgeInsetsGeometry, double, double, double) _resolveMetrics() {
    switch (size) {
      case RSBadgeSize.small:
        return (
          const EdgeInsets.symmetric(horizontal: RSSpacing.sm, vertical: RSSpacing.xs),
          10,
          10,
          RSSpacing.radiusSm,
        );
      case RSBadgeSize.medium:
        return (
          const EdgeInsets.symmetric(horizontal: RSSpacing.md, vertical: RSSpacing.xs),
          11,
          12,
          RSSpacing.radiusMd,
        );
      case RSBadgeSize.large:
        return (
          const EdgeInsets.symmetric(horizontal: RSSpacing.lg, vertical: RSSpacing.sm),
          12,
          14,
          RSSpacing.radiusLg,
        );
    }
  }
}

enum RSBadgeSize { small, medium, large }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS AVATAR - User/profile avatar                                     │
/// └─────────────────────────────────────────────────────────────────────┘

class RSAvatar extends StatelessWidget {
  const RSAvatar({
    super.key,
    this.image,
    this.name,
    this.size = RSAvatarSize.medium,
    this.shape = RSAvatarShape.circle,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = RSBorders.thin,
    this.semanticLabel,
  });

  final ImageProvider? image;
  final String? name;
  final RSAvatarSize size;
  final RSAvatarShape shape;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = _resolveSize();
    final borderRadius = _resolveBorderRadius();
    final fontSize = _resolveFontSize();
    final bgColor = backgroundColor ?? _generateColorFromName(name);

    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: shape == RSAvatarShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == RSAvatarShape.circle ? null : BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        image: image != null
            ? DecorationImage(
                image: image!,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: image == null && name != null
          ? Center(
              child: Text(
                _getInitials(name!),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );

    if (semanticLabel != null) {
      avatar = Semantics(
        label: semanticLabel,
        image: true,
        child: avatar,
      );
    }

    return avatar;
  }

  double _resolveSize() {
    switch (size) {
      case RSAvatarSize.xs:
        return 24;
      case RSAvatarSize.sm:
        return 32;
      case RSAvatarSize.medium:
        return 44;
      case RSAvatarSize.lg:
        return 56;
      case RSAvatarSize.xl:
        return 72;
      case RSAvatarSize.xxl:
        return 96;
    }
  }

  double _resolveBorderRadius() {
    switch (size) {
      case RSAvatarSize.xs:
        return RSSpacing.radiusSm;
      case RSAvatarSize.sm:
        return RSSpacing.radiusMd;
      case RSAvatarSize.medium:
        return RSSpacing.radiusLg;
      case RSAvatarSize.lg:
        return RSSpacing.radiusXl;
      case RSAvatarSize.xl:
        return RSSpacing.radiusXxl;
      case RSAvatarSize.xxl:
        return RSSpacing.radiusXxxl;
    }
  }

  double _resolveFontSize() {
    switch (size) {
      case RSAvatarSize.xs:
        return 8;
      case RSAvatarSize.sm:
        return 11;
      case RSAvatarSize.medium:
        return 15;
      case RSAvatarSize.lg:
        return 19;
      case RSAvatarSize.xl:
        return 24;
      case RSAvatarSize.xxl:
        return 32;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Color _generateColorFromName(String? name) {
    if (name == null || name.isEmpty) {
      return RSColors.burgundy;
    }
    final colors = [
      RSColors.burgundy,
      RSColors.wine,
      RSColors.gold,
      RSColors.deepBurgundy,
      Color(0xFF5D3A1A),
      Color(0xFF1B5E20),
      Color(0xFF0D47A1),
      Color(0xFF8B0000),
    ];
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}

enum RSAvatarSize { xs, sm, medium, lg, xl, xxl }
enum RSAvatarShape { circle, rounded }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS INFO ROW - Icon + label + value row                              │
/// └─────────────────────────────────────────────────────────────────────┘

class RSInfoRow extends StatelessWidget {
  const RSInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.spacing = RSSpacing.sm,
    this.iconSize = RSIconSizes.md,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  final Widget icon;
  final String label;
  final String value;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;
  final double iconSize;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        IconTheme(
          data: IconThemeData(
            color: iconColor ?? theme.colorScheme.primary,
            size: iconSize,
          ),
          child: icon,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: labelStyle ??
                    RSTypography.labelSmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: valueStyle ??
                    RSTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS SECTION HEADER - Consistent section headers                      │
/// └─────────────────────────────────────────────────────────────────────┘

class RSSectionHeader extends StatelessWidget {
  const RSSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.icon,
    this.style = RSSectionHeaderStyle.defaultStyle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionLabel;
  final Widget? icon;
  final RSSectionHeaderStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (style) {
      case RSSectionHeaderStyle.defaultStyle:
        return _buildDefault(context);
      case RSSectionHeaderStyle.compact:
        return _buildCompact(context);
      case RSSectionHeaderStyle.hero:
        return _buildHero(context);
    }
  }

  Widget _buildDefault(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RSSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: theme.colorScheme.primary,
                size: RSIconSizes.lg,
              ),
              child: icon!,
            ),
            SizedBox(width: RSSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RSTypography.titleLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: RSSpacing.xs),
                  Text(
                    subtitle!,
                    style: RSTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null && actionLabel != null)
            TextButton(onPressed: action, child: Text(actionLabel!)),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: theme.colorScheme.primary,
              size: RSIconSizes.md,
            ),
            child: icon!,
          ),
          SizedBox(width: RSSpacing.xs),
        ],
        Text(
          title,
          style: RSTypography.titleMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(width: RSSpacing.sm),
          Text(
            subtitle!,
            style: RSTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (action != null && actionLabel != null) ...[
          const Spacer(),
          TextButton(onPressed: action, child: Text(actionLabel!)),
        ],
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: theme.colorScheme.primary,
              size: RSIconSizes.xxxl,
            ),
            child: icon!,
          ),
          SizedBox(height: RSSpacing.md),
        ],
        Text(
          title,
          style: RSTypography.displaySmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: RSSpacing.sm),
          Text(
            subtitle!,
            style: RSTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (action != null && actionLabel != null) ...[
          SizedBox(height: RSSpacing.lg),
          RSButton(
            label: actionLabel!,
            style: RSButtonStyle.primary,
            onPressed: action,
          ),
        ],
      ],
    );
  }
}

enum RSSectionHeaderStyle { defaultStyle, compact, hero }

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS DIVIDER - Styled divider                                         │
/// └─────────────────────────────────────────────────────────────────────┘

class RSDivider extends StatelessWidget {
  const RSDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.thickness = RSBorders.hairline,
    this.color,
    this.height = RSSpacing.lg,
    this.vertical = false,
  });

  final double indent;
  final double endIndent;
  final double thickness;
  final Color? color;
  final double height;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.dividerTheme.color ?? RSColors.divider;

    if (vertical) {
      return SizedBox(
        height: height,
        child: VerticalDivider(
          indent: indent,
          endIndent: endIndent,
          thickness: thickness,
          color: dividerColor,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Divider(
        indent: indent,
        endIndent: endIndent,
        thickness: thickness,
        color: dividerColor,
      ),
    );
  }
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS SPACER - Consistent vertical spacing                             │
/// └─────────────────────────────────────────────────────────────────────┘

class RSSpacer extends StatelessWidget {
  const RSSpacer({
    super.key,
    this.size = RSSpacerSize.medium,
    this.customHeight,
  });

  final RSSpacerSize size;
  final double? customHeight;

  @override
  Widget build(BuildContext context) {
    final height = customHeight ?? _resolveHeight();
    return SizedBox(height: height);
  }

  double _resolveHeight() {
    switch (size) {
      case RSSpacerSize.xs:
        return RSSpacing.xs;
      case RSSpacerSize.sm:
        return RSSpacing.sm;
      case RSSpacerSize.medium:
        return RSSpacing.md;
      case RSSpacerSize.lg:
        return RSSpacing.lg;
      case RSSpacerSize.xl:
        return RSSpacing.xl;
      case RSSpacerSize.xxl:
        return RSSpacing.xxl;
      case RSSpacerSize.xxxl:
        return RSSpacing.xxxl;
      case RSSpacerSize.huge:
        return RSSpacing.huge;
      case RSSpacerSize.massive:
        return RSSpacing.massive;
    }
  }
}

enum RSSpacerSize {
  xs,
  sm,
  medium,
  lg,
  xl,
  xxl,
  xxxl,
  huge,
  massive,
}

/// ┌─────────────────────────────────────────────────────────────────────┐
/// │ RS ANIMATED WRAPPER - Reusable animations                           │
/// └─────────────────────────────────────────────────────────────────────┘

class RSAnimatedScale extends StatefulWidget {
  const RSAnimatedScale({
    super.key,
    required this.child,
    this.duration = RSMotion.normal,
    this.curve = RSMotion.standardCurve,
    this.begin = 0.95,
    this.end = 1.0,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  final Duration delay;

  @override
  State<RSAnimatedScale> createState() => _RSAnimatedScaleState();
}

class _RSAnimatedScaleState extends State<RSAnimatedScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: Opacity(opacity: _animation.value, child: child),
      ),
      child: widget.child,
    );
  }
}

class RSAnimatedFade extends StatefulWidget {
  const RSAnimatedFade({
    super.key,
    required this.child,
    this.duration = RSMotion.normal,
    this.curve = RSMotion.standardCurve,
    this.begin = 0.0,
    this.end = 1.0,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  final Duration delay;

  @override
  State<RSAnimatedFade> createState() => _RSAnimatedFadeState();
}

class _RSAnimatedFadeState extends State<RSAnimatedFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

class RSAnimatedSlide extends StatefulWidget {
  const RSAnimatedSlide({
    super.key,
    required this.child,
    this.duration = RSMotion.normal,
    this.curve = RSMotion.standardCurve,
    this.begin = const Offset(0, 20),
    this.end = Offset.zero,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset begin;
  final Offset end;
  final Duration delay;

  @override
  State<RSAnimatedSlide> createState() => _RSAnimatedSlideState();
}

class _RSAnimatedSlideState extends State<RSAnimatedSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Staggered list animation
class RSStaggeredList extends StatelessWidget {
  const RSStaggeredList({
    super.key,
    required this.children,
    this.itemDelay = RSMotion.staggerBase,
    this.maxDelay = RSMotion.staggerMax,
    this.animationBuilder,
  });

  final List<Widget> children;
  final Duration itemDelay;
  final Duration maxDelay;
  final Widget Function(Widget child, int index, Animation<double> animation)? animationBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        final delay = Duration(
          milliseconds: (itemDelay.inMilliseconds * index).clamp(
            0,
            maxDelay.inMilliseconds,
          ),
        );
        final child = children[index];

        if (animationBuilder != null) {
          return RSAnimatedFade(
            delay: delay,
            child: child,
          );
        }

        return RSAnimatedSlide(
          delay: delay,
          begin: const Offset(0, 20),
          child: child,
        );
      }),
    );
  }
}