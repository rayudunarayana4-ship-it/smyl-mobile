import 'transaction_status.dart';

enum JourneyType { domestic, international }

class ShipmentModel {
  final String id;
  final String senderId;
  final String senderName;
  
  // Pickup
  final String pickupCity;
  final String pickupCountry;
  final String pickupAddress;
  
  // Destination
  final String destCity;
  final String destCountry;
  final String destAddress;
  
  // Receiver
  final String receiverName;
  final String receiverPhone;
  final String? receiverInstructions;
  
  // Item
  final String itemCategory;
  final String itemDescription;
  final double weightKg;
  final int quantity;
  final bool isFragile;
  final double declaredValue;
  final String currency;
  final JourneyType journeyType;
  final String? specialInstructions;
  final bool declarationAccepted;
  
  // Economics
  final double estimatedCost;
  final double travellerPayout;
  final double platformFee;
  final double courierFee;
  
  // Association & Status
  final String? matchedTravellerId;
  final String? matchedTravellerName;
  final TransactionStatus status;
  final String originOtp;
  final String deliveryOtp;
  final DateTime createdAt;

  const ShipmentModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.pickupCity,
    required this.pickupCountry,
    required this.pickupAddress,
    required this.destCity,
    required this.destCountry,
    required this.destAddress,
    required this.receiverName,
    required this.receiverPhone,
    this.receiverInstructions,
    required this.itemCategory,
    required this.itemDescription,
    required this.weightKg,
    this.quantity = 1,
    this.isFragile = false,
    required this.declaredValue,
    this.currency = 'INR',
    required this.journeyType,
    this.specialInstructions,
    this.declarationAccepted = true,
    required this.estimatedCost,
    required this.travellerPayout,
    required this.platformFee,
    this.courierFee = 0.0,
    this.matchedTravellerId,
    this.matchedTravellerName,
    this.status = TransactionStatus.created,
    required this.originOtp,
    required this.deliveryOtp,
    required this.createdAt,
  });

  ShipmentModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? pickupCity,
    String? pickupCountry,
    String? pickupAddress,
    String? destCity,
    String? destCountry,
    String? destAddress,
    String? receiverName,
    String? receiverPhone,
    String? receiverInstructions,
    String? itemCategory,
    String? itemDescription,
    double? weightKg,
    int? quantity,
    bool? isFragile,
    double? declaredValue,
    String? currency,
    JourneyType? journeyType,
    String? specialInstructions,
    bool? declarationAccepted,
    double? estimatedCost,
    double? travellerPayout,
    double? platformFee,
    double? courierFee,
    String? matchedTravellerId,
    String? matchedTravellerName,
    TransactionStatus? status,
    String? originOtp,
    String? deliveryOtp,
    DateTime? createdAt,
  }) {
    return ShipmentModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      pickupCity: pickupCity ?? this.pickupCity,
      pickupCountry: pickupCountry ?? this.pickupCountry,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destCity: destCity ?? this.destCity,
      destCountry: destCountry ?? this.destCountry,
      destAddress: destAddress ?? this.destAddress,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverInstructions: receiverInstructions ?? this.receiverInstructions,
      itemCategory: itemCategory ?? this.itemCategory,
      itemDescription: itemDescription ?? this.itemDescription,
      weightKg: weightKg ?? this.weightKg,
      quantity: quantity ?? this.quantity,
      isFragile: isFragile ?? this.isFragile,
      declaredValue: declaredValue ?? this.declaredValue,
      currency: currency ?? this.currency,
      journeyType: journeyType ?? this.journeyType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      declarationAccepted: declarationAccepted ?? this.declarationAccepted,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      travellerPayout: travellerPayout ?? this.travellerPayout,
      platformFee: platformFee ?? this.platformFee,
      courierFee: courierFee ?? this.courierFee,
      matchedTravellerId: matchedTravellerId ?? this.matchedTravellerId,
      matchedTravellerName: matchedTravellerName ?? this.matchedTravellerName,
      status: status ?? this.status,
      originOtp: originOtp ?? this.originOtp,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
