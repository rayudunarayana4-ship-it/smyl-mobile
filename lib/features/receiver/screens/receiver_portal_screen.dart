import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_logo.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class ReceiverPortalScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  final TransactionModel? transaction;

  const ReceiverPortalScreen({
    super.key,
    this.transactionId,
    this.transaction,
  });

  @override
  ConsumerState<ReceiverPortalScreen> createState() =>
      _ReceiverPortalScreenState();
}

class _ReceiverPortalScreenState extends ConsumerState<ReceiverPortalScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isDelivered = false;

  TransactionModel _getTransaction() {
    final repo = ref.watch(appRepositoryProvider);
    final targetId = widget.transactionId ?? widget.transaction?.id;
    if (targetId != null) {
      return repo.transactions.firstWhere(
        (t) => t.id == targetId,
        orElse: () => repo.primaryTransaction,
      );
    }
    return repo.primaryTransaction;
  }

  void _confirmReceipt() {
    final tx = _getTransaction();
    final entered = _otpController.text.trim();

    if (entered.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit delivery OTP.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isVerifying = false);
        final success = ref
            .read(appRepositoryProvider)
            .verifyDeliveryOtp(tx.id, entered);

        if (success) {
          setState(() => _isDelivered = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Invalid OTP! Expected delivery code: ${tx.destinationHandoverOtp}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = _getTransaction();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const SmylLogo(size: 28, showText: true),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _isDelivered || tx.status == TransactionStatus.delivered
              ? _buildDeliveryCompletedView(tx)
              : _buildReceiverPortalView(tx),
        ),
      ),
    );
  }

  Widget _buildReceiverPortalView(TransactionModel tx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Secure Token Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.deepSpace,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_rounded, size: 12, color: AppColors.auroraTeal),
              SizedBox(width: 6),
              Text(
                'SECURE RECEIVER PORTAL • NO ACCOUNT REQUIRED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.auroraTeal,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Incoming Handover for\n${tx.receiverName}',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You have a verified consignment arriving via international traveller assistance.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 24),

        // Shipment Card
        SmylCard(
          isHighlighted: true,
          padding: const EdgeInsets.all(18),
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
                    ),
                  ),
                  SmylStatusBadge(status: tx.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tx.itemDescription,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Weight: ${tx.weightKg} KG • Category: ${tx.itemCategory}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceBorder),
              ),
              _buildDetailRow('Sender', tx.senderName),
              const SizedBox(height: 6),
              _buildDetailRow(
                  'Verified Carrier', tx.travellerName ?? 'Vikramaditya Roy'),
              const SizedBox(height: 6),
              _buildDetailRow('Arrival Route',
                  '${tx.originCity} → ${tx.destCity} (${tx.destAirportCode})'),
              const SizedBox(height: 6),
              _buildDetailRow('Delivery Contact', tx.receiverPhone),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Confirm Receipt via OTP',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Only provide this OTP after you have physically received and inspected the unbroken package seals.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.champagneSand,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // OTP Display Preview (For testing / demonstration)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.deepSpace,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR DELIVERY OTP:',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.champagneSand,
                  fontSize: 10,
                ),
              ),
              Text(
                tx.destinationHandoverOtp,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.auroraTeal,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: AppTypography.displayMedium.copyWith(
            letterSpacing: 10.0,
            color: AppColors.auroraTeal,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••••',
            hintStyle: TextStyle(
              letterSpacing: 10.0,
              color: AppColors.slate.withOpacity(0.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() => _otpController.text = tx.destinationHandoverOtp);
            },
            icon: const Icon(Icons.flash_on_rounded,
                size: 16, color: AppColors.champagneSand),
            label: Text(
              'Auto-fill Secret OTP (${tx.destinationHandoverOtp})',
              style: AppTypography.labelAccent.copyWith(
                color: AppColors.champagneSand,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        SmylButton(
          text: 'Confirm Receipt & Complete Delivery',
          onPressed: _confirmReceipt,
          isLoading: _isVerifying,
          variant: SmylButtonVariant.primary,
        ),
        const SizedBox(height: 12),
        SmylButton(
          text: 'Track Courier Partner (SML-CP-829104) →',
          onPressed: () => context.push(AppRoutes.courierTracking, extra: tx),
          variant: SmylButtonVariant.outline,
        ),
      ],
    );
  }

  Widget _buildDeliveryCompletedView(TransactionModel tx) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withOpacity(0.18),
            border: Border.all(color: AppColors.success, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 52,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'DELIVERY CONFIRMED',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you, ${tx.receiverName}. Receipt of consignment ${tx.id} has been recorded on the immutable ledger. Carrier escrow has been released.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateLight,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 40),
        SmylButton(
          text: 'Return to Main App',
          onPressed: () => context.go(AppRoutes.mainShell),
          variant: SmylButtonVariant.primary,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.warmIvory,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
