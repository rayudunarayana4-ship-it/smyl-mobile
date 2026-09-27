import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'smyl_button.dart';

class SmylErrorView extends StatelessWidget {
  final String title;
  final String description;
  final String nextSteps;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String retryButtonText;
  final String secondaryButtonText;

  const SmylErrorView({
    super.key,
    this.title = 'Unable to Complete Request',
    this.description = 'A temporary network interruption or verification anomaly occurred.',
    this.nextSteps = 'Check your connection or attempt the operation again in a few moments.',
    this.onRetry,
    this.onSecondaryAction,
    this.retryButtonText = 'Retry Operation',
    this.secondaryButtonText = 'Return to Safety',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.warmIvory,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.deepSpace,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 15, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'WHAT HAPPENED',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.warning,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: AppColors.surfaceBorder),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 15, color: AppColors.electricCyan),
                      const SizedBox(width: 8),
                      Text(
                        'RECOMMENDED NEXT STEP',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.electricCyan,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextSteps,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              SmylButton(
                text: retryButtonText,
                onPressed: onRetry,
                variant: SmylButtonVariant.primary,
                height: 48,
              ),
            if (onSecondaryAction != null) ...[
              const SizedBox(height: 10),
              SmylButton(
                text: secondaryButtonText,
                onPressed: onSecondaryAction,
                variant: SmylButtonVariant.outline,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
