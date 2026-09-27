import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final transactions = repo.transactions;

    final totalEarnings = transactions
        .where((t) => t.status == TransactionStatus.delivered)
        .fold(0.0, (sum, t) => sum + t.travellerPayout);

    final pendingEscrow = transactions
        .where((t) => t.status != TransactionStatus.delivered && !t.status.isException)
        .fold(0.0, (sum, t) => sum + t.travellerPayout);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'CARRIER EARNINGS & ESCROW',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Hero Earnings Card
            SmylCard(
              isHighlighted: true,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL AVAILABLE FOR PAYOUT',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.champagneSand,
                          fontSize: 10,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.4)),
                        ),
                        child: Text(
                          'ESCROW SETTLED',
                          style: AppTypography.labelUppercase.copyWith(
                            color: AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${(totalEarnings > 0 ? totalEarnings : 12450.0).toStringAsFixed(0)}',
                    style: AppTypography.currencyHighlight.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 16),

                  // Mini Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'PENDING IN ESCROW',
                          '₹${(pendingEscrow > 0 ? pendingEscrow : 5500.0).toStringAsFixed(0)}',
                          AppColors.warning,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.surfaceBorder,
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'COMPLETED TRIPS',
                          '${repo.currentUser.completedDeliveries}',
                          AppColors.auroraTeal,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColors.surfaceBorder,
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          'PAYOUT METHOD',
                          'HDFC Bank Wire',
                          AppColors.warmIvory,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SmylButton(
                    text: 'Request Instant Bank Payout',
                    variant: SmylButtonVariant.primary,
                    height: 44,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Payout transfer request of ₹12,450 submitted to automated clearing house.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weekly Carrying Velocity Chart (Bar representation)
            Text(
              'MONTHLY LOGISTICS VOLUME',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 10),
            SmylCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Carrier Activity (KG Carried)',
                        style: AppTypography.titleMedium.copyWith(fontSize: 13),
                      ),
                      Text(
                        'Total 24.5 KG',
                        style: AppTypography.labelAccent.copyWith(
                            color: AppColors.electricCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar('W1', 0.45, '4.5kg'),
                      _buildChartBar('W2', 0.85, '8.0kg', isHighlight: true),
                      _buildChartBar('W3', 0.35, '3.2kg'),
                      _buildChartBar('W4', 0.70, '6.8kg'),
                      _buildChartBar('W5', 0.20, '2.0kg'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transaction History
            Text(
              'CARRIER SETTLEMENT LEDGER',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 10),

            ...transactions.map((tx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SmylCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tx.id,
                            style: AppTypography.labelUppercase.copyWith(
                              color: AppColors.electricCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SmylStatusBadge(status: tx.status),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${tx.originCity} → ${tx.destCity}',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Net: ₹${tx.travellerPayout.toStringAsFixed(0)}',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.champagneSand,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        '${tx.itemDescription} (${tx.weightKg} KG)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateLight,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Fee Breakdown Row
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deepSpace,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gross: ₹${tx.totalAmount.toStringAsFixed(0)}',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            Text(
                              'SMYL Fee: -₹${tx.platformFee.toStringAsFixed(0)}',
                              style: AppTypography.bodySmall
                                  .copyWith(fontSize: 11, color: AppColors.slate),
                            ),
                            if (tx.courierFee > 0)
                              Text(
                                'Courier: -₹${tx.courierFee.toStringAsFixed(0)}',
                                style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11, color: AppColors.slate),
                              ),
                            Text(
                              DateFormat('dd MMM').format(tx.createdAt),
                              style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11, color: AppColors.slateLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelUppercase.copyWith(
            fontSize: 7.5,
            color: AppColors.slate,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(String label, double fillPercent, String value,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isHighlight ? AppColors.electricCyan : AppColors.slate,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.deepSpace,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 28,
            height: 90 * fillPercent,
            decoration: BoxDecoration(
              gradient: isHighlight
                  ? AppColors.brandGradient
                  : LinearGradient(
                      colors: [
                        AppColors.slateDark,
                        AppColors.slateDark.withOpacity(0.5)
                      ],
                    ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            fontSize: 9,
            color: AppColors.slateLight,
          ),
        ),
      ],
    );
  }
}
