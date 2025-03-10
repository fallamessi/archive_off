// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Vérifier si un utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    _isAuthenticated = session != null;
    notifyListeners();
    return _isAuthenticated;
  }

  // Création de compte
  Future<bool> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    DateTime? dateNaissance,
    required String nationalite,
    required String typeUtilisateur,
    String? etablissement,
    String? niveauEtudes,
    String? institution,
    String? direction,
    String? poste,
    String? ministere,
    String? entreprise,
    String? secteurActivite,
    String? profession,
    bool acceptTerms = false,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Créer le compte d'authentification
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Échec de la création du compte");
      }

      // 2. Insérer les données utilisateur dans la table personnalisée
      await _supabase.from('utilisateurs').insert({
        'auth_user_id': authResponse.user!.id,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'date_naissance': dateNaissance?.toIso8601String(),
        'nationalite': nationalite,
        'type_utilisateur': typeUtilisateur,
        'etablissement': etablissement,
        'niveau_etudes': niveauEtudes,
        'institution': institution,
        'direction': direction,
        'poste': poste,
        'ministere': ministere,
        'entreprise': entreprise,
        'secteur_activite': secteurActivite,
        'profession': profession,
        'accept_terms': acceptTerms,
        'isActive': false, // L'administrateur devra activer le compte
      });

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors de l\'inscription: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Vérifier si le compte est actif
        final userData = await _supabase
            .from('utilisateurs')
            .select()
            .eq('auth_user_id', response.user?.id)
            .single();

        if (userData['isActive'] == false) {
          await _supabase.auth.signOut();
          throw Exception(
              'Votre compte n\'est pas encore activé par l\'administrateur');
        }

        _isAuthenticated = true;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors de la connexion: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.signOut();
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors de la déconnexion: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les informations de l'utilisateur connecté
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('utilisateurs')
          .select()
          .eq('auth_user_id', userId)
          .single();

      return response;
    } catch (e) {
      _error = e.toString();
      debugPrint(
          'Erreur lors de la récupération des données utilisateur: $_error');
      return null;
    }
  }

  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors de la réinitialisation du mot de passe: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mise à jour du profil
  Future<bool> updateProfile({
    required String userId,
    Map<String, dynamic> userData = const {},
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase
          .from('utilisateurs')
          .update(userData)
          .eq('auth_user_id', userId);

      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors de la mise à jour du profil: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
