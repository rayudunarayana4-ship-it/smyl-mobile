import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_empty_state.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/claim_model.dart';
import '../../../shared/services/app_repository.dart';

class ClaimsListScreen extends ConsumerWidget {
  const ClaimsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final claims = repo.claims;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'CLAIMS & DISPUTES VAULT',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.electricCyan,
        foregroundColor: AppColors.obsidian,
        icon: const Icon(Icons.add_moderator_rounded),
        label: Text(
          'Report Issue',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.obsidian,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: () => context.push(AppRoutes.fileClaim),
      ),
      body: SafeArea(
        child: claims.isEmpty
            ? SmylEmptyState(
                icon: Icons.shield_outlined,
                title: 'No Active Claims',
                message:
                    'All your shipments and traveller deliveries have completed without operational dispute.',
                actionText: 'File a Claim',
                onAction: () => context.push(AppRoutes.fileClaim),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: claims.length,
                itemBuilder: (context, index) {
                  final claim = claims[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SmylCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                claim.id,
                                style: AppTypography.labelUppercase.copyWith(
                                  color: AppColors.electricCyan,
                                  fontSize: 10,
                                ),
                              ),
                              SmylStatusBadge(
                                customLabel: claim.status.label,
                                customColor: _getClaimStatusColor(claim.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Text(
                            claim.issueType.label,
                            style: AppTypography.headlineMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Associated Transaction: ${claim.transactionId}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.champagneSand,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            claim.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateLight,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Escrow & Resolution Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.deepSpace,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'DECLARED CARGO VALUE:',
                                      style:
                                          AppTypography.labelUppercase.copyWith(
                                        fontSize: 9,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                    Text(
                                      '₹${claim.declaredItemValue.toStringAsFixed(0)}',
                                      style:
                                          AppTypography.titleMedium.copyWith(
                                        color: AppColors.warmIvory,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                if (claim.resolutionSummary != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    claim.resolutionSummary!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filed on ${DateFormat('dd MMM yyyy').format(claim.createdAt)}',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.slate,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push(
                                    '${AppRoutes.tracking}/${claim.transactionId}',
                                  );
                                },
                                child: Text(
                                  'View Consignment',
                                  style: AppTypography.labelUppercase.copyWith(
                                    color: AppColors.electricCyan,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getClaimStatusColor(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.claimOpen:
      case ClaimStatus.actionRequired:
        return AppColors.warning;
      case ClaimStatus.underReview:
        return AppColors.electricCyan;
      case ClaimStatus.resolved:
        return AppColors.success;
      case ClaimStatus.disputed:
        return AppColors.danger;
    }
  }
}
