enum UserRole { sender, traveller, receiver, both, admin }

enum KycStatus {
  pending,
  verified,
  rejected,
  additionalInfoRequired,
  suspended,
}

extension KycStatusExtension on KycStatus {
  String get label {
    switch (this) {
      case KycStatus.pending:
        return 'PENDING REVIEW';
      case KycStatus.verified:
        return 'VERIFIED';
      case KycStatus.rejected:
        return 'REJECTED';
      case KycStatus.additionalInfoRequired:
        return 'ACTION REQUIRED';
      case KycStatus.suspended:
        return 'SUSPENDED';
    }
  }

  String get description {
    switch (this) {
      case KycStatus.pending:
        return 'Your identity documents are undergoing compliance verification. Usually takes 2-4 hours.';
      case KycStatus.verified:
        return 'Full international traveller privileges active. Permitted to carry verified consignments.';
      case KycStatus.rejected:
        return 'Verification was rejected due to blurry document edges or name mismatch. Please resubmit.';
      case KycStatus.additionalInfoRequired:
        return 'Please provide a clear photo of your passport bio-page with readable MRZ code.';
      case KycStatus.suspended:
        return 'Your account is under temporary operational review. Contact support@smyl.global.';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final KycStatus kycStatus;
  final String country;
  final String? passportNumber;
  final String? governmentIdType;
  final String? governmentIdNumber;
  final double rating;
  final int completedDeliveries;
  final int completedShipments;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.kycStatus,
    required this.country,
    this.passportNumber,
    this.governmentIdType,
    this.governmentIdNumber,
    this.rating = 5.0,
    this.completedDeliveries = 0,
    this.completedShipments = 0,
    required this.createdAt,
  });

  // Demo Personas for Connected Transaction SMYL-2026-000184
  static UserModel get demoSender => UserModel(
        id: 'usr_lakshmi_01',
        name: 'Lakshmi Narayana',
        email: 'lakshmi.n@smyl.global',
        phone: '+91 98490 12345',
        role: UserRole.sender,
        kycStatus: KycStatus.verified,
        country: 'India',
        passportNumber: 'Z8942104',
        governmentIdType: 'Aadhaar / National ID',
        governmentIdNumber: 'XXXX-XXXX-8921',
        rating: 4.95,
        completedDeliveries: 0,
        completedShipments: 12,
        createdAt: DateTime(2026, 1, 15),
      );

  static UserModel get demoTraveller => UserModel(
        id: 'trv_arjun_01',
        name: 'Arjun Reddy',
        email: 'arjun.reddy@aircarrier.net',
        phone: '+91 98850 67890',
        role: UserRole.traveller,
        kycStatus: KycStatus.verified,
        country: 'India',
        passportNumber: 'P7482910',
        governmentIdType: 'Passport & Frequent Flyer Tier 1',
        governmentIdNumber: 'EK-SKY-9021',
        rating: 4.8,
        completedDeliveries: 24,
        completedShipments: 0,
        createdAt: DateTime(2025, 8, 10),
      );

  static UserModel get demoReceiver => UserModel(
        id: 'rcv_rahul_01',
        name: 'Rahul Kumar',
        email: 'rahul.kumar@dubai.ae',
        phone: '+971 50 123 4567',
        role: UserRole.receiver,
        kycStatus: KycStatus.verified,
        country: 'United Arab Emirates',
        governmentIdType: 'Emirates ID',
        governmentIdNumber: '784-1988-1234567-1',
        rating: 5.0,
        completedDeliveries: 0,
        completedShipments: 6,
        createdAt: DateTime(2026, 2, 20),
      );

  static UserModel get demoAdmin => UserModel(
        id: 'usr_admin_01',
        name: 'Operations Command Officer',
        email: 'ops.command@smyl.global',
        phone: '+971 4 800 7695',
        role: UserRole.admin,
        kycStatus: KycStatus.verified,
        country: 'United Arab Emirates',
        governmentIdType: 'Internal Staff ID',
        governmentIdNumber: 'SMYL-OPS-001',
        rating: 5.0,
        completedDeliveries: 120,
        completedShipments: 120,
        createdAt: DateTime(2025, 1, 1),
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    KycStatus? kycStatus,
    String? country,
    String? passportNumber,
    String? governmentIdType,
    String? governmentIdNumber,
    double? rating,
    int? completedDeliveries,
    int? completedShipments,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      kycStatus: kycStatus ?? this.kycStatus,
      country: country ?? this.country,
      passportNumber: passportNumber ?? this.passportNumber,
      governmentIdType: governmentIdType ?? this.governmentIdType,
      governmentIdNumber: governmentIdNumber ?? this.governmentIdNumber,
      rating: rating ?? this.rating,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      completedShipments: completedShipments ?? this.completedShipments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
