import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/theme/app_theme.dart';

/// Liquid Glass app bar.
class GlassAppBar extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;

  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: GlassTokens.spacingMD,
          vertical: GlassTokens.spacingSM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: GlassTokens.spacingSM),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTheme.headlineLarge.copyWith(
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                if (actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!
                        .map((a) => Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: a,
                            ))
                        .toList(),
                  ),
              ],
            ),
            if (bottom != null) ...[
              SizedBox(height: GlassTokens.spacingSM),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Small icon button wrapped in Liquid Glass.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final Color? color;
  final String? badge;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          LiquidGlass(
            settings: LiquidGlassSettings(
              blur: GlassTokens.blurLight,
              ambientStrength: GlassTokens.ambientLight,
              lightAngle: -0.2 * math.pi,
              glassColor: isDark ? Colors.white12 : Colors.white60,
            ),
            shape: LiquidRoundedSuperellipse(
              borderRadius: Radius.circular(GlassTokens.radiusFull),
            ),
            glassContainsChild: false,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                icon,
                color: color ?? AppTheme.textPrimary(context),
                size: size ?? 24,
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.error(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



