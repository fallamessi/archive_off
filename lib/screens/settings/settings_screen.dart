// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _archiveAlerts = true;
  String _selectedLanguage = 'Français';
  String _selectedTheme = 'Clair';
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _selectedSection = 'Profil';

  // Contrôleurs pour l'édition du profil
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = await authProvider.getCurrentUser();

      if (mounted) {
        setState(() {
          _userData = userData;
          // Initialiser les contrôleurs avec les données existantes
          _nomController.text = userData?['nom'] ?? '';
          _prenomController.text = userData?['prenom'] ?? '';
          _telephoneController.text = userData?['telephone'] ?? '';
          _emailController.text = userData?['email'] ?? '';
          _emailNotifications = userData?['email_notifications'] ?? true;
          _archiveAlerts = userData?['archive_alerts'] ?? true;
          _selectedLanguage = userData?['langue'] ?? 'Français';
          _selectedTheme = userData?['theme'] ?? 'Clair';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erreur lors du chargement des données: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: _buildSettingsNavigation(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildSettingsContent(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isEditing)
            Row(
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsNavigation() {
    final List<Map<String, dynamic>> navigationItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Profil',
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Sécurité',
      },
      {
        'icon': Icons.language_outlined,
        'title': 'Langue',
      },
      if (_userData?['type_utilisateur'] == 'Admin')
        {
          'icon': Icons.backup_outlined,
          'title': 'Sauvegarde',
        },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListView(
        shrinkWrap: true,
        children: navigationItems
            .map((item) => _buildNavigationItem(
                  icon: item['icon'],
                  title: item['title'],
                  isSelected: _selectedSection == item['title'],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor:
          isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
      selectedColor: AppTheme.primaryBlue,
      onTap: () {
        setState(() {
          _selectedSection = title;
          _isEditing = false;
        });
      },
    );
  }

  Widget _buildSettingsContent() {
    switch (_selectedSection) {
      case 'Profil':
        return _buildProfileSection();
      case 'Notifications':
        return _buildNotificationsSection();
      case 'Sécurité':
        return _buildSecuritySection();
      case 'Langue':
        return _buildLanguageSection();
      case 'Sauvegarde':
        return _buildBackupSection();
      default:
        return _buildProfileSection();
    }
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _isEditing = true);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileField(
              label: 'Nom',
              controller: _nomController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Prénom',
              controller: _prenomController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Téléphone',
              controller: _telephoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Email',
              controller: _emailController,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
            ),
            if (_userData != null) ...[
              const SizedBox(height: 32),
              Text(
                'Informations spécifiques - ${_userData!['type_utilisateur']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSpecificUserInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Préférences de notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingGroup(
              title: 'Notifications par email',
              children: [
                _buildSettingSwitch(
                  title: 'Notifications par e-mail',
                  subtitle:
                      'Recevoir des notifications par e-mail pour les mises à jour importantes',
                  value: _emailNotifications,
                  onChanged: (value) async {
                    setState(() => _emailNotifications = value);
                    await _updateUserPreference('email_notifications', value);
                  },
                ),
                _buildSettingSwitch(
                  title: 'Alertes d\'archives',
                  subtitle:
                      'Recevoir des notifications pour les archives nécessitant une action',
                  value: _archiveAlerts,
                  onChanged: (value) async {
                    setState(() => _archiveAlerts = value);
                    await _updateUserPreference('archive_alerts', value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sécurité du compte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingGroup(
              title: 'Mot de passe et authentification',
              children: [
                _buildSettingButton(
                  title: 'Changer le mot de passe',
                  subtitle: 'Modifier votre mot de passe actuel',
                  icon: Icons.lock_outline,
                  onPressed: () => _showChangePasswordDialog(context),
                ),
                _buildSettingButton(
                  title: 'Historique des connexions',
                  subtitle: 'Voir l\'historique des connexions à votre compte',
                  icon: Icons.history,
                  onPressed: () => _showLoginHistory(),
                ),
                _buildSettingButton(
                  title: 'Authentification à deux facteurs',
                  subtitle: 'Ajouter une couche de sécurité supplémentaire',
                  icon: Icons.security,
                  onPressed: () => _setup2FA(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Langue et affichage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingGroup(
              title: 'Préférences de langue',
              children: [
                _buildSettingDropdown(
                  title: 'Langue de l\'application',
                  value: _selectedLanguage,
                  items: const ['Français', 'English'],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _selectedLanguage = value);
                      await _updateUserPreference('langue', value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingDropdown(
                  title: 'Thème',
                  value: _selectedTheme,
                  items: const ['Clair', 'Sombre', 'Système'],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _selectedTheme = value);
                      await _updateUserPreference('theme', value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    if (_userData?['type_utilisateur'] != 'Admin') {
      return const Center(
        child: Text('Vous n\'avez pas accès à cette section'),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestion des sauvegardes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingGroup(
              title: 'Sauvegardes manuelles',
              children: [
                _buildSettingButton(
                  title: 'Créer une sauvegarde',
                  subtitle: 'Sauvegarder toutes les données de l\'application',
                  icon: Icons.backup,
                  onPressed: () => _createBackup(),
                ),
                _buildSettingButton(
                  title: 'Restaurer une sauvegarde',
                  subtitle: 'Restaurer les données à partir d\'une sauvegarde',
                  icon: Icons.restore,
                  onPressed: () => _restoreBackup(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingGroup(
              title: 'Sauvegardes automatiques',
              children: [
                _buildSettingSwitch(
                  title: 'Sauvegardes quotidiennes',
                  subtitle: 'Effectuer une sauvegarde automatique chaque jour',
                  value: _userData?['backup_auto'] ?? false,
                  onChanged: (value) async {
                    await _updateUserPreference('backup_auto', value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widgets utilitaires
  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  Widget _buildSpecificUserInfo() {
    final userType = _userData!['type_utilisateur'];
    final Map<String, String> specificInfo = {};

    switch (userType) {
      case 'Etudiant':
        specificInfo['Établissement'] = _userData!['etablissement'] ?? '';
        specificInfo['Niveau d\'études'] = _userData!['niveau_etudes'] ?? '';
        break;
      case 'Agent de l\'État':
        specificInfo['Direction'] = _userData!['direction'] ?? '';
        specificInfo['Poste'] = _userData!['poste'] ?? '';
        specificInfo['Ministère'] = _userData!['ministere'] ?? '';
        break;
      case 'Entreprise/ONG':
        specificInfo['Entreprise'] = _userData!['entreprise'] ?? '';
        specificInfo['Secteur d\'activité'] =
            _userData!['secteur_activite'] ?? '';
        break;
      case 'Chercheur':
        specificInfo['Institution'] = _userData!['institution'] ?? '';
        specificInfo['Domaine de recherche'] =
            _userData!['domaine_recherche'] ?? '';
        break;
      case 'Particulier':
        specificInfo['Profession'] = _userData!['profession'] ?? '';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specificInfo.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(entry.value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingDropdown({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Gestionnaires d'événements et méthodes utilitaires
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Restaurer les valeurs originales
      _nomController.text = _userData?['nom'] ?? '';
      _prenomController.text = _userData?['prenom'] ?? '';
      _telephoneController.text = _userData?['telephone'] ?? '';
    });
  }

  Future<void> _saveChanges() async {
    try {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        userId: _userData!['auth_user_id'],
        userData: {
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'telephone': _telephoneController.text,
        },
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        _loadUserData(); // Recharger les données
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserPreference(String key, dynamic value) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        userId: _userData!['auth_user_id'],
        userData: {key: value},
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préférence mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Implémentation du changement de mot de passe
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory() {
    // Implémenter l'affichage de l'historique des connexions
  }

  void _setup2FA() {
    // Implémenter la configuration de l'authentification à deux facteurs
  }

  void _createBackup() {
    // Implémenter la création de sauvegarde
  }

  void _restoreBackup() {
    // Implémenter la restauration de sauvegarde
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
