import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmylCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final Color? backgroundColor;
  final double borderRadius;

  const SmylCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.isHighlighted = false,
    this.backgroundColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final borderGradient = isHighlighted
        ? const LinearGradient(
            colors: [AppColors.electricCyan, AppColors.auroraTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderGradient == null
            ? Border.all(
                color: isHighlighted
                    ? AppColors.electricCyan
                    : AppColors.surfaceBorder,
                width: isHighlighted ? 1.5 : 1.0,
              )
            : null,
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.electricCyan.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
