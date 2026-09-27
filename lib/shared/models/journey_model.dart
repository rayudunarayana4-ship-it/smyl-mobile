enum JourneyStatus { active, inTransit, completed, cancelled }

class JourneyModel {
  final String id;
  final String travellerId;
  final String travellerName;
  final double travellerRating;
  final bool travellerKycVerified;

  final String originCity;
  final String originCountry;
  final String originAirportCode;

  final String destCity;
  final String destCountry;
  final String destAirportCode;

  final DateTime departureDate;
  final String departureTime;
  final DateTime arrivalDate;
  final String arrivalTime;

  final String airline;
  final String flightNumber;
  final double totalCapacityKg;
  final double availableCapacityKg;
  final bool isInternational;
  final String handoverPreference;
  final JourneyStatus status;
  final double estimatedEarnings;
  final List<String> acceptedShipmentIds;

  const JourneyModel({
    required this.id,
    required this.travellerId,
    required this.travellerName,
    this.travellerRating = 4.9,
    this.travellerKycVerified = true,
    required this.originCity,
    required this.originCountry,
    required this.originAirportCode,
    required this.destCity,
    required this.destCountry,
    required this.destAirportCode,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.airline,
    required this.flightNumber,
    required this.totalCapacityKg,
    required this.availableCapacityKg,
    this.isInternational = true,
    this.handoverPreference = 'Airport Departure Terminal',
    this.status = JourneyStatus.active,
    this.estimatedEarnings = 0.0,
    this.acceptedShipmentIds = const [],
  });

  JourneyModel copyWith({
    String? id,
    String? travellerId,
    String? travellerName,
    double? travellerRating,
    bool? travellerKycVerified,
    String? originCity,
    String? originCountry,
    String? originAirportCode,
    String? destCity,
    String? destCountry,
    String? destAirportCode,
    DateTime? departureDate,
    String? departureTime,
    DateTime? arrivalDate,
    String? arrivalTime,
    String? airline,
    String? flightNumber,
    double? totalCapacityKg,
    double? availableCapacityKg,
    bool? isInternational,
    String? handoverPreference,
    JourneyStatus? status,
    double? estimatedEarnings,
    List<String>? acceptedShipmentIds,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      travellerId: travellerId ?? this.travellerId,
      travellerName: travellerName ?? this.travellerName,
      travellerRating: travellerRating ?? this.travellerRating,
      travellerKycVerified: travellerKycVerified ?? this.travellerKycVerified,
      originCity: originCity ?? this.originCity,
      originCountry: originCountry ?? this.originCountry,
      originAirportCode: originAirportCode ?? this.originAirportCode,
      destCity: destCity ?? this.destCity,
      destCountry: destCountry ?? this.destCountry,
      destAirportCode: destAirportCode ?? this.destAirportCode,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      airline: airline ?? this.airline,
      flightNumber: flightNumber ?? this.flightNumber,
      totalCapacityKg: totalCapacityKg ?? this.totalCapacityKg,
      availableCapacityKg: availableCapacityKg ?? this.availableCapacityKg,
      isInternational: isInternational ?? this.isInternational,
      handoverPreference: handoverPreference ?? this.handoverPreference,
      status: status ?? this.status,
      estimatedEarnings: estimatedEarnings ?? this.estimatedEarnings,
      acceptedShipmentIds: acceptedShipmentIds ?? this.acceptedShipmentIds,
    );
  }
}
