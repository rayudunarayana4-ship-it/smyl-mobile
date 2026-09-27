import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class OtpHandoverScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  final TransactionModel? transaction;

  const OtpHandoverScreen({
    super.key,
    this.transactionId,
    this.transaction,
  });

  @override
  ConsumerState<OtpHandoverScreen> createState() => _OtpHandoverScreenState();
}

class _OtpHandoverScreenState extends ConsumerState<OtpHandoverScreen> {
  final _otpController = TextEditingController();
  bool _isOriginHandover = true;
  bool _isProcessing = false;
  bool _handoverConfirmed = false;

  @override
  void initState() {
    super.initState();
    final tx = _getTransaction();
    if (tx.status.standardProgressIndex >= 5) {
      _isOriginHandover = false;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  TransactionModel _getTransaction() {
    final repo = ref.read(appRepositoryProvider);
    final targetId = widget.transactionId ?? widget.transaction?.id;
    if (targetId != null) {
      return repo.transactions.firstWhere(
        (t) => t.id == targetId,
        orElse: () => repo.primaryTransaction,
      );
    }
    return repo.primaryTransaction;
  }

  void _verifyOtp() {
    final tx = _getTransaction();
    final code = _otpController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit handshake OTP.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isProcessing = false);

        bool success = false;
        if (_isOriginHandover) {
          success = ref
              .read(appRepositoryProvider)
              .verifyOriginHandoverOtp(tx.id, code);
        } else {
          success = ref
              .read(appRepositoryProvider)
              .verifyDeliveryOtp(tx.id, code);
        }

        if (success) {
          setState(() => _handoverConfirmed = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid OTP! Expected ${_isOriginHandover ? tx.originHandoverOtp : tx.destinationHandoverOtp}',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    });
  }

  void _autoFillOtp() {
    final tx = _getTransaction();
    setState(() {
      _otpController.text =
          _isOriginHandover ? tx.originHandoverOtp : tx.destinationHandoverOtp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final targetId = widget.transactionId ?? widget.transaction?.id;
    final tx = targetId != null
        ? repo.transactions.firstWhere(
            (t) => t.id == targetId,
            orElse: () => repo.primaryTransaction,
          )
        : repo.primaryTransaction;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'SECURE OTP HANDOVER',
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
              // Handover Stage Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStageTab(
                        '1. ORIGIN (SENDER → TRAVELLER)',
                        isSelected: _isOriginHandover,
                        onTap: () {
                          setState(() {
                            _isOriginHandover = true;
                            _handoverConfirmed = false;
                            _otpController.clear();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildStageTab(
                        '2. DELIVERY (TRAVELLER → RECEIVER)',
                        isSelected: !_isOriginHandover,
                        onTap: () {
                          setState(() {
                            _isOriginHandover = false;
                            _handoverConfirmed = false;
                            _otpController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_handoverConfirmed)
                _buildSuccessState(tx)
              else
                _buildInputState(tx),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageTab(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricCyan.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.electricCyan)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.electricCyan : AppColors.slate,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputState(TransactionModel tx) {
    final expectedCode =
        _isOriginHandover ? tx.originHandoverOtp : tx.destinationHandoverOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transaction Info Card
        SmylCard(
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
              const SizedBox(height: 10),
              Text(
                '${tx.originCity} → ${tx.destCity}',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${tx.itemDescription} (${tx.weightKg} KG)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isOriginHandover
                        ? 'Handover Party: ${tx.travellerName}'
                        : 'Receiver Party: ${tx.receiverName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isOriginHandover ? 'Terminal Gate 4' : 'Dubai Marina',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.champagneSand,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Text(
          _isOriginHandover ? 'Origin Handover Protocol' : 'Final Receipt Protocol',
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isOriginHandover
            ? 'The sender generates this code. The traveller inspects cargo and validates this 6-digit OTP to assume legal carriage custody.'
            : 'The receiver provides their secret OTP upon receiving and physically checking the intact package.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.slateLight,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Secret OTP display preview (for test ease)
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
                'AUTHORIZED SECURITY TOKEN:',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.champagneSand,
                  fontSize: 10,
                ),
              ),
              Text(
                expectedCode,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.electricCyan,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 6-digit OTP Text Field
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: AppTypography.displayMedium.copyWith(
            letterSpacing: 10.0,
            color: AppColors.electricCyan,
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

        const SizedBox(height: 14),

        Center(
          child: TextButton.icon(
            onPressed: _autoFillOtp,
            icon: const Icon(Icons.flash_on_rounded,
                size: 16, color: AppColors.champagneSand),
            label: Text(
              'Auto-fill Handshake OTP ($expectedCode)',
              style: AppTypography.labelAccent.copyWith(
                color: AppColors.champagneSand,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        SmylButton(
          text: _isOriginHandover
              ? 'Confirm Origin Handover'
              : 'Confirm Receipt & Unlock Payout',
          onPressed: _verifyOtp,
          isLoading: _isProcessing,
          variant: SmylButtonVariant.primary,
        ),
      ],
    );
  }

  Widget _buildSuccessState(TransactionModel tx) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withOpacity(0.18),
            border: Border.all(color: AppColors.success, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 20,
              )
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 44,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isOriginHandover ? 'HANDOVER CONFIRMED' : 'DELIVERY CONFIRMED',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.warmIvory,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isOriginHandover
              ? 'Physical handover validated. Status is now HANDED TO TRAVELLER. In-flight coverage active.'
              : 'Recipient confirmed receipt. Status is now DELIVERED. Carrier payout of ₹${tx.travellerPayout.toStringAsFixed(0)} released from escrow.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateLight,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        SmylButton(
          text: 'Return to Live Tracking',
          onPressed: () {
            context.push(
              '${AppRoutes.tracking}/${tx.id}',
              extra: tx,
            );
          },
          variant: SmylButtonVariant.primary,
        ),
      ],
    );
  }
}
