import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/theme/app_theme.dart';

/// Liquid Glass bottom navigation bar.
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: GlassTokens.spacingLG,
          vertical: GlassTokens.spacingSM,
        ),
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            blur: GlassTokens.blurMedium,
            ambientStrength: GlassTokens.ambientLight,
            lightAngle: 0.2 * math.pi,
            glassColor: isDark ? Colors.white12 : Colors.white60,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: LiquidGlass.inLayer(
                    shape: LiquidRoundedSuperellipse(
                      borderRadius: Radius.circular(GlassTokens.radiusFull),
                    ),
                    glassContainsChild: false,
                    child: AnimatedContainer(
                      duration: GlassTokens.animMedium,
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: isActive ? 16 : 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: GlassTokens.animMedium,
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? AppTheme.accent(context)
                                  : AppTheme.textTertiary(context),
                              size: isActive ? 26 : 24,
                            ),
                          ),
                          SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: GlassTokens.animMedium,
                            style: AppTheme.labelSmall.copyWith(
                              color: isActive
                                  ? AppTheme.accent(context)
                                  : AppTheme.textTertiary(context),
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: isActive ? 11 : 10,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const GlassNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

