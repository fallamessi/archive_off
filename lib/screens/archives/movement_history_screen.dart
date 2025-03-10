// lib/screens/archives/movement_history_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({Key? key}) : super(key: key);

  @override
  _MovementHistoryScreenState createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  String _selectedPeriod = 'Tout';
  String _selectedLocation = 'Tous les emplacements';
  late List<ArchiveMovement> _movements;

  @override
  void initState() {
    super.initState();
    // Simuler les données d'historique
    _movements = [
      ArchiveMovement(
        id: '1',
        archiveReference: 'REF-2024-001',
        fromLocation: 'Local A - Étagère 1',
        toLocation: 'Local B - Étagère 3',
        movedBy: 'John Doe',
        movedAt: DateTime.now().subtract(const Duration(hours: 2)),
        reason: 'Reclassement',
        notes: 'Déplacement pour optimisation de l\'espace',
      ),
      // Autres mouvements...
    ];
  }

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
                // Filtres latéraux
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: _buildFilters(),
                ),
                // Liste des mouvements
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: _buildMovementsList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Historique des déplacements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      child: ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.download),
        label: const Text('Exporter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: Text('Exporter en PDF'),
        ),
        const PopupMenuItem(
          value: 'excel',
          child: Text('Exporter en Excel'),
        ),
      ],
      onSelected: (value) {
        // Gérer l'export
      },
    );
  }

  Widget _buildFilters() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterSection(
          title: 'Période',
          child: Column(
            children: [
              _buildFilterOption(
                title: 'Aujourd\'hui',
                isSelected: _selectedPeriod == 'Aujourd\'hui',
                onTap: () => setState(() => _selectedPeriod = 'Aujourd\'hui'),
              ),
              _buildFilterOption(
                title: 'Cette semaine',
                isSelected: _selectedPeriod == 'Cette semaine',
                onTap: () => setState(() => _selectedPeriod = 'Cette semaine'),
              ),
              _buildFilterOption(
                title: 'Ce mois',
                isSelected: _selectedPeriod == 'Ce mois',
                onTap: () => setState(() => _selectedPeriod = 'Ce mois'),
              ),
              _buildFilterOption(
                title: 'Tout',
                isSelected: _selectedPeriod == 'Tout',
                onTap: () => setState(() => _selectedPeriod = 'Tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Emplacement',
          child: Column(
            children: [
              _buildFilterOption(
                title: 'Tous les emplacements',
                isSelected: _selectedLocation == 'Tous les emplacements',
                onTap: () =>
                    setState(() => _selectedLocation = 'Tous les emplacements'),
              ),
              _buildFilterOption(
                title: 'Local A',
                isSelected: _selectedLocation == 'Local A',
                onTap: () => setState(() => _selectedLocation = 'Local A'),
              ),
              _buildFilterOption(
                title: 'Local B',
                isSelected: _selectedLocation == 'Local B',
                onTap: () => setState(() => _selectedLocation = 'Local B'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFilterSection(
          title: 'Raison du déplacement',
          child: Column(
            children: [
              _buildCheckboxFilter('Reclassement'),
              _buildCheckboxFilter('Optimisation'),
              _buildCheckboxFilter('Archivage'),
              _buildCheckboxFilter('Consultation'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxFilter(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: false,
      onChanged: (value) {
        // Gérer la sélection
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMovementsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movements.length,
      itemBuilder: (context, index) {
        final movement = _movements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              'Déplacement de l\'archive ${movement.archiveReference}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _formatTimestamp(movement.movedAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: AppTheme.primaryBlue,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMovementDetail(
                      'De',
                      movement.fromLocation,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildMovementDetail(
                      'Vers',
                      movement.toLocation,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 8),
                    _buildMovementDetail(
                      'Déplacé par',
                      movement.movedBy,
                      Icons.person,
                    ),
                    const SizedBox(height: 8),
                    _buildMovementDetail(
                      'Raison',
                      movement.reason,
                      Icons.info_outline,
                    ),
                    if (movement.notes != null) ...[
                      const SizedBox(height: 8),
                      _buildMovementDetail(
                        'Notes',
                        movement.notes!,
                        Icons.note,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMovementDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
    }
  }
}

class ArchiveMovement {
  final String id;
  final String archiveReference;
  final String fromLocation;
  final String toLocation;
  final String movedBy;
  final DateTime movedAt;
  final String reason;
  final String? notes;

  ArchiveMovement({
    required this.id,
    required this.archiveReference,
    required this.fromLocation,
    required this.toLocation,
    required this.movedBy,
    required this.movedAt,
    required this.reason,
    this.notes,
  });
}
