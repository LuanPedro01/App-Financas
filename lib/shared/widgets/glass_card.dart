import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:financeiro/core/theme/app_colors.dart';
import 'package:financeiro/core/theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.border,
    this.blur = 12.0,
    this.opacity = 0.08,
    this.boxShadow,
    this.onTap,
    this.height,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;
  final double blur;
  final double opacity;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(AppSpacing.cardRadius);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            height: height,
            width: width,
            padding: padding ?? AppSpacing.cardInsets,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.white.withOpacity(opacity),
                      AppColors.white.withOpacity(opacity * 0.5),
                    ],
                  ),
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: AppColors.white.withOpacity(0.12),
                    width: 1,
                  ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.gradient,
    this.onTap,
    this.boxShadow,
    this.border,
    this.height,
    this.width,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.cardRadius);

    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? scheme.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: border ??
            Border.all(
              color: scheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? AppSpacing.cardInsets,
            child: child,
          ),
        ),
      ),
    );
  }
}
