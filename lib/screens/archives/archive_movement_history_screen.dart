// lib/screens/archives/archive_movement_history_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArchiveMovementHistoryScreen extends StatefulWidget {
  final String? archiveReference; // Optionnel: pour filtrer par archive

  const ArchiveMovementHistoryScreen({
    super.key,
    this.archiveReference,
  });

  @override
  State<ArchiveMovementHistoryScreen> createState() =>
      _ArchiveMovementHistoryScreenState();
}

class _ArchiveMovementHistoryScreenState
    extends State<ArchiveMovementHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = 'Tout';
  String _selectedLocation = 'Tous les emplacements';
  List<String> _selectedReasons = [];
  late List<ArchiveMovement> _movements;
  List<ArchiveMovement> _filteredMovements = [];

  @override
  void initState() {
    super.initState();
    // Simuler le chargement des données
    _movements = _getMockMovements();
    _filterMovements();
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
                // Panneau de filtres
                SizedBox(
                  width: 280,
                  child: _buildFiltersPanel(),
                ),
                // Tableau des mouvements
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: _buildMovementsTable(),
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
          if (widget.archiveReference != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Archive ${widget.archiveReference}',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.download),
            label: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          // En-tête des filtres
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
                  'Filtres',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),
          // Contenu des filtres
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => _filterMovements(),
                ),
                const SizedBox(height: 24),
                // Période
                _buildFilterSection(
                  title: 'Période',
                  child: Column(
                    children: [
                      _buildFilterOption(
                        'Aujourd\'hui',
                        _selectedPeriod == 'Aujourd\'hui',
                        () => _setPeriod('Aujourd\'hui'),
                      ),
                      _buildFilterOption(
                        'Cette semaine',
                        _selectedPeriod == 'Cette semaine',
                        () => _setPeriod('Cette semaine'),
                      ),
                      _buildFilterOption(
                        'Ce mois',
                        _selectedPeriod == 'Ce mois',
                        () => _setPeriod('Ce mois'),
                      ),
                      _buildFilterOption(
                        'Tout',
                        _selectedPeriod == 'Tout',
                        () => _setPeriod('Tout'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Emplacement
                _buildFilterSection(
                  title: 'Emplacement',
                  child: Column(
                    children: [
                      _buildFilterOption(
                        'Tous les emplacements',
                        _selectedLocation == 'Tous les emplacements',
                        () => _setLocation('Tous les emplacements'),
                      ),
                      _buildFilterOption(
                        'Local A',
                        _selectedLocation == 'Local A',
                        () => _setLocation('Local A'),
                      ),
                      _buildFilterOption(
                        'Local B',
                        _selectedLocation == 'Local B',
                        () => _setLocation('Local B'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Raisons
                _buildFilterSection(
                  title: 'Raison du déplacement',
                  child: Column(
                    children: [
                      _buildCheckboxOption('Reclassement'),
                      _buildCheckboxOption('Optimisation'),
                      _buildCheckboxOption('Archivage'),
                      _buildCheckboxOption('Consultation'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsTable() {
    return Column(
      children: [
        // En-tête du tableau
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '${_filteredMovements.length} mouvements',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Tableau
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredMovements.length,
            itemBuilder: (context, index) {
              final movement = _filteredMovements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: Text(movement.archiveReference),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'De "${movement.fromLocation}" vers "${movement.toLocation}"',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag(movement.reason, AppTheme.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            'par ${movement.movedBy}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    _formatDateTime(movement.movedAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
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
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFilterOption(
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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

  Widget _buildCheckboxOption(String reason) {
    final isSelected = _selectedReasons.contains(reason);
    return CheckboxListTile(
      title: Text(reason),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value ?? false) {
            _selectedReasons.add(reason);
          } else {
            _selectedReasons.remove(reason);
          }
          _filterMovements();
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _filterMovements();
    });
  }

  void _setLocation(String location) {
    setState(() {
      _selectedLocation = location;
      _filterMovements();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedPeriod = 'Tout';
      _selectedLocation = 'Tous les emplacements';
      _selectedReasons.clear();
      _filterMovements();
    });
  }

  void _filterMovements() {
    setState(() {
      _filteredMovements = _movements.where((movement) {
        // Filtre par recherche
        if (_searchController.text.isNotEmpty) {
          final search = _searchController.text.toLowerCase();
          if (!movement.archiveReference.toLowerCase().contains(search) &&
              !movement.fromLocation.toLowerCase().contains(search) &&
              !movement.toLocation.toLowerCase().contains(search) &&
              !movement.movedBy.toLowerCase().contains(search)) {
            return false;
          }
        }

        // Filtre par période
        if (_selectedPeriod != 'Tout') {
          final now = DateTime.now();
          final diff = now.difference(movement.movedAt);
          switch (_selectedPeriod) {
            case 'Aujourd\'hui':
              if (diff.inDays > 0) return false;
              break;
            case 'Cette semaine':
              if (diff.inDays > 7) return false;
              break;
            case 'Ce mois':
              if (diff.inDays > 30) return false;
              break;
          }
        }

        // Filtre par emplacement
        if (_selectedLocation != 'Tous les emplacements') {
          if (movement.fromLocation != _selectedLocation &&
              movement.toLocation != _selectedLocation) {
            return false;
          }
        }

        // Filtre par raison
        if (_selectedReasons.isNotEmpty &&
            !_selectedReasons.contains(movement.reason)) {
          return false;
        }

        return true;
      }).toList();

      // Tri par date décroissante
      _filteredMovements.sort((a, b) => b.movedAt.compareTo(a.movedAt));
    });
  }

  void _generateReport() {
    // Implémenter la génération de rapport
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export en cours...')),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<ArchiveMovement> _getMockMovements() {
    // Simuler des données de test
    return [
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
      // Ajouter plus de mouvements...
    ];
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
