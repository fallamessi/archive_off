// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../documents/document_list_screen.dart';
import '../archives/archive_list_screen.dart';
import '../users/users_screen.dart';
import '../settings/settings_screen.dart';
import '../documents/document_scan_screen.dart';
import '../search/advanced_search_screen.dart';
import '../subscription/subscription_management_screen.dart';
import '../subscription/subscription_plans_screen.dart';
import '../chat/chat_assistant_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = await authProvider.getCurrentUser();
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    }
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barre latérale
          Container(
            width: 280,
            color: AppTheme.primaryBlue,
            child: Column(
              children: [
                // En-tête avec logo
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Direction des Archives Nationales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Menu de navigation dans un Expanded avec ListView
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(
                        icon: Icons.dashboard_rounded,
                        title: 'Tableau de bord',
                        index: 0,
                      ),
                      _buildMenuItem(
                        icon: Icons.folder_rounded,
                        title: 'Documents',
                        index: 1,
                      ),
                      _buildMenuItem(
                        icon: Icons.archive_rounded,
                        title: 'Archives',
                        index: 2,
                      ),
                      _buildMenuItem(
                        icon: Icons.document_scanner,
                        title: 'Scanner un document',
                        index: 5,
                      ),
                      _buildMenuItem(
                        icon: Icons.search,
                        title: 'Recherche avancée',
                        index: 6,
                      ),
                      _buildMenuItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Assistant IA',
                        index: 9,
                      ),
                      _buildMenuItem(
                        icon: Icons.subscriptions,
                        title: 'Les abonnées',
                        index: 7,
                      ),
                      _buildMenuItem(
                        icon: Icons.money,
                        title: 'Les frais',
                        index: 8,
                      ),
                      _buildMenuItem(
                        icon: Icons.people_rounded,
                        title: 'Utilisateurs',
                        index: 3,
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        title: 'Paramètres',
                        index: 4,
                      ),
                    ],
                  ),
                ),

                // Profil utilisateur en bas
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_userData?['nom'] ?? ''} ${_userData?['prenom'] ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _userData?['type_utilisateur'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white70,
                              ),
                              onPressed: _handleLogout,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: _getScreenForIndex(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const DocumentListScreen();
      case 2:
        return const ArchiveListScreen();
      case 3:
        return const UsersScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return const DocumentScanScreen();
      case 6:
        return const AdvancedSearchScreen();
      case 7:
        return const SubscriptionManagementScreen();
      case 8:
        return const SubscriptionPlansScreen();
      case 9:
        return const ChatAssistantScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        selected: isSelected,
        onTap: () => _navigateToScreen(index),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Barre supérieure
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Contenu du tableau de bord
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tableau de bord',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Cartes statistiques
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Documents',
                      value: '0',
                      icon: Icons.file_copy_rounded,
                      color: AppTheme.primaryBlue,
                      onTap: () => _navigateToScreen(1),
                    ),
                    const SizedBox(width: 24),
                    _buildStatCard(
                      title: 'Archives',
                      value: '10',
                      icon: Icons.archive_rounded,
                      color: AppTheme.accentGreen,
                      onTap: () => _navigateToScreen(2),
                    ),
                    const SizedBox(width: 24),
                    _buildStatCard(
                      title: 'Utilisateurs',
                      value: '1',
                      icon: Icons.people_rounded,
                      color: AppTheme.accentYellow,
                      onTap: () => _navigateToScreen(3),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Archives
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildArchivesOverview(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildArchiveStats(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Documents récents et activités
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRecentDocuments(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildRecentActivities(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArchivesOverview() {
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aperçu des Archives',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(2),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildArchiveMetric(
                    icon: Icons.inbox,
                    title: 'À éliminer',
                    value: '0',
                    color: AppTheme.accentRed,
                  ),
                ),
                Expanded(
                  child: _buildArchiveMetric(
                    icon: Icons.upload_file,
                    title: 'Validés',
                    value: '0',
                    color: AppTheme.accentGreen,
                  ),
                ),
                Expanded(
                  child: _buildArchiveMetric(
                    icon: Icons.storage,
                    title: 'En conservation',
                    value: '0',
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveStats() {
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'État des Emplacements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildLocationProgress('Local A', 0.75),
            const SizedBox(height: 16),
            _buildLocationProgress('Local B', 0.45),
            const SizedBox(height: 16),
            _buildLocationProgress('Local C', 0.90),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveMetric({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationProgress(String location, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(location),
            Text('${(progress * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.8 ? AppTheme.accentRed : AppTheme.primaryBlue,
          ),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildRecentDocuments() {
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Documents récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(1),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.file_copy_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: Text('Document ${index + 1}'),
                  subtitle: Text('Modifié il y a ${index + 1} heures'),
                  onTap: () => _navigateToScreen(1),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activités récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                final bool isArchiveActivity = index.isEven;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isArchiveActivity
                              ? AppTheme.accentGreen
                              : AppTheme.primaryBlue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isArchiveActivity ? Icons.archive : Icons.description,
                      color: isArchiveActivity
                          ? AppTheme.accentGreen
                          : AppTheme.primaryBlue,
                    ),
                  ),
                  title: Text(
                    isArchiveActivity
                        ? 'Archive déplacée vers Local A'
                        : 'Document ajouté',
                  ),
                  subtitle: Text('Il y a ${index + 1} heures'),
                  trailing: Text(
                    isArchiveActivity
                        ? 'REF-2024-00${index + 1}'
                        : 'DOC-00${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
