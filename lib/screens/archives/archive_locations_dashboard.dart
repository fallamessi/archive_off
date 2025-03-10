// lib/screens/archives/archive_locations_dashboard.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
//import '../../models/archive_model.dart';

class ArchiveLocationsDashboard extends StatefulWidget {
  const ArchiveLocationsDashboard({super.key});

  @override
  State<ArchiveLocationsDashboard> createState() =>
      _ArchiveLocationsDashboardState();
}

class _ArchiveLocationsDashboardState extends State<ArchiveLocationsDashboard> {
  String _selectedLocal = 'Local A';
  bool _showCapacityWarnings = true;

  // Ces données devraient venir d'une API
  final Map<String, List<LocalEtagere>> _locauxData = {
    'Local A': [
      LocalEtagere(
        id: 'A1',
        nom: 'Étagère 1',
        capaciteMax: 100,
        archivesCount: 75,
        positions: [
          Position(nom: '1A', occupee: true),
          Position(nom: '1B', occupee: true),
          Position(nom: '1C', occupee: false),
          Position(nom: '1D', occupee: true),
        ],
      ),
      LocalEtagere(
        id: 'A2',
        nom: 'Étagère 2',
        capaciteMax: 100,
        archivesCount: 95,
        positions: [
          Position(nom: '2A', occupee: true),
          Position(nom: '2B', occupee: true),
          Position(nom: '2C', occupee: true),
          Position(nom: '2D', occupee: true),
        ],
      ),
    ],
    'Local B': [
      // Ajouter les données pour le Local B
    ],
  };

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
                // Panneau de navigation des locaux
                SizedBox(
                  width: 280,
                  child: _buildLocauxNavigation(),
                ),
                // Vue détaillée du local sélectionné
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: _buildLocalDetail(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEtagereDialog,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
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
            'Emplacements des archives',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Switch pour afficher/masquer les alertes de capacité
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20),
              const SizedBox(width: 8),
              const Text('Alertes de capacité'),
              const SizedBox(width: 8),
              Switch(
                value: _showCapacityWarnings,
                onChanged: (value) {
                  setState(() {
                    _showCapacityWarnings = value;
                  });
                },
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocauxNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Locaux',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddLocalDialog,
                  tooltip: 'Ajouter un local',
                ),
              ],
            ),
          ),
          // Liste des locaux
          Expanded(
            child: ListView.builder(
              itemCount: _locauxData.length,
              itemBuilder: (context, index) {
                final local = _locauxData.keys.elementAt(index);
                final isSelected = local == _selectedLocal;
                return _buildLocalNavigationItem(local, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalNavigationItem(String local, bool isSelected) {
    final etageres = _locauxData[local] ?? [];
    final totalArchives = etageres.fold<int>(
      0,
      (sum, etagere) => sum + etagere.archivesCount,
    );
    final totalCapacite = etageres.fold<int>(
      0,
      (sum, etagere) => sum + etagere.capaciteMax,
    );
    final occupationRate =
        totalCapacite > 0 ? (totalArchives / totalCapacite * 100).round() : 0;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocal = local;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  local,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primaryBlue : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProgressBar(
              occupationRate.toDouble(),
              label: '$occupationRate% occupé',
            ),
            const SizedBox(height: 4),
            Text(
              '$totalArchives archives sur $totalCapacite emplacements',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalDetail() {
    final etageres = _locauxData[_selectedLocal] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du local
          Text(
            _selectedLocal,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Grille d'étagères
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.5,
            ),
            itemCount: etageres.length,
            itemBuilder: (context, index) {
              return _buildEtagereCard(etageres[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEtagereCard(LocalEtagere etagere) {
    final occupationRate =
        (etagere.archivesCount / etagere.capaciteMax * 100).round();
    final isNearCapacity = occupationRate >= 90;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isNearCapacity && _showCapacityWarnings
              ? AppTheme.accentRed.withOpacity(0.5)
              : Colors.grey[200]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        etagere.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${etagere.archivesCount} archives sur ${etagere.capaciteMax} emplacements',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditEtagereDialog(etagere);
                        break;
                      case 'delete':
                        _showDeleteEtagereDialog(etagere);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              occupationRate.toDouble(),
              showWarning: _showCapacityWarnings,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: etagere.positions.map((position) {
                  return _buildPositionCell(position);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    double percentage, {
    String? label,
    bool showWarning = true,
  }) {
    final isNearCapacity = percentage >= 90;
    final color = isNearCapacity && showWarning
        ? AppTheme.accentRed
        : AppTheme.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionCell(Position position) {
    return Container(
      decoration: BoxDecoration(
        color: position.occupee
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: position.occupee
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: Text(
          position.nom,
          style: TextStyle(
            color: position.occupee ? AppTheme.primaryBlue : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showAddLocalDialog() {
    // Implémenter l'ajout d'un nouveau local
  }

  void _showAddEtagereDialog() {
    // Implémenter l'ajout d'une nouvelle étagère
  }

  void _showEditEtagereDialog(LocalEtagere etagere) {
    // Implémenter la modification d'une étagère
  }

  void _showDeleteEtagereDialog(LocalEtagere etagere) {
    // Implémenter la suppression d'une étagère
  }
}

class LocalEtagere {
  final String id;
  final String nom;
  final int capaciteMax;
  final int archivesCount;
  final List<Position> positions;

  LocalEtagere({
    required this.id,
    required this.nom,
    required this.capaciteMax,
    required this.archivesCount,
    required this.positions,
  });
}

class Position {
  final String nom;
  final bool occupee;

  Position({
    required this.nom,
    required this.occupee,
  });
}
