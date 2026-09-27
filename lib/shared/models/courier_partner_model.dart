class CourierPartnerModel {
  final String id;
  final String name;
  final String code;
  final String logoCode;
  final String serviceTier;
  final String contactSupport;
  final bool isActive;
  final double averageTransitHours;

  const CourierPartnerModel({
    required this.id,
    required this.name,
    required this.code,
    required this.logoCode,
    required this.serviceTier,
    required this.contactSupport,
    this.isActive = true,
    this.averageTransitHours = 12.0,
  });
}
