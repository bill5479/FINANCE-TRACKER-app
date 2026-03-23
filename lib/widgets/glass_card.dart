import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/theme/app_theme.dart';

/// Reusable glassmorphic card with Liquid Glass effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? blur;
  final Color? glassColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.glassColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          settings: LiquidGlassSettings(
            blur: blur ?? GlassTokens.blurMedium,
            ambientStrength: GlassTokens.ambientLight,
            lightAngle: 0.2 * math.pi,
            glassColor: glassColor ?? (isDark ? Colors.white12 : Colors.white60),
            thickness: GlassTokens.thicknessLight,
          ),
          shape: LiquidRoundedSuperellipse(
            borderRadius: Radius.circular(borderRadius ?? GlassTokens.radiusLarge),
          ),
          glassContainsChild: false,
          child: Container(
            width: width,
            height: height,
            padding: padding ?? EdgeInsets.all(GlassTokens.spacingLG),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A variant for simple glass containers without the full LiquidGlass widget
/// (used for older Flutter versions or fallback).
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(GlassTokens.spacingLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? GlassTokens.radiusLarge),
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.7),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

