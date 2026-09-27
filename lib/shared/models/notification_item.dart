enum NotificationCategory {
  transaction,
  verification,
  security,
  payout,
  system,
}

extension NotificationCategoryExtension on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.transaction:
        return 'LOGISTICS';
      case NotificationCategory.verification:
        return 'VERIFICATION';
      case NotificationCategory.security:
        return 'SECURITY & OTP';
      case NotificationCategory.payout:
        return 'FINANCE & PAYOUT';
      case NotificationCategory.system:
        return 'SYSTEM ALERT';
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final String? relatedTransactionId;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.relatedTransactionId,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    String? relatedTransactionId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      relatedTransactionId: relatedTransactionId ?? this.relatedTransactionId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
