enum RestrictionLevel {
  strictlyProhibited,
  permitRequired,
  declarationRequired,
}

extension RestrictionLevelExtension on RestrictionLevel {
  String get label {
    switch (this) {
      case RestrictionLevel.strictlyProhibited:
        return 'STRICTLY PROHIBITED';
      case RestrictionLevel.permitRequired:
        return 'PERMIT REQUIRED';
      case RestrictionLevel.declarationRequired:
        return 'CUSTOMS DECLARATION REQUIRED';
    }
  }
}

class ProhibitedRuleModel {
  final String id;
  final String category;
  final String itemName;
  final String originCountry;
  final String destinationCountry;
  final RestrictionLevel restrictionLevel;
  final String rationale;
  final String penaltyNotice;
  final bool isActive;

  const ProhibitedRuleModel({
    required this.id,
    required this.category,
    required this.itemName,
    this.originCountry = 'GLOBAL',
    this.destinationCountry = 'GLOBAL',
    required this.restrictionLevel,
    required this.rationale,
    required this.penaltyNotice,
    this.isActive = true,
  });
}
