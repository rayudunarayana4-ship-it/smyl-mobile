import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum SmylButtonVariant { primary, secondary, outline, ghost, danger, success }

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
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (onPressed == null) return AppColors.slate;
      switch (variant) {
        case SmylButtonVariant.primary:
          return AppColors.obsidian;
        case SmylButtonVariant.secondary:
          return AppColors.warmIvory;
        case SmylButtonVariant.outline:
          return AppColors.warmIvory;
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

    if (variant == SmylButtonVariant.primary) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [AppColors.electricCyan, AppColors.auroraTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: onPressed == null ? AppColors.slateDark : null,
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: AppColors.electricCyan.withOpacity(0.28),
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
            child: Center(child: content),
          ),
        ),
      );
    }

    Color getBgColor() {
      if (onPressed == null) return AppColors.deepSpace;
      switch (variant) {
        case SmylButtonVariant.secondary:
          return AppColors.surfaceElevated;
        case SmylButtonVariant.outline:
        case SmylButtonVariant.ghost:
          return Colors.transparent;
        case SmylButtonVariant.danger:
          return AppColors.danger;
        case SmylButtonVariant.success:
          return AppColors.success;
        case SmylButtonVariant.primary:
          return AppColors.electricCyan;
      }
    }

    Border? getBorder() {
      if (variant == SmylButtonVariant.outline) {
        return Border.all(
          color: onPressed == null
              ? AppColors.surfaceBorder
              : AppColors.surfaceBorderHighlight.withOpacity(0.6),
          width: 1.2,
        );
      }
      if (variant == SmylButtonVariant.secondary) {
        return Border.all(color: AppColors.surfaceBorder, width: 1.0);
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
          child: Center(child: content),
        ),
      ),
    );
  }
}
