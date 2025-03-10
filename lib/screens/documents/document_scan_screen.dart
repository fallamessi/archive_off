// lib/screens/documents/document_scan_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  _DocumentScanScreenState createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Document administratif';
  String _selectedService = 'Direction générale';
  String _selectedQuality = 'Standard (200 DPI)';
  bool _isColorScan = true;
  bool _isDoubleSided = false;
  bool _autoRotate = true;
  bool _removeBlankPages = true;
  int _currentPage = 1;
  List<String> _scannedPages = [];

  final List<String> _documentTypes = [
    'Document administratif',
    'Rapport',
    'Note de service',
    'Correspondance',
    'Contrat',
  ];

  final List<String> _services = [
    'Direction générale',
    'Service technique',
    'Service administratif',
    'Service financier',
  ];

  final List<String> _scanQualities = [
    'Basse (150 DPI)',
    'Standard (200 DPI)',
    'Haute (300 DPI)',
    'Ultra haute (600 DPI)',
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
                // Zone de prévisualisation
                Expanded(
                  flex: 2,
                  child: _buildPreviewArea(),
                ),
                // Panneau des paramètres
                SizedBox(
                  width: 400,
                  child: _buildSettingsPanel(),
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          const Text(
            'Numérisation de document',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Barre d'outils de numérisation
          _buildScanToolbar(),
          // Zone de prévisualisation
          Expanded(
            child: _scannedPages.isEmpty
                ? _buildEmptyPreview()
                : _buildPagePreview(),
          ),
          // Barre de pagination
          if (_scannedPages.isNotEmpty) _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildScanToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.scanner),
            label: const Text('Numériser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: _importFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Importer'),
          ),
          const Spacer(),
          if (_scannedPages.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.rotate_left),
              onPressed: () => _rotatePage(false),
              tooltip: 'Rotation gauche',
            ),
            IconButton(
              icon: const Icon(Icons.rotate_right),
              onPressed: () => _rotatePage(true),
              tooltip: 'Rotation droite',
            ),
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: _cropPage,
              tooltip: 'Recadrer',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deletePage,
              tooltip: 'Supprimer',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.scanner,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune page numérisée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur "Numériser" pour commencer',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagePreview() {
    return Center(
      child: AspectRatio(
        aspectRatio: 0.707, // Ratio A4
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Preview de la page actuelle
              Center(
                child: Text(
                  'Page $_currentPage/${_scannedPages.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Boutons navigation
              if (_scannedPages.length > 1) ...[
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildPageNavigationButton(false),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _buildPageNavigationButton(true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavigationButton(bool isNext) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigatePage(isNext),
        child: Container(
          width: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            border: Border(
              left: isNext
                  ? const BorderSide(color: Colors.black12)
                  : BorderSide.none,
              right: !isNext
                  ? const BorderSide(color: Colors.black12)
                  : BorderSide.none,
            ),
          ),
          child: Icon(
            isNext ? Icons.chevron_right : Icons.chevron_left,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Page $_currentPage sur ${_scannedPages.length}',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Informations du document
            _buildSectionTitle('Informations du document'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Référence',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de document',
                border: OutlineInputBorder(),
              ),
              items: _documentTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(
                labelText: 'Service',
                border: OutlineInputBorder(),
              ),
              items: _services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedService = value!);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Paramètres de numérisation
            _buildSectionTitle('Paramètres de numérisation'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedQuality,
              decoration: const InputDecoration(
                labelText: 'Qualité',
                border: OutlineInputBorder(),
              ),
              items: _scanQualities.map((quality) {
                return DropdownMenuItem(
                  value: quality,
                  child: Text(quality),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedQuality = value!);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Numérisation couleur'),
              value: _isColorScan,
              onChanged: (value) {
                setState(() => _isColorScan = value);
              },
            ),
            SwitchListTile(
              title: const Text('Recto-verso'),
              value: _isDoubleSided,
              onChanged: (value) {
                setState(() => _isDoubleSided = value);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Options de traitement'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Rotation automatique'),
              subtitle: const Text('Corriger l\'orientation des pages'),
              value: _autoRotate,
              onChanged: (value) {
                setState(() => _autoRotate = value);
              },
            ),
            SwitchListTile(
              title: const Text('Supprimer les pages blanches'),
              subtitle: const Text('Détecter et supprimer les pages vides'),
              value: _removeBlankPages,
              onChanged: (value) {
                setState(() => _removeBlankPages = value);
              },
            ),
            const SizedBox(height: 32),

            // Boutons d'action
            ElevatedButton.icon(
              onPressed: _saveDocument,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Méthodes d'action
  void _startScanning() {
    // Implémenter l'interaction avec le scanner
  }

  void _importFile() {
    // Implémenter l'import de fichier
  }

  void _rotatePage(bool clockwise) {
    // Implémenter la rotation
  }

  void _cropPage() {
    // Implémenter le recadrage
  }

  void _deletePage() {
    // Implémenter la suppression
  }

  void _navigatePage(bool next) {
    setState(() {
      if (next && _currentPage < _scannedPages.length) {
        _currentPage++;
      } else if (!next && _currentPage > 1) {
        _currentPage--;
      }
    });
  }

  void _saveDocument() {
    if (_formKey.currentState!.validate()) {
      // Implémenter la sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document enregistré avec succès')),
      );
      Navigator.pop(context);
    }
  }
}
