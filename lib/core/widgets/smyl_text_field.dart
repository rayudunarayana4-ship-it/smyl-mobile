import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

/// ==============================================================================
/// SMYL GLOBAL — DESIGN SYSTEM TEXT FIELD
/// ==============================================================================
class SmylTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const SmylTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelUppercase.copyWith(
              color: AppColors.slateLight,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.warmIvory,
          ),
          cursorColor: AppColors.electricCyan,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceCard, // #111923
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.slate),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMd,
              borderSide: const BorderSide(color: AppColors.electricCyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
