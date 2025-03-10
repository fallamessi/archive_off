import 'package:dan/screens/documents/document_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/document_model.dart';
import '../../providers/document_provider.dart';
import '../../widgets/document_widgets/document_card.dart';
import '../../widgets/document_widgets/document_filter.dart';
import 'document_create_screen.dart';
import 'document_detail_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  bool _showGrid = false;
  Map<String, dynamic> _currentFilters = {};
  late DocumentProvider _documentProvider;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    try {
      await _documentProvider.loadDocuments(
        type: _currentFilters['type'],
        accessLevel: _currentFilters['access_level'],
        department: _currentFilters['department'],
        status: _currentFilters['status'],
        searchQuery: _searchQuery,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panneau des filtres
          DocumentFilters(
            initialFilters: _currentFilters,
            onFiltersChanged: _handleFilterChange,
          ),

          // Liste des documents
          Expanded(
            child: Column(
              children: [
                // En-tête avec barre de recherche et boutons d'action
                _buildHeader(),

                // Affichage des filtres actifs
                if (_currentFilters.isNotEmpty)
                  ActiveFilters(
                    filters: _currentFilters,
                    onRemoveFilter: _handleRemoveFilter,
                  ),

                // Liste des documents
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildDocumentsList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateDocument,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            'Documents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _loadDocuments();
              },
            ),
          ),
          const SizedBox(width: 24),
          // Bouton de vue grille/liste
          IconButton(
            icon: Icon(_showGrid ? Icons.view_list : Icons.grid_view),
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

  Widget _buildDocumentsList() {
    final documents = _documentProvider.documents;

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun document trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par ajouter un document ou modifiez vos filtres',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return _showGrid
        ? _buildDocumentGrid(documents)
        : _buildDocumentList(documents);
  }

  Widget _buildDocumentList(List<Document> documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DocumentCard(
            document: document,
            onTap: () => _navigateToDetail(document),
            onEdit: () => _navigateToEdit(document),
            onDelete: () => _deleteDocument(document),
          ),
        );
      },
    );
  }

  Widget _buildDocumentGrid(List<Document> documents) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return DocumentCard(
          document: document,
          onTap: () => _navigateToDetail(document),
          onEdit: () => _navigateToEdit(document),
          onDelete: () => _deleteDocument(document),
        );
      },
    );
  }

  void _handleFilterChange(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    _loadDocuments();
  }

  void _handleRemoveFilter(String key) {
    setState(() {
      if (key == 'search') {
        _currentFilters.remove('search');
        _searchQuery = '';
      } else if (key == 'dateRange') {
        _currentFilters.remove('dateRange');
      } else if (key.startsWith('service:')) {
        final services =
            List<String>.from(_currentFilters['selected_services'] ?? []);
        services.remove(key.replaceFirst('service:', ''));
        _currentFilters['selected_services'] = services;
      } else {
        final filters =
            List<String>.from(_currentFilters['selected_filters'] ?? []);
        filters.remove(key);
        _currentFilters['selected_filters'] = filters;
      }
    });
    _loadDocuments();
  }

  void _navigateToDetail(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailScreen(document: document),
      ),
    ).then((_) => _loadDocuments());
  }

  void _navigateToCreateDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentCreateScreen(),
      ),
    ).then((_) => _loadDocuments());
  }

  void _navigateToEdit(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(document: document),
      ),
    ).then((_) => _loadDocuments());
  }

  Future<void> _deleteDocument(Document document) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce document ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _documentProvider.deleteDocument(document.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document supprimé')),
          );
          _loadDocuments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
