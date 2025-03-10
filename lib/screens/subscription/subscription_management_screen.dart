// lib/screens/subscription/subscription_management_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
//import '../../models/subscription_plan.dart';
import '../../models/client_subscription.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  String _selectedPeriod = 'Tout';
  String _selectedLocation = 'Tous les emplacements';
  List<String> _selectedReasons = [];
  bool _isTableView = false;

  // Données simulées
  final List<ClientSubscription> _subscriptions = [
    ClientSubscription(
      id: '1',
      clientId: 'client1',
      planId: 'pro',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      expiryDate: DateTime.now().add(const Duration(days: 335)),
      status: 'active',
      storageUsed: 25.5,
      documentsStored: 150,
    ),
    // Ajouter plus d'abonnements pour les tests
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panneau de filtres
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatsSection(),
                      Expanded(
                        child: _buildFiltersPanel(),
                      ),
                    ],
                  ),
                ),
                // Liste des abonnements
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        _buildListHeader(),
                        Expanded(
                          child: _isTableView
                              ? _buildSubscriptionsTable()
                              : _buildSubscriptionsList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewSubscriptionDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
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
            'Gestion des abonnements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _exportData(),
            icon: const Icon(Icons.download),
            label: const Text('Exporter'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showNewSubscriptionDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouvel abonnement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Abonnements actifs',
            value: '1',
            trend: '+12%',
            isPositive: true,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Chiffre d\'affaires mensuel',
            value: '50.000 GNF',
            trend: '+8%',
            isPositive: true,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Taux de résiliation',
            value: '0%',
            trend: '-0.0%',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.accentGreen.withOpacity(0.1)
                      : AppTheme.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color:
                        isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Filtre par statut
          _buildFilterSection(
            title: 'Statut',
            children: [
              _buildFilterOption('Tous les statuts', true),
              _buildFilterOption('Actif', false),
              _buildFilterOption('En attente', false),
              _buildFilterOption('Expiré', false),
            ],
          ),
          const SizedBox(height: 24),
          // Filtre par plan
          _buildFilterSection(
            title: 'Plan',
            children: [
              _buildFilterOption('Tous les plans', true),
              _buildFilterOption('Basique', false),
              _buildFilterOption('Professionnel', false),
              _buildFilterOption('Entreprise', false),
            ],
          ),
          const SizedBox(height: 24),
          // Filtre par période
          _buildFilterSection(
            title: 'Période',
            children: [
              _buildFilterOption('Tout', true),
              _buildFilterOption('Ce mois', false),
              _buildFilterOption('Ce trimestre', false),
              _buildFilterOption('Cette année', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '${_subscriptions.length} abonnements',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_isTableView ? Icons.grid_view : Icons.table_rows),
            onPressed: () {
              setState(() {
                _isTableView = !_isTableView;
              });
            },
            tooltip: _isTableView ? 'Vue grille' : 'Vue tableau',
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        return _buildSubscriptionCard(subscription);
      },
    );
  }

  Widget _buildSubscriptionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Client ID')),
          DataColumn(label: Text('Plan')),
          DataColumn(label: Text('Statut')),
          DataColumn(label: Text('Date début')),
          DataColumn(label: Text('Date fin')),
          DataColumn(label: Text('Stockage utilisé')),
          DataColumn(label: Text('Documents')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _subscriptions.map((subscription) {
          return DataRow(
            cells: [
              DataCell(Text(subscription.clientId)),
              DataCell(Text(subscription.planId)),
              DataCell(_buildStatusBadge(subscription.status)),
              DataCell(Text(_formatDate(subscription.startDate))),
              DataCell(Text(_formatDate(subscription.expiryDate))),
              DataCell(Text('${subscription.storageUsed} GB')),
              DataCell(Text(subscription.documentsStored.toString())),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editSubscription(subscription),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteSubscription(subscription),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionCard(ClientSubscription subscription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client ID: ${subscription.clientId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan: ${subscription.planId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildStatusBadge(subscription.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                    'Date début', _formatDate(subscription.startDate)),
                const SizedBox(width: 24),
                _buildInfoItem(
                    'Date fin', _formatDate(subscription.expiryDate)),
                const SizedBox(width: 24),
                _buildInfoItem('Stockage', '${subscription.storageUsed} GB'),
                const SizedBox(width: 24),
                _buildInfoItem(
                    'Documents', subscription.documentsStored.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showSubscriptionDetails(subscription),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Détails'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editSubscription(subscription),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteSubscription(subscription),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = AppTheme.accentGreen;
        label = 'Actif';
        break;
      case 'pending':
        color = AppTheme.accentYellow;
        label = 'En attente';
        break;
      case 'expired':
        color = AppTheme.accentRed;
        label = 'Expiré';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nouvel abonnement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Formulaire d'abonnement
              _buildSubscriptionForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client ID
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'ID Client',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // Plan
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Plan',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'basic', child: Text('Basique')),
            DropdownMenuItem(value: 'pro', child: Text('Professionnel')),
            DropdownMenuItem(value: 'enterprise', child: Text('Entreprise')),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        // Durée
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Durée',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 12, child: Text('1 an')),
            DropdownMenuItem(value: 24, child: Text('2 ans')),
            DropdownMenuItem(value: 36, child: Text('3 ans')),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        // Boutons d'action
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Logique de création d'abonnement
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ],
    );
  }

  void _showSubscriptionDetails(ClientSubscription subscription) {
    // Implémenter l'affichage des détails
  }

  void _editSubscription(ClientSubscription subscription) {
    // Implémenter la modification
  }

  void _deleteSubscription(ClientSubscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'abonnement du client ${subscription.clientId} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique de suppression
              Navigator.pop(context);
              setState(() {
                _subscriptions.remove(subscription);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // Implémenter l'exportation des données
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
