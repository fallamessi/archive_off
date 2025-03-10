// lib/models/client_subscription.dart
class ClientSubscription {
  final String id;
  final String clientId;
  final String planId;
  final DateTime startDate;
  final DateTime expiryDate;
  final String status; // 'active', 'expired', 'cancelled'
  final double storageUsed;
  final int documentsStored;

  ClientSubscription({
    required this.id,
    required this.clientId,
    required this.planId,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.storageUsed,
    required this.documentsStored,
  });
}
