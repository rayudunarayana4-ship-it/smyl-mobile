import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_text_field.dart';
import '../../../shared/models/claim_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/services/app_repository.dart';

class FileClaimScreen extends ConsumerStatefulWidget {
  final String? initialTransactionId;
  final TransactionModel? initialTransaction;

  const FileClaimScreen({
    super.key,
    this.initialTransactionId,
    this.initialTransaction,
  });

  @override
  ConsumerState<FileClaimScreen> createState() => _FileClaimScreenState();
}

class _FileClaimScreenState extends ConsumerState<FileClaimScreen> {
  late String _selectedTransactionId;
  ClaimIssueType _selectedIssue = ClaimIssueType.damagedItem;
  final _descController = TextEditingController(
      text: 'Outer packaging was compromised and internal packaging dented upon arrival.');
  final _declaredValueController = TextEditingController(text: '8000');
  int _uploadedEvidenceCount = 2;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(appRepositoryProvider);
    _selectedTransactionId = widget.initialTransactionId ??
        widget.initialTransaction?.id ??
        (repo.transactions.isNotEmpty ? repo.transactions.first.id : 'SMYL-TRX-10482');
  }

  @override
  void dispose() {
    _descController.dispose();
    _declaredValueController.dispose();
    super.dispose();
  }

  void _submitClaim() {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the occurrence in detail.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final user = ref.read(appRepositoryProvider).currentUser;
        final newClaimId = 'CLM-${Random().nextInt(9000) + 1000}';

        final claim = ClaimModel(
          id: newClaimId,
          transactionId: _selectedTransactionId,
          userId: user.id,
          userName: user.name,
          issueType: _selectedIssue,
          description: _descController.text,
          declaredItemValue:
              double.tryParse(_declaredValueController.text) ?? 5000.0,
          evidenceFiles: ['damage_photo_01.jpg', 'air_waybill_scan.pdf'],
          status: ClaimStatus.claimOpen,
          resolutionSummary:
              'Escrow automatically locked. Compliance agent assigned.',
          createdAt: DateTime.now(),
        );

        ref.read(appRepositoryProvider).fileClaim(claim);

        // Put transaction on hold
        ref.read(appRepositoryProvider).toggleTransactionHold(
              _selectedTransactionId,
              true,
              'Claim $newClaimId initiated by ${user.name}',
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Claim $newClaimId registered. Escrow payout held pending investigation.'),
            backgroundColor: AppColors.warning,
          ),
        );

        context.go(AppRoutes.claims);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final transactions = repo.transactions;

    final issues = [
      {'label': 'Item damaged', 'type': ClaimIssueType.damagedItem, 'icon': Icons.broken_image_outlined},
      {'label': 'Delivery delayed', 'type': ClaimIssueType.courierIssue, 'icon': Icons.access_time_rounded},
      {'label': 'Wrong item', 'type': ClaimIssueType.lostItem, 'icon': Icons.help_outline_rounded},
      {'label': 'Other issue', 'type': ClaimIssueType.other, 'icon': Icons.more_horiz_rounded},
    ];

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'REPORT AN ISSUE',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Something went wrong?',
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.warmIvory,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tell us what happened so we can protect your escrow payment and resolve this quickly.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Transaction Selector
              Text(
                'SELECT SHIPMENT',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.midnight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTransactionId,
                    dropdownColor: AppColors.surfaceElevated,
                    isExpanded: true,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.warmIvory),
                    items: transactions.map((t) {
                      return DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(
                          '${t.id} • ${t.originCity} → ${t.destCity} (${t.itemCategory})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTransactionId = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Select Issue (Radio Chips)
              Text(
                'SELECT ISSUE',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: issues.map((item) {
                  final type = item['type'] as ClaimIssueType;
                  final isSelected = _selectedIssue == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIssue = type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.electricCyan.withOpacity(0.08)
                              : AppColors.midnight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.electricCyan
                                : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? AppColors.electricCyan
                                  : AppColors.slateLight,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.warmIvory
                                      : AppColors.slateLight,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? AppColors.electricCyan
                                  : AppColors.slate,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Explain Briefly Text Box
              SmylTextField(
                controller: _descController,
                label: 'EXPLAIN BRIEFLY',
                hintText: 'Describe what happened with your parcel or delivery...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Upload Photo
              Text(
                'UPLOAD PHOTO',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() => _uploadedEvidenceCount++);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo attached successfully.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.midnight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: AppColors.electricCyan, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _uploadedEvidenceCount > 0
                            ? '+ Add Photo ($_uploadedEvidenceCount attached)'
                            : '+ Add Photo',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.electricCyan,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Protective Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: AppColors.champagneSand, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Escrow payout is instantly held until our resolution team reviews your report.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateLight,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SmylButton(
                text: 'Submit Report',
                onPressed: _submitClaim,
                isLoading: _isSubmitting,
                variant: SmylButtonVariant.primary,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
