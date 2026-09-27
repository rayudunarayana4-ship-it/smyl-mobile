import 'dart:async';

enum PaymentMethodType {
  upi,
  qrCode,
  creditCard,
  netBanking,
}

enum PaymentGatewayStage {
  idle,
  validating,
  initiating,
  authorizingEscrow,
  success,
  failed,
}

class PaymentReceipt {
  final String receiptId;
  final String transactionId;
  final String paymentReference;
  final double deliveryCharge;
  final double platformFee;
  final double courierFee;
  final double totalAmount;
  final String paymentMethod;
  final String paidBy;
  final String paidToEscrowAccount;
  final DateTime paidAt;
  final String escrowStatusNote;

  const PaymentReceipt({
    required this.receiptId,
    required this.transactionId,
    required this.paymentReference,
    required this.deliveryCharge,
    required this.platformFee,
    required this.courierFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paidBy,
    required this.paidToEscrowAccount,
    required this.paidAt,
    this.escrowStatusNote = 'Funds held in SMYL Secure Escrow until OTP delivery confirmation.',
  });
}

abstract class PaymentService {
  bool validateUpiId(String upiId);
  Future<PaymentReceipt> processUpiPayment({
    required String transactionId,
    required String upiId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
    void Function(PaymentGatewayStage stage, String message)? onProgress,
  });

  Future<PaymentReceipt> confirmQrPayment({
    required String transactionId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
  });

  PaymentReceipt generateReceiptForTransaction({
    required String transactionId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
    String? paymentRef,
    String? paymentMethod,
  });
}

class MockPaymentService implements PaymentService {
  static const String defaultPaymentRef = 'SMYL-PAY-2026-008721';
  static const String escrowAccountId = 'SMYL-ESCROW-ICICI-9941';

  final RegExp _upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');

  @override
  bool validateUpiId(String upiId) {
    final trimmed = upiId.trim();
    if (trimmed.isEmpty) return false;
    return _upiRegex.hasMatch(trimmed);
  }

  @override
  Future<PaymentReceipt> processUpiPayment({
    required String transactionId,
    required String upiId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
    void Function(PaymentGatewayStage stage, String message)? onProgress,
  }) async {
    onProgress?.call(PaymentGatewayStage.validating, 'Validating UPI VPA: $upiId...');
    await Future.delayed(const Duration(milliseconds: 600));

    onProgress?.call(PaymentGatewayStage.initiating, 'Sending collect request to bank...');
    await Future.delayed(const Duration(milliseconds: 800));

    onProgress?.call(
        PaymentGatewayStage.authorizingEscrow, 'Locking funds into SMYL Secure Escrow...');
    await Future.delayed(const Duration(milliseconds: 700));

    onProgress?.call(PaymentGatewayStage.success, 'Payment Confirmed! Reference: $defaultPaymentRef');

    return PaymentReceipt(
      receiptId: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      transactionId: transactionId,
      paymentReference: defaultPaymentRef,
      deliveryCharge: deliveryCharge,
      platformFee: platformFee,
      courierFee: courierFee,
      totalAmount: totalAmount,
      paymentMethod: 'UPI ($upiId)',
      paidBy: senderName,
      paidToEscrowAccount: escrowAccountId,
      paidAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentReceipt> confirmQrPayment({
    required String transactionId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PaymentReceipt(
      receiptId: 'RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      transactionId: transactionId,
      paymentReference: defaultPaymentRef,
      deliveryCharge: deliveryCharge,
      platformFee: platformFee,
      courierFee: courierFee,
      totalAmount: totalAmount,
      paymentMethod: 'UPI Dynamic QR (Verified)',
      paidBy: senderName,
      paidToEscrowAccount: escrowAccountId,
      paidAt: DateTime.now(),
    );
  }

  @override
  PaymentReceipt generateReceiptForTransaction({
    required String transactionId,
    required double totalAmount,
    required double deliveryCharge,
    required double platformFee,
    required double courierFee,
    required String senderName,
    String? paymentRef,
    String? paymentMethod,
  }) {
    return PaymentReceipt(
      receiptId: 'RCP-2026-98104',
      transactionId: transactionId,
      paymentReference: paymentRef ?? defaultPaymentRef,
      deliveryCharge: deliveryCharge,
      platformFee: platformFee,
      courierFee: courierFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod ?? 'UPI (Verified Escrow)',
      paidBy: senderName,
      paidToEscrowAccount: escrowAccountId,
      paidAt: DateTime.now(),
    );
  }
}
