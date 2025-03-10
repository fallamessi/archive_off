// lib/screens/documents/document_version_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DocumentVersionScreen extends StatefulWidget {
  final String documentId;

  const DocumentVersionScreen({
    super.key,
    required this.documentId,
  });

  @override
  _DocumentVersionScreenState createState() => _DocumentVersionScreenState();
}

class _DocumentVersionScreenState extends State<DocumentVersionScreen> {
  late List<DocumentVersion> versions;
  DocumentVersion? selectedVersion;

  @override
  void initState() {
    super.initState();
    // Simuler le chargement des versions
    versions = [
      DocumentVersion(
        id: '1',
        versionNumber: '1.0',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        createdBy: 'John Doe',
        changes: 'Version initiale',
        fileSize: '2.5 MB',
      ),
      // Autres versions...
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // En-tête
          _buildHeader(),

          // Contenu principal
          Expanded(
            child: Row(
              children: [
                // Liste des versions
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: _buildVersionsList(),
                ),

                // Détails de la version
                Expanded(
                  child: _buildVersionDetails(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Historique des versions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _uploadNewVersion,
            icon: const Icon(Icons.upload),
            label: const Text('Nouvelle version'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionsList() {
    return ListView.builder(
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        final isSelected = version == selectedVersion;

        return InkWell(
          onTap: () {
            setState(() {
              selectedVersion = version;
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'v${version.versionNumber}',
                    style: TextStyle(
                      color:
                          isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        version.createdBy,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _formatDate(version.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'download',
                      child: Text('Télécharger'),
                    ),
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('Restaurer cette version'),
                    ),
                    const PopupMenuItem(
                      value: 'compare',
                      child: Text('Comparer les versions'),
                    ),
                  ],
                  onSelected: (value) {
                    // Gérer les actions
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionDetails() {
    if (selectedVersion == null) {
      return const Center(
        child: Text('Sélectionnez une version pour voir les détails'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête des détails
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Version ${selectedVersion!.versionNumber}',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(selectedVersion!.createdAt),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Informations détaillées
          _buildDetailSection(
            title: 'Informations',
            content: Column(
              children: [
                _buildDetailRow('Créé par', selectedVersion!.createdBy),
                _buildDetailRow('Taille du fichier', selectedVersion!.fileSize),
                _buildDetailRow('Hash MD5', 'a1b2c3d4e5f6g7h8i9j0'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notes de changement
          _buildDetailSection(
            title: 'Notes de changement',
            content: Text(selectedVersion!.changes),
          ),
          const SizedBox(height: 24),

          // Actions rapides
          _buildDetailSection(
            title: 'Actions rapides',
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Télécharger',
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.restore,
                  label: 'Restaurer',
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.compare_arrows,
                  label: 'Comparer',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required Widget content,
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
        content,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.grey[800],
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  void _uploadNewVersion() {
    // Implémenter la logique d'upload
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class DocumentVersion {
  final String id;
  final String versionNumber;
  final DateTime createdAt;
  final String createdBy;
  final String changes;
  final String fileSize;

  DocumentVersion({
    required this.id,
    required this.versionNumber,
    required this.createdAt,
    required this.createdBy,
    required this.changes,
    required this.fileSize,
  });
}
