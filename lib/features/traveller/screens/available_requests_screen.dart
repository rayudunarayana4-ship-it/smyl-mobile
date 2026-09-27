import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_empty_state.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class AvailableRequestsScreen extends ConsumerWidget {
  const AvailableRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    // Find all shipments looking for matches or pending requests
    final incomingRequests = repo.shipments.where((s) {
      return s.status == TransactionStatus.openForMatching ||
          s.status == TransactionStatus.created;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'INCOMING CONSIGNMENT REQUESTS',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: incomingRequests.isEmpty
            ? SmylEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No Incoming Requests',
                message:
                    'Your active flight routes are currently open. When senders book capacity, requests will appear here.',
                actionText: 'Post New Journey',
                onAction: () => context.push(AppRoutes.postJourney),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: incomingRequests.length,
                itemBuilder: (context, index) {
                  final req = incomingRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SmylCard(
                      isHighlighted: true,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.electricCyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.electricCyan.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'NEW REQUEST',
                                  style: AppTypography.labelUppercase.copyWith(
                                    color: AppColors.electricCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                'Reward: ₹${req.travellerPayout.toStringAsFixed(0)}',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.champagneSand,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Route
                          Row(
                            children: [
                              Text(
                                req.pickupCity,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: AppColors.electricCyan, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                req.destCity,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Text(
                            req.itemDescription,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.warmIvory,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Item Specs
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.deepSpace,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSpec('WEIGHT', '${req.weightKg} KG'),
                                Container(
                                    width: 1,
                                    height: 20,
                                    color: AppColors.surfaceBorder),
                                _buildSpec('CATEGORY', req.itemCategory.split(' ').first),
                                Container(
                                    width: 1,
                                    height: 20,
                                    color: AppColors.surfaceBorder),
                                _buildSpec('FRAGILE', req.isFragile ? 'YES' : 'NO',
                                    color: req.isFragile
                                        ? AppColors.warning
                                        : AppColors.warmIvory),
                                Container(
                                    width: 1,
                                    height: 20,
                                    color: AppColors.surfaceBorder),
                                _buildSpec(
                                    'VALUE', '₹${req.declaredValue.toStringAsFixed(0)}'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons: View Details, Accept, Reject
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SmylButton(
                                  text: 'Decline',
                                  variant: SmylButtonVariant.outline,
                                  height: 42,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Request declined.'),
                                        backgroundColor: AppColors.slateDark,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: SmylButton(
                                  text: 'Accept Consignment',
                                  variant: SmylButtonVariant.primary,
                                  height: 42,
                                  onPressed: () {
                                    // Match with traveller's first active journey
                                    final myJourney = repo.journeys.first;
                                    final newTx = repo.createTransactionFromMatch(
                                      shipment: req,
                                      journey: myJourney,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Consignment accepted! Transaction ${newTx.id} is now ACTIVE.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );

                                    context.push(
                                      '${AppRoutes.tracking}/${newTx.id}',
                                      extra: newTx,
                                    );
                                  },
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

  Widget _buildSpec(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            fontSize: 8,
            color: AppColors.slate,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.warmIvory,
          ),
        ),
      ],
    );
  }
}
