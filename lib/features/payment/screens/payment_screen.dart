import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/services/app_repository.dart';
import '../../../shared/services/payment_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const PaymentScreen({
    super.key,
    this.transaction,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedMethodIndex = 0; // 0: UPI, 1: QR Code, 2: Cards
  final TextEditingController _upiController =
      TextEditingController(text: 'lakshmi.narayana@okaxis');
  bool _isProcessing = false;
  String _processingStageText = '';
  bool _isUpiValid = true;

  // QR Modal Timer State
  Timer? _qrTimer;
  int _qrCountdownSeconds = 582; // 09:42 initial

  @override
  void initState() {
    super.initState();
    _validateUpi(_upiController.text);
  }

  @override
  void dispose() {
    _upiController.dispose();
    _qrTimer?.cancel();
    super.dispose();
  }

  void _validateUpi(String value) {
    final repo = ref.read(appRepositoryProvider);
    setState(() {
      _isUpiValid = repo.paymentService.validateUpiId(value);
    });
  }

  Future<void> _handleUpiPayment(TransactionModel tx) async {
    if (!_isUpiValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID (e.g. name@bank)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStageText = 'Connecting to Secure Escrow Gateway...';
    });

    final repo = ref.read(appRepositoryProvider);

    try {
      final receipt = await repo.payWithUpi(
        transactionId: tx.id,
        upiId: _upiController.text.trim(),
        onProgress: (stage, message) {
          if (mounted) {
            setState(() {
              _processingStageText = message;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Navigate to Digital Receipt Screen
        context.push(
          AppRoutes.paymentReceipt,
          extra: {
            'receipt': receipt,
            'transaction': repo.primaryTransaction,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initiation failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showQrPaymentModal(TransactionModel tx) {
    _qrCountdownSeconds = 582;
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCountdownSeconds > 0) {
        if (mounted) {
          setState(() {
            _qrCountdownSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalStateContext, setModalState) {
            final mins = (_qrCountdownSeconds ~/ 60).toString().padLeft(2, '0');
            final secs = (_qrCountdownSeconds % 60).toString().padLeft(2, '0');

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.slate,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Scan & Pay via Any UPI App',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Google Pay • PhonePe • Paytm • BHIM',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Simulated High Fidelity QR Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricCyan.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Stylized QR pattern simulation
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12, width: 2),
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                ),
                                itemCount: 49,
                                itemBuilder: (context, index) {
                                  // Corner targets or pseudo QR pattern
                                  final isCorner = (index <= 1 || index == 7 || index == 8) ||
                                      (index >= 5 && index <= 6 || index == 12 || index == 13) ||
                                      (index >= 42 && index <= 43 || index == 35 || index == 36);
                                  final isFilled = isCorner || (index % 3 == 0) || (index % 5 == 1);
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isFilled ? Colors.black : Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.obsidian,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.electricCyan, width: 1.5),
                              ),
                              child: Text(
                                'SMYL',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.electricCyan,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${tx.totalAmount.toInt()}',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Ref: ${MockPaymentService.defaultPaymentRef}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Countdown Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'QR code expires in $mins:$secs',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Simulate instant payment for reviewer/user
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(modalContext);
                      setState(() {
                        _isProcessing = true;
                        _processingStageText = 'Confirming QR payment from bank...';
                      });

                      final repo = ref.read(appRepositoryProvider);
                      final receipt = await repo.payWithQr(transactionId: tx.id);

                      if (mounted) {
                        setState(() {
                          _isProcessing = false;
                        });
                        context.push(
                          AppRoutes.paymentReceipt,
                          extra: {
                            'receipt': receipt,
                            'transaction': repo.primaryTransaction,
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.obsidian),
                    label: const Text('Simulate Successful QR Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricCyan,
                      foregroundColor: AppColors.obsidian,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(modalContext),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _qrTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = widget.transaction ?? repo.primaryTransaction;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escrow Payment',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  '100% Protected',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricCyan),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Securing Escrow Payment',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.warmIvory,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _processingStageText,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.electricCyan,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(
                        'Your funds remain locked in SMYL Escrow until you confirm delivery.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Consignment & Route Header
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.electricCyan.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: AppColors.electricCyan,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${tx.originCity} (${tx.originAirportCode}) → ${tx.destCity} (${tx.destAirportCode})',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warmIvory,
                                    ),
                                  ),
                                  Text(
                                    'Traveller: ${tx.travellerName ?? "Arjun Reddy"} • Flight EK-527',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.slateLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Consignment Item',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                            ),
                            Text(
                              '${tx.weightKg} KG • Pashmina & Sweets',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.warmIvory,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ID',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                            ),
                            Text(
                              tx.id,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.electricCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transparent Cost Breakdown Card
                  Text(
                    'Cost Breakdown',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _buildFeeRow(
                          'Traveller Delivery Reward',
                          '₹${tx.travellerPayout.toInt()}',
                          'Paid directly to traveller upon OTP confirmation',
                        ),
                        const SizedBox(height: 10),
                        _buildFeeRow(
                          'SMYL Protection & Platform Fee',
                          '₹${tx.platformFee.toInt()}',
                          'Includes insurance, KYC verification & 24/7 support',
                        ),
                        const SizedBox(height: 10),
                        _buildFeeRow(
                          'Onward Courier Partner Fee',
                          '₹${tx.courierFee.toInt()}',
                          'Doorstep dispatch from Dubai Gateway to receiver',
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Escrow Deposit',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warmIvory,
                                  ),
                                ),
                                Text(
                                  'Guaranteed refundable until physical handover',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.slateLight,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${tx.totalAmount.toInt()}',
                              style: AppTypography.headlineMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.electricCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Selector
                  Text(
                    'Select Payment Method',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Method Selection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodTab(
                          index: 0,
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'UPI Direct',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMethodTab(
                          index: 1,
                          icon: Icons.qr_code_scanner,
                          title: 'Scan QR',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMethodTab(
                          index: 2,
                          icon: Icons.credit_card,
                          title: 'Cards',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Method 0: UPI Form
                  if (_selectedMethodIndex == 0) ...[
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
                          Text(
                            'Enter your UPI Virtual Address (VPA)',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.warmIvory,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _upiController,
                            onChanged: _validateUpi,
                            decoration: InputDecoration(
                              hintText: 'e.g. yourname@okaxis',
                              prefixIcon: const Icon(
                                Icons.alternate_email,
                                color: AppColors.electricCyan,
                              ),
                              suffixIcon: _isUpiValid
                                  ? const Icon(Icons.check_circle, color: AppColors.success)
                                  : const Icon(Icons.error_outline, color: AppColors.warning),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Quick UPI Options:',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.slateLight),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildUpiChip('lakshmi@okaxis'),
                              _buildUpiChip('lakshmi@oksbi'),
                              _buildUpiChip('lakshmi@paytm'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _handleUpiPayment(tx),
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
                          const Icon(Icons.lock_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'PAY ₹${tx.totalAmount.toInt()} VIA UPI',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.obsidian,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Method 1: QR Option
                  if (_selectedMethodIndex == 1) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 64,
                            color: AppColors.electricCyan,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Instant Dynamic UPI QR',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warmIvory,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Generate a secure payment QR code to scan with any UPI app on your device.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () => _showQrPaymentModal(tx),
                            icon: const Icon(Icons.qr_code_scanner, color: AppColors.obsidian),
                            label: Text('SHOW PAYMENT QR (₹${tx.totalAmount.toInt()})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricCyan,
                              foregroundColor: AppColors.obsidian,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Method 2: Cards Option
                  if (_selectedMethodIndex == 2) ...[
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
                            children: const [
                              Icon(Icons.credit_card, color: AppColors.electricCyan),
                              SizedBox(width: 8),
                              Text('Visa / Mastercard / RuPay / Amex'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              hintText: '4111 2222 3333 4444',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Expiry',
                                    hintText: 'MM/YY',
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _handleUpiPayment(tx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.electricCyan,
                              foregroundColor: AppColors.obsidian,
                              minimumSize: const Size(double.infinity, 52),
                            ),
                            child: Text(
                              'AUTHORIZE ₹${tx.totalAmount.toInt()} ESCROW',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.obsidian,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Escrow Guarantee Explainer Footer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.deepSpace,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 20,
                          color: AppColors.electricCyan,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How SMYL Escrow Protects You',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.warmIvory,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your money is safely locked in ICICI escrow. It is only released to traveller Arjun Reddy once Rahul Kumar provides the 6-digit delivery OTP in Dubai.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.slateLight,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildMethodTab({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _selectedMethodIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethodIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.electricCyan.withOpacity(0.15)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.electricCyan : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.electricCyan : AppColors.slateLight,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.electricCyan : AppColors.warmIvory,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiChip(String vpa) {
    return ActionChip(
      label: Text(
        vpa,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.electricCyan,
        ),
      ),
      backgroundColor: AppColors.electricCyan.withOpacity(0.1),
      side: BorderSide(color: AppColors.electricCyan.withOpacity(0.3)),
      onPressed: () {
        _upiController.text = vpa;
        _validateUpi(vpa);
      },
    );
  }

  Widget _buildFeeRow(String title, String amount, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warmIvory,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              amount,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warmIvory,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.slateLight,
          ),
        ),
      ],
    );
  }
}
