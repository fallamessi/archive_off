// lib/widgets/document_widgets/document_version_list.dart
import 'package:flutter/material.dart';
//import '../../models/document_model.dart';
import '../../theme/app_theme.dart';

class DocumentVersionList extends StatelessWidget {
  final List<DocumentVersion> versions;
  final DocumentVersion? selectedVersion;
  final Function(DocumentVersion) onVersionSelected;
  final Function(DocumentVersion) onVersionDownload;
  final Function(DocumentVersion) onVersionRestore;
  final Function(DocumentVersion, DocumentVersion) onVersionCompare;

  const DocumentVersionList({
    Key? key,
    required this.versions,
    this.selectedVersion,
    required this.onVersionSelected,
    required this.onVersionDownload,
    required this.onVersionRestore,
    required this.onVersionCompare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Historique des versions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              final isSelected = version == selectedVersion;
              final canCompare = index < versions.length - 1;

              return InkWell(
                onTap: () => onVersionSelected(version),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : null,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildVersionBadge(version, isSelected),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              version.commentaire ??
                                  'Version ${version.numeroVersion}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Par ${version.creePar} - ${_formatDate(version.creeLe)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (version.modifications.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Modifications: ${_formatModifications(version.modifications)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => onVersionDownload(version),
                            tooltip: 'Télécharger',
                          ),
                          IconButton(
                            icon: const Icon(Icons.restore),
                            onPressed: () => onVersionRestore(version),
                            tooltip: 'Restaurer cette version',
                          ),
                          if (canCompare)
                            IconButton(
                              icon: const Icon(Icons.compare_arrows),
                              onPressed: () => onVersionCompare(
                                version,
                                versions[index + 1],
                              ),
                              tooltip: 'Comparer avec la version précédente',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVersionBadge(DocumentVersion version, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'v${version.numeroVersion}',
        style: TextStyle(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatModifications(Map<String, dynamic> modifications) {
    final List<String> changes = [];

    if (modifications.containsKey('changed_fields')) {
      final fields = modifications['changed_fields'] as Map<String, dynamic>;
      fields.forEach((key, value) {
        changes.add(key);
      });
    }

    return changes.join(', ');
  }
}

class DocumentVersion {
  final String id;
  final String numeroVersion;
  final String nomFichier;
  final String cheminFichier;
  final int tailleFichier;
  final String? hashMd5;
  final String? commentaire;
  final Map<String, dynamic> modifications;
  final DateTime creeLe;
  final String creePar;
  final bool estMajeure;

  DocumentVersion({
    required this.id,
    required this.numeroVersion,
    required this.nomFichier,
    required this.cheminFichier,
    required this.tailleFichier,
    this.hashMd5,
    this.commentaire,
    this.modifications = const {},
    required this.creeLe,
    required this.creePar,
    this.estMajeure = false,
  });

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'],
      numeroVersion: json['numero_version'],
      nomFichier: json['nom_fichier'],
      cheminFichier: json['chemin_fichier'],
      tailleFichier: json['taille_fichier'],
      hashMd5: json['hash_md5'],
      commentaire: json['commentaire'],
      modifications: json['modifications'] ?? {},
      creeLe: DateTime.parse(json['cree_le']),
      creePar: json['cree_par'],
      estMajeure: json['est_majeure'] ?? false,
    );
  }
}
