import 'transaction_status.dart';

enum PaymentStatus {
  pending,
  authorizedEscrow,
  releasedToTraveller,
  partiallyRefunded,
  refunded,
  failed,
  onHold,
  disputed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'PAYMENT PENDING';
      case PaymentStatus.authorizedEscrow:
        return 'IN ESCROW (AUTHORIZED)';
      case PaymentStatus.releasedToTraveller:
        return 'PAYOUT RELEASED';
      case PaymentStatus.partiallyRefunded:
        return 'PARTIALLY REFUNDED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
      case PaymentStatus.failed:
        return 'PAYMENT FAILED';
      case PaymentStatus.onHold:
        return 'ESCROW ON HOLD';
      case PaymentStatus.disputed:
        return 'PAYMENT DISPUTED';
    }
  }
}

class TransactionModel {
  final String id;
  final String shipmentId;
  final String? journeyId;

  final String senderId;
  final String senderName;
  final String? travellerId;
  final String? travellerName;
  final String receiverName;
  final String receiverPhone;

  final String originCity;
  final String originCountry;
  final String originAirportCode;

  final String destCity;
  final String destCountry;
  final String destAirportCode;

  final String itemCategory;
  final String itemDescription;
  final double weightKg;

  final TransactionStatus status;
  final PaymentStatus paymentStatus;

  final double totalAmount;
  final double travellerPayout;
  final double platformFee;
  final double courierFee;

  final String originHandoverOtp;
  final String destinationHandoverOtp;

  final String? courierPartnerId;
  final String? courierPartnerName;
  final String? courierTrackingId;

  final String? paymentReference;
  final DateTime? handoverTime;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final DateTime? deliveryTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.shipmentId,
    this.journeyId,
    required this.senderId,
    required this.senderName,
    this.travellerId,
    this.travellerName,
    required this.receiverName,
    required this.receiverPhone,
    required this.originCity,
    required this.originCountry,
    required this.originAirportCode,
    required this.destCity,
    required this.destCountry,
    required this.destAirportCode,
    required this.itemCategory,
    required this.itemDescription,
    required this.weightKg,
    required this.status,
    this.paymentStatus = PaymentStatus.authorizedEscrow,
    required this.totalAmount,
    required this.travellerPayout,
    required this.platformFee,
    this.courierFee = 0.0,
    required this.originHandoverOtp,
    required this.destinationHandoverOtp,
    this.courierPartnerId,
    this.courierPartnerName,
    this.courierTrackingId,
    this.paymentReference,
    this.handoverTime,
    this.departureTime,
    this.arrivalTime,
    this.deliveryTime,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionModel copyWith({
    String? id,
    String? shipmentId,
    String? journeyId,
    String? senderId,
    String? senderName,
    String? travellerId,
    String? travellerName,
    String? receiverName,
    String? receiverPhone,
    String? originCity,
    String? originCountry,
    String? originAirportCode,
    String? destCity,
    String? destCountry,
    String? destAirportCode,
    String? itemCategory,
    String? itemDescription,
    double? weightKg,
    TransactionStatus? status,
    PaymentStatus? paymentStatus,
    double? totalAmount,
    double? travellerPayout,
    double? platformFee,
    double? courierFee,
    String? originHandoverOtp,
    String? destinationHandoverOtp,
    String? courierPartnerId,
    String? courierPartnerName,
    String? courierTrackingId,
    String? paymentReference,
    DateTime? handoverTime,
    DateTime? departureTime,
    DateTime? arrivalTime,
    DateTime? deliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      journeyId: journeyId ?? this.journeyId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      travellerId: travellerId ?? this.travellerId,
      travellerName: travellerName ?? this.travellerName,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      originCity: originCity ?? this.originCity,
      originCountry: originCountry ?? this.originCountry,
      originAirportCode: originAirportCode ?? this.originAirportCode,
      destCity: destCity ?? this.destCity,
      destCountry: destCountry ?? this.destCountry,
      destAirportCode: destAirportCode ?? this.destAirportCode,
      itemCategory: itemCategory ?? this.itemCategory,
      itemDescription: itemDescription ?? this.itemDescription,
      weightKg: weightKg ?? this.weightKg,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      travellerPayout: travellerPayout ?? this.travellerPayout,
      platformFee: platformFee ?? this.platformFee,
      courierFee: courierFee ?? this.courierFee,
      originHandoverOtp: originHandoverOtp ?? this.originHandoverOtp,
      destinationHandoverOtp: destinationHandoverOtp ?? this.destinationHandoverOtp,
      courierPartnerId: courierPartnerId ?? this.courierPartnerId,
      courierPartnerName: courierPartnerName ?? this.courierPartnerName,
      courierTrackingId: courierTrackingId ?? this.courierTrackingId,
      paymentReference: paymentReference ?? this.paymentReference,
      handoverTime: handoverTime ?? this.handoverTime,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
