import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/services/app_repository.dart';
import '../../../shared/services/payment_service.dart';

class PaymentReceiptScreen extends ConsumerWidget {
  final PaymentReceipt? receipt;
  final TransactionModel? transaction;

  const PaymentReceiptScreen({
    super.key,
    this.receipt,
    this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = transaction ?? repo.primaryTransaction;
    final r = receipt ?? repo.getPaymentReceipt(tx.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Confirmation',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(AppRoutes.mainShell),
            tooltip: 'Return to Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success Card Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.15),
                    AppColors.surfaceCard,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Escrow Deposit Secured',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Funds locked in SMYL Secure Escrow',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₹${r.totalAmount.toInt()}',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.electricCyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.obsidian,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Text(
                      'Ref: ${r.paymentReference}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.slateLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Receipt Breakdown Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Information',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow('Shipment ID', tx.id, isHighlight: true),
                  _buildDetailRow('Paid By', r.paidBy),
                  _buildDetailRow('Payment Method', r.paymentMethod),
                  _buildDetailRow('Escrow Account', r.paidToEscrowAccount),
                  _buildDetailRow('Paid At', _formatDateTime(r.paidAt)),
                  const Divider(height: 24),
                  _buildDetailRow('Traveller Delivery Reward', '₹${r.deliveryCharge.toInt()}'),
                  _buildDetailRow('Platform Protection Fee', '₹${r.platformFee.toInt()}'),
                  _buildDetailRow('Onward Courier Fee', '₹${r.courierFee.toInt()}'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Escrow Charged',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.warmIvory,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '₹${r.totalAmount.toInt()}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.electricCyan,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Next Steps Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist_rounded, color: AppColors.electricCyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Next Steps',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmIvory,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildStepItem(
                    step: '1',
                    title: 'Airport Handover',
                    subtitle: 'Meet Arjun Reddy at HYD Gate 4. Share Origin OTP: 482913.',
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    step: '2',
                    title: 'Flight EK-527 to Dubai',
                    subtitle: 'Track live progress from Hyderabad to Dubai Airport.',
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    step: '3',
                    title: 'Local Courier Handover',
                    subtitle: 'Dispatched via SMYL Logistics Partner (SML-CP-829104).',
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    step: '4',
                    title: 'Delivery Verification',
                    subtitle: 'Rahul Kumar confirms receipt with secret OTP 739104 to release payout.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Primary Navigation Buttons
            ElevatedButton(
              onPressed: () {
                context.push('${AppRoutes.tracking}/${tx.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricCyan,
                foregroundColor: AppColors.obsidian,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.near_me_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'VIEW LIVE TRACKING',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.obsidian,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Receipt downloaded: SMYL-RECEIPT-${tx.id}.pdf',
                      style: const TextStyle(color: AppColors.warmIvory),
                    ),
                    backgroundColor: AppColors.surfaceCard,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, color: AppColors.warmIvory),
              label: const Text('Download Official PDF Receipt'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => context.go(AppRoutes.mainShell),
              child: Text(
                'Back to Home Dashboard',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                color: isHighlight ? AppColors.electricCyan : AppColors.warmIvory,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.electricCyan.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.electricCyan, width: 1),
          ),
          child: Text(
            step,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.electricCyan,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warmIvory,
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
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hr = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hr:$min $ampm';
  }
}
