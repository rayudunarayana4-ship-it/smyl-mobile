import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel? transaction;

  const TransactionDetailScreen({
    super.key,
    this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = transaction ?? repo.primaryTransaction;

    final isPaid = tx.status != TransactionStatus.openForMatching &&
        tx.status != TransactionStatus.travellerRequested;
    final isHandoverDone = tx.status.standardProgressIndex >= 5;
    final isDelivered = tx.status == TransactionStatus.completed ||
        tx.status == TransactionStatus.delivered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shipment Overview',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shipment link copied: smyl.global/track/${tx.id}'),
                  backgroundColor: AppColors.surfaceCard,
                ),
              );
            },
            tooltip: 'Share Shipment Link',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Customer Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.electricCyan.withOpacity(0.15),
                    AppColors.surfaceCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.electricCyan.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.obsidian,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          tx.id,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.electricCyan,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDelivered
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isDelivered ? 'COMPLETED' : 'IN WORKFLOW',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDelivered ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tx.status.customerStatusText,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tx.status.customerSubtext,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Route & Consignment Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.originAirportCode,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.warmIvory,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            tx.originCity,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.flight_takeoff, color: AppColors.electricCyan, size: 22),
                          const SizedBox(height: 2),
                          Text(
                            'EK-527',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.electricCyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tx.destAirportCode,
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.warmIvory,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            tx.destCity,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item Description',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                      ),
                      Text(
                        '${tx.weightKg} KG • ${tx.itemDescription}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warmIvory,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4-Stage Operational Checklist
            Text(
              'Delivery Process Checklist',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.warmIvory,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Escrow Payment
            _buildChecklistCard(
              context: context,
              stepNum: '1',
              title: 'Escrow Payment',
              subtitle: isPaid
                  ? 'Locked: ₹${tx.totalAmount.toInt()} (Ref: ${tx.paymentReference ?? "SMYL-PAY-2026-008721"})'
                  : 'Pending authorization of ₹${tx.totalAmount.toInt()}',
              isDone: isPaid,
              actionLabel: isPaid ? 'View Receipt' : 'Pay Now',
              onAction: () {
                if (isPaid) {
                  context.push(AppRoutes.paymentReceipt);
                } else {
                  context.push(AppRoutes.payment);
                }
              },
            ),

            const SizedBox(height: 12),

            // 2. Traveller Assignment
            _buildChecklistCard(
              context: context,
              stepNum: '2',
              title: 'Verified Traveller',
              subtitle: tx.travellerName != null
                  ? '${tx.travellerName} • Flight EK-527 (10 Oct)'
                  : 'Matching with verified international travellers',
              isDone: tx.travellerName != null,
              actionLabel: tx.travellerName != null ? 'Traveller Profile' : 'Find Traveller',
              onAction: () {
                if (tx.travellerName != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Traveller Arjun Reddy: KYC Verified, 4.9★ rating (34 trips).'),
                      backgroundColor: AppColors.surfaceCard,
                    ),
                  );
                } else {
                  context.push(AppRoutes.findTraveller);
                }
              },
            ),

            const SizedBox(height: 12),

            // 3. Physical Handover
            _buildChecklistCard(
              context: context,
              stepNum: '3',
              title: 'Origin Handover',
              subtitle: isHandoverDone
                  ? 'Handover completed at Rajiv Gandhi Int\'l Airport'
                  : 'Meet at Departure Gate 4 • Share Origin OTP: ${tx.originHandoverOtp}',
              isDone: isHandoverDone,
              actionLabel: 'Handover Details',
              onAction: () {
                context.push('${AppRoutes.otpHandover}/${tx.id}');
              },
            ),

            const SizedBox(height: 12),

            // 4. Onward Courier & Delivery
            _buildChecklistCard(
              context: context,
              stepNum: '4',
              title: 'Courier & Final Handover',
              subtitle: 'SMYL Logistics Partner (SML-CP-829104) • Delivery OTP: ${tx.destinationHandoverOtp}',
              isDone: isDelivered,
              actionLabel: 'Courier Tracking',
              onAction: () {
                context.push(AppRoutes.courierTracking);
              },
            ),

            const SizedBox(height: 24),

            // Main Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                context.push('${AppRoutes.tracking}/${tx.id}');
              },
              icon: const Icon(Icons.near_me, color: AppColors.obsidian),
              label: const Text('OPEN LIVE TIMELINE & MAP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricCyan,
                foregroundColor: AppColors.obsidian,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                context.push(AppRoutes.courierTracking);
              },
              icon: const Icon(Icons.local_shipping_outlined, color: AppColors.warmIvory),
              label: const Text('TRACK COURIER PARTNER (SML-CP-829104)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard({
    required BuildContext context,
    required String stepNum,
    required String title,
    required String subtitle,
    required bool isDone,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? AppColors.success.withOpacity(0.3)
              : AppColors.surfaceBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.obsidian,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? AppColors.success : AppColors.surfaceBorder,
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 18, color: AppColors.success)
                : Text(
                    stepNum,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.slateLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.warmIvory,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.electricCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
