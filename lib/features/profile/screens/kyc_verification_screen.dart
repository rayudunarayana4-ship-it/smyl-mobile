import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_text_field.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/app_repository.dart';

class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  final _passportController = TextEditingController(text: 'Z8942104');
  bool _showForm = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passportController.dispose();
    super.dispose();
  }

  void _completeVerification() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showForm = false;
        });
        ref.read(appRepositoryProvider).updateKycStatus(
              KycStatus.verified,
              passportNumber: _passportController.text,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID verification complete! International carrying privileges active.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final user = repo.currentUser;
    final isVerified = user.kycStatus == KycStatus.verified;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'IDENTITY VERIFICATION',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trust & Security\nVerification',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verify your identity to unlock international luggage carry privileges.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 32),

              // Simple 3-step checklist
              SmylCard(
                isHighlighted: isVerified,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCheckItem(
                      title: 'Mobile Number Verified',
                      subtitle: user.phone,
                      isDone: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    _buildCheckItem(
                      title: 'Email Address Verified',
                      subtitle: user.email,
                      isDone: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    _buildCheckItem(
                      title: isVerified
                          ? 'ID Verification Complete'
                          : 'ID Verification Pending',
                      subtitle: isVerified
                          ? 'Passport ${user.passportNumber ?? "Z8942104"}'
                          : 'Passport or Government ID required',
                      isDone: isVerified,
                      isCurrent: !isVerified,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (!_showForm && !isVerified)
                SmylButton(
                  text: 'Complete Verification →',
                  variant: SmylButtonVariant.primary,
                  onPressed: () => setState(() => _showForm = true),
                )
              else if (_showForm) ...[
                Text(
                  'PASSPORT / GOVERNMENT ID',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.slateLight,
                  ),
                ),
                const SizedBox(height: 10),
                SmylTextField(
                  controller: _passportController,
                  label: 'DOCUMENT NUMBER',
                  hintText: 'e.g. Z8942104',
                  prefixIcon: const Icon(Icons.badge_outlined,
                      color: AppColors.slate, size: 20),
                ),
                const SizedBox(height: 20),
                SmylButton(
                  text: 'Submit for Verification',
                  variant: SmylButtonVariant.primary,
                  isLoading: _isSubmitting,
                  onPressed: _completeVerification,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.auroraTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.auroraTeal.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: AppColors.auroraTeal, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are fully verified. All international carrying routes and payouts are active.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warmIvory,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required String subtitle,
    required bool isDone,
    bool isCurrent = false,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.auroraTeal.withOpacity(0.18)
                : (isCurrent
                    ? AppColors.warning.withOpacity(0.18)
                    : AppColors.deepSpace),
            border: Border.all(
              color: isDone
                  ? AppColors.auroraTeal
                  : (isCurrent ? AppColors.warning : AppColors.surfaceBorder),
              width: 1.5,
            ),
          ),
          child: Icon(
            isDone
                ? Icons.check_rounded
                : (isCurrent ? Icons.circle : Icons.lock_outline_rounded),
            size: isDone ? 16 : (isCurrent ? 8 : 14),
            color: isDone
                ? AppColors.auroraTeal
                : (isCurrent ? AppColors.warning : AppColors.slate),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDone ? AppColors.warmIvory : AppColors.slateLight,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slate,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
