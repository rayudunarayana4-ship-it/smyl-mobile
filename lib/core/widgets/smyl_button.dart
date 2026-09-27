import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

enum SmylButtonVariant { primary, secondary, outline, ghost, danger, success }

/// ==============================================================================
/// SMYL GLOBAL — DESIGN SYSTEM BUTTON
/// ==============================================================================
class SmylButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SmylButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final double borderRadius;

  const SmylButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = SmylButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.height = 52.0,
    this.width = double.infinity,
    this.borderRadius = AppRadius.button,
  });

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (onPressed == null) return AppColors.slate;
      switch (variant) {
        case SmylButtonVariant.primary:
          return AppColors.obsidian; // High-contrast dark text on bright Aurora Cyan
        case SmylButtonVariant.secondary:
          return AppColors.warmIvory;
        case SmylButtonVariant.outline:
          return AppColors.electricCyan;
        case SmylButtonVariant.ghost:
          return AppColors.electricCyan;
        case SmylButtonVariant.danger:
          return AppColors.warmIvory;
        case SmylButtonVariant.success:
          return AppColors.obsidian;
      }
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: getTextColor()),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTypography.titleMedium.copyWith(
              color: getTextColor(),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ]
      ],
    );

    // Primary Button: Solid Aurora Cyan with dark text & subtle glow
    if (variant == SmylButtonVariant.primary) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: onPressed == null ? AppColors.slateDark : AppColors.electricCyan,
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.electricCyan.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.obsidian.withOpacity(0.12),
            highlightColor: AppColors.obsidian.withOpacity(0.06),
            child: Center(child: content),
          ),
        ),
      );
    }

    // Secondary Button: Dark surface (#111923) + Cyan border
    if (variant == SmylButtonVariant.secondary) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: onPressed == null ? AppColors.surfaceBorder : AppColors.electricCyan.withOpacity(0.8),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.electricCyan.withOpacity(0.08),
            highlightColor: AppColors.electricCyan.withOpacity(0.04),
            child: Center(child: content),
          ),
        ),
      );
    }

    // Outline / Ghost / Other variants
    Color getBgColor() {
      if (onPressed == null) return AppColors.surfaceCard;
      switch (variant) {
        case SmylButtonVariant.outline:
        case SmylButtonVariant.ghost:
          return Colors.transparent;
        case SmylButtonVariant.danger:
          return AppColors.danger;
        case SmylButtonVariant.success:
          return AppColors.success;
        default:
          return AppColors.surfaceCard;
      }
    }

    Border? getBorder() {
      if (variant == SmylButtonVariant.outline) {
        return Border.all(
          color: onPressed == null
              ? AppColors.surfaceBorder
              : AppColors.electricCyan.withOpacity(0.5),
          width: 1.2,
        );
      }
      return null;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: getBgColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: getBorder(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.electricCyan.withOpacity(0.08),
          child: Center(child: content),
        ),
      ),
    );
  }
}
