import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// ==============================================================================
/// SMYL GLOBAL — PREMIUM CARD CONTAINER
/// ==============================================================================
class SmylCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final Color? backgroundColor;
  final double borderRadius;
  final Border? customBorder;

  const SmylCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.isHighlighted = false,
    this.backgroundColor,
    this.borderRadius = AppRadius.card,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final border = customBorder ??
        Border.all(
          color: isHighlighted
              ? AppColors.electricCyan.withOpacity(0.8)
              : AppColors.surfaceBorder,
          width: isHighlighted ? 1.5 : 1.0,
        );

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isHighlighted ? AppColors.cardElevated : AppColors.surfaceCard),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.electricCyan.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.electricCyan.withOpacity(0.08),
            highlightColor: AppColors.electricCyan.withOpacity(0.04),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}
