// lib/models/subscription_plan.dart
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int storageLimit; // en GB
  final int documentLimit;
  final List<String> features;
  final String billingPeriod; // 'monthly' ou 'yearly'

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.storageLimit,
    required this.documentLimit,
    required this.features,
    required this.billingPeriod,
  });
}
