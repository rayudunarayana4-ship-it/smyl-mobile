import 'transaction_status.dart';

class TrackingEventModel {
  final String id;
  final String transactionId;
  final TransactionStatus status;
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final String actor;
  final String eventType;
  final TransactionStatus? previousStatus;
  final TransactionStatus? newStatus;
  final bool isCompleted;

  const TrackingEventModel({
    required this.id,
    required this.transactionId,
    required this.status,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    this.actor = 'System',
    this.eventType = 'STATUS_CHANGE',
    this.previousStatus,
    this.newStatus,
    this.isCompleted = true,
  });
}
