// lib/screens/archives/archive_list_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/archive_model.dart';
import 'archive_detail_screen.dart';
import 'archive_form_dialog.dart';
import 'archive_locations_dashboard.dart';
//import 'archive_movement_history_screen.dart';

class ArchiveListScreen extends StatefulWidget {
  const ArchiveListScreen({super.key});

  @override
  State<ArchiveListScreen> createState() => _ArchiveListScreenState();
}

class _ArchiveListScreenState extends State<ArchiveListScreen> {
  final List<String> _locationFilters = [
    'Tous les emplacements',
    'Local A',
    'Local B',
    'Local C'
  ];
  String _selectedLocation = 'Tous les emplacements';
  bool _showGrid = false;
  final TextEditingController _yearFromController = TextEditingController();
  final TextEditingController _yearToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _selectedStatus = {
    'À conserver': false,
    'À éliminer': false,
    'À verser': false,
  };
  int _selectedDUA = 5;

  @override
  void dispose() {
    _yearFromController.dispose();
    _yearToController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Barre supérieure
                _buildTopBar(),

                // Contenu principal avec filtres latéraux
                Expanded(
                  child: Row(
                    children: [
                      // Panneau de filtres latéral
                      _buildFilterPanel(),

                      // Liste des archives
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          child: Column(
                            children: [
                              // En-tête de la liste
                              _buildListHeader(),

                              // Liste des archives
                              Expanded(
                                child: _showGrid
                                    ? _buildArchiveGrid()
                                    : _buildArchiveList(),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLocalDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau local'),
      ),
    );
  }

  // Méthodes de construction de l'interface

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher dans les archives...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
        ),
        onChanged: (value) {
          setState(() {
            // Implémenter la logique de recherche
          });
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
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
          Expanded(child: _buildSearchBar()),
          const SizedBox(width: 16),
          _buildNewArchiveButton(),
        ],
      ),
    );
  }

  Widget _buildNewArchiveButton() {
    return ElevatedButton.icon(
      onPressed: () => _showNewArchiveDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Nouvelle archive'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
            'Archives (${_showGrid ? "Vue grille" : "Vue liste"})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_showGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
          ),
        ],
      ),
    );
  }

  // Méthodes pour les filtres

  Widget _buildFilterPanel() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationFilter(),
                  const SizedBox(height: 24),
                  _buildYearFilter(),
                  const SizedBox(height: 24),
                  _buildDUAFilter(),
                  const SizedBox(height: 24),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ),
          _buildApplyFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
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
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emplacement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _locationFilters.length,
          (index) => _buildFilterOption(
            title: _locationFilters[index],
            isSelected: _selectedLocation == _locationFilters[index],
            onTap: () {
              setState(() {
                _selectedLocation = _locationFilters[index];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Année',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _yearFromController,
                decoration: InputDecoration(
                  hintText: 'De',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            const Text('à'),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _yearToController,
                decoration: InputDecoration(
                  hintText: 'À',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDUASlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée d\'utilité administrative (DUA)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('$_selectedDUA ans'),
            Expanded(
              child: Slider(
                value: _selectedDUA.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_selectedDUA ans',
                onChanged: (value) {
                  setState(() {
                    _selectedDUA = value.round();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'État',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._selectedStatus.entries.map(
          (entry) => CheckboxListTile(
            title: Text(entry.key),
            value: entry.value,
            onChanged: (bool? value) {
              setState(() {
                _selectedStatus[entry.key] = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyFiltersButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.all(16),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Appliquer les filtres'),
      ),
    );
  }

  // Méthodes de construction des listes

  Widget _buildArchiveList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.archive_rounded,
                color: AppTheme.primaryBlue,
              ),
            ),
            title: Text('Archive ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Référence: REF-2024-${index + 1}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildArchiveTag('Local A', Colors.blue),
                    const SizedBox(width: 8),
                    _buildArchiveTag('5 ans', Colors.orange),
                  ],
                ),
              ],
            ),
            onTap: () => _navigateToArchiveDetail(context, index),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) =>
                  _handleArchiveAction(context, value, index),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('Voir les détails'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier'),
                ),
                const PopupMenuItem(
                  value: 'move',
                  child: Text('Déplacer'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () => _navigateToArchiveDetail(context, index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.archive_rounded,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) =>
                            _handleArchiveAction(context, value, index),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('Voir les détails'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Modifier'),
                          ),
                          const PopupMenuItem(
                            value: 'move',
                            child: Text('Déplacer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Archive ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'REF-2024-${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildArchiveTag('Local A', Colors.blue),
                      const SizedBox(width: 8),
                      _buildArchiveTag('5 ans', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDUAFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée d\'utilité administrative (DUA)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('$_selectedDUA ans'),
            Expanded(
              child: Slider(
                value: _selectedDUA.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_selectedDUA ans',
                onChanged: (value) {
                  setState(() {
                    _selectedDUA = value.round();
                  });
                },
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
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

  void _navigateToArchiveDetail(BuildContext context, int archiveIndex) {
    final archive = Archive(
      id: 'ARCH-$archiveIndex',
      reference: 'REF-2024-$archiveIndex',
      description: 'Description de l\'archive $archiveIndex',
      location: 'Local A',
      dua: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'John Doe',
      status: 'À conserver',
      metadata: {'type': 'Document administratif'},
      eliminationDate: DateTime.now().add(const Duration(days: 365 * 5)),
      transferDate: null,
      notes: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveDetailScreen(archive: archive),
      ),
    );
  }

  void _handleArchiveAction(
      BuildContext context, String action, int archiveIndex) {
    switch (action) {
      case 'view':
        _navigateToArchiveDetail(context, archiveIndex);
        break;
      case 'edit':
        _showEditArchiveDialog(context, archiveIndex);
        break;
      case 'move':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArchiveLocationsDashboard(),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, archiveIndex);
        break;
    }
  }

  // Méthodes de navigation et d'action

  Widget _buildArchiveTag(String text, Color color) {
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

  void _showEditArchiveDialog(BuildContext context, int archiveIndex) {
    showDialog(
      context: context,
      builder: (context) => ArchiveFormDialog(
        archiveData: {
          'reference': 'REF-2024-$archiveIndex',
          'description': 'Description de l\'archive $archiveIndex',
          'location': 'Local A',
          'dua': 5,
          'status': 'À conserver',
        },
      ),
    ).then((value) {
      if (value != null) {
        // Rafraîchir la liste après modification
        setState(() {});
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, int archiveIndex) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'archive REF-2024-$archiveIndex ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Ajouter la logique de suppression ici
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Archive supprimée')),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showNewArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ArchiveFormDialog(),
    ).then((value) {
      if (value != null) {
        // Rafraîchir la liste des archives
        setState(() {});
      }
    });
  }

  void _showAddLocalDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArchiveLocationsDashboard(),
      ),
    );
  }

  void _showArchiveDetail(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveDetailScreen(
          archive: Archive(
            id: 'ARCH-$index',
            reference: 'REF-2024-$index',
            description: 'Description de l\'archive $index',
            location: 'Local A',
            dua: 5,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: 'John Doe',
            status: 'À conserver',
            metadata: {'type': 'Document administratif'},
            eliminationDate: DateTime.now().add(const Duration(days: 365 * 5)),
            transferDate: null,
            notes: '',
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = 'Tous les emplacements';
      _yearFromController.clear();
      _yearToController.clear();
      _selectedDUA = 5;
      _selectedStatus.updateAll((key, value) => false);
    });
  }

  void _applyFilters() {
    // Implémenter la logique de filtrage
    setState(() {});
  }
}
