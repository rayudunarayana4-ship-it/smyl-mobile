class AppConstants {
  static const String appName = 'SMYL GLOBAL';
  static const String appTagline = 'Your Journey Can Carry More.';
  static const String appVersion = '1.0.0 (Build 240)';

  // Fee Structure (Configurable)
  static const double platformFeePercentage = 0.15; // 15%
  static const double baseCourierPartnerFee = 350.0; // INR flat estimate
  static const double standardInsuranceRate = 0.02; // 2% of declared value

  // Prohibited Categories for Compliance Check
  static const List<String> prohibitedCategories = [
    'Lithium-ion Batteries & Power banks (>100Wh)',
    'Flammable liquids, perfumes & aerosols',
    'Live plants, seeds & agricultural produce',
    'Prescription narcotics without doctor certificate',
    'Perishable meat & fresh dairy products',
    'Cultural antiques & national heritage artifacts',
    'Weapons, explosives & replica tactical equipment',
    'Cryptocurrency mining gear & uncertified transmitters',
  ];

  // Permitted Item Categories
  static const List<String> permittedCategories = [
    'Personal Documents & Certificates',
    'Branded Apparel & Fashion Accessories',
    'Packaged Dry Foods & Traditional Sweets',
    'Consumer Electronics (Laptops, Phones)',
    'Cosmetics & Sealed Toiletries',
    'Books, Literature & Art Prints',
    'Gifts & Luxury Souvenirs',
    'Medical Supplies & Authorized OTC Care',
  ];

  // Supported Currencies
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';
}
