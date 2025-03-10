// Provider pour la gestion des états liés aux abonnements
import 'package:flutter/material.dart';
//import '../models/subscription_plan.dart';
import '../models/client_subscription.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();
  ClientSubscription? _currentSubscription;
  List<ClientSubscription> _allSubscriptions = [];
  bool _isLoading = false;

  ClientSubscription? get currentSubscription => _currentSubscription;
  List<ClientSubscription> get allSubscriptions => _allSubscriptions;
  bool get isLoading => _isLoading;

  // Charger tous les abonnements (pour l'admin)
  Future<void> loadAllSubscriptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implémenter le chargement
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Créer un nouvel abonnement
  Future<void> createSubscription({
    required String clientId,
    required String planId,
    required int durationMonths,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final subscription = await _service.createSubscription(
        clientId: clientId,
        planId: planId,
        durationMonths: durationMonths,
      );
      _currentSubscription = subscription;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Annuler un abonnement
  Future<void> cancelSubscription(String subscriptionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancelSubscription(subscriptionId);
      // Mettre à jour la liste locale
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Filtrer les abonnements
  void filterSubscriptions({
    String? status,
    String? plan,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Implémenter le filtrage
    notifyListeners();
  }
}
