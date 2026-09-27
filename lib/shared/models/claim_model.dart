enum ClaimIssueType {
  lostItem,
  damagedItem,
  nonReceipt,
  travellerCancellation,
  courierIssue,
  other,
}

extension ClaimIssueTypeExtension on ClaimIssueType {
  String get label {
    switch (this) {
      case ClaimIssueType.lostItem:
        return 'Lost Item / Luggage Misplacement';
      case ClaimIssueType.damagedItem:
        return 'Damaged or Broken Item';
      case ClaimIssueType.nonReceipt:
        return 'Non-Receipt / Failed Handover';
      case ClaimIssueType.travellerCancellation:
        return 'Last Minute Traveller Cancellation';
      case ClaimIssueType.courierIssue:
        return 'Courier Handoff Delay / Damage';
      case ClaimIssueType.other:
        return 'Other Exceptional Dispute';
    }
  }
}

enum ClaimStatus {
  claimOpen,
  underReview,
  actionRequired,
  resolved,
  disputed,
}

extension ClaimStatusExtension on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.claimOpen:
        return 'CLAIM OPEN';
      case ClaimStatus.underReview:
        return 'UNDER REVIEW';
      case ClaimStatus.actionRequired:
        return 'ACTION REQUIRED';
      case ClaimStatus.resolved:
        return 'RESOLVED';
      case ClaimStatus.disputed:
        return 'DISPUTED';
    }
  }
}

class ClaimModel {
  final String id;
  final String transactionId;
  final String userId;
  final String userName;
  final ClaimIssueType issueType;
  final String description;
  final double declaredItemValue;
  final List<String> evidenceFiles;
  final ClaimStatus status;
  final String? resolutionSummary;
  final DateTime createdAt;

  const ClaimModel({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.userName,
    required this.issueType,
    required this.description,
    required this.declaredItemValue,
    this.evidenceFiles = const [],
    this.status = ClaimStatus.claimOpen,
    this.resolutionSummary,
    required this.createdAt,
  });

  ClaimModel copyWith({
    String? id,
    String? transactionId,
    String? userId,
    String? userName,
    ClaimIssueType? issueType,
    String? description,
    double? declaredItemValue,
    List<String>? evidenceFiles,
    ClaimStatus? status,
    String? resolutionSummary,
    DateTime? createdAt,
  }) {
    return ClaimModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      declaredItemValue: declaredItemValue ?? this.declaredItemValue,
      evidenceFiles: evidenceFiles ?? this.evidenceFiles,
      status: status ?? this.status,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
