class AuditLogModel {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String previousStatus;
  final String newStatus;
  final String referenceId;
  final String entityType;
  final String reason;
  final DateTime timestamp;

  const AuditLogModel({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.previousStatus,
    required this.newStatus,
    required this.referenceId,
    required this.entityType,
    required this.reason,
    required this.timestamp,
  });
}
