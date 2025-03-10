// lib/widgets/document_widgets/document_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/document_model.dart';
import '../../providers/document_provider.dart';
import '../../theme/app_theme.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentCard({
    Key? key,
    required this.document,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône du type de document
              _buildDocumentIcon(),
              const SizedBox(width: 16),

              // Informations du document
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.titre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          document.reference,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (document.description != null) ...[
                      Text(
                        document.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        _buildTag(
                          document.typeDocument.toString().split('.').last,
                          AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        _buildTag(
                          document.statut.toString().split('.').last,
                          _getStatusColor(document.statut),
                        ),
                        const SizedBox(width: 8),
                        _buildTag(
                          document.niveauAcces.toString().split('.').last,
                          _getAccessLevelColor(document.niveauAcces),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(document.creeLe),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      _downloadDocument(context);
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text('Télécharger'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getDocumentIcon(),
        color: AppTheme.primaryBlue,
        size: 24,
      ),
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

  IconData _getDocumentIcon() {
    switch (document.typeDocument) {
      case DocumentType.document_administratif:
        return Icons.description;
      case DocumentType.rapport:
        return Icons.assessment;
      case DocumentType.note_service:
        return Icons.note;
      case DocumentType.correspondance:
        return Icons.mail;
      case DocumentType.contrat:
        return Icons.handshake;
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.valide:
        return AppTheme.accentGreen;
      case DocumentStatus.en_revision:
      case DocumentStatus.a_valider:
        return AppTheme.accentYellow;
      case DocumentStatus.a_modifier:
        return AppTheme.accentRed;
      default:
        return Colors.grey;
    }
  }

  Color _getAccessLevelColor(AccessLevel level) {
    switch (level) {
      case AccessLevel.public:
        return AppTheme.accentGreen;
      case AccessLevel.interne:
        return AppTheme.primaryBlue;
      case AccessLevel.confidentiel:
        return AppTheme.accentYellow;
      case AccessLevel.secret:
        return AppTheme.accentRed;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _downloadDocument(BuildContext context) {
    final documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);
    documentProvider.downloadDocument(document.id).then((bytes) {
      if (bytes != null) {
        // Implémenter le téléchargement côté client
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Téléchargement réussi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}

/// Widget pour afficher une grille de documents
class DocumentGrid extends StatelessWidget {
  final List<Document> documents;
  final Function(Document) onDocumentTap;
  final Function(Document) onDownload;
  final Function(Document) onEdit;
  final Function(Document) onDelete;

  const DocumentGrid({
    Key? key,
    required this.documents,
    required this.onDocumentTap,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return DocumentCard(
          document: document,
          onTap: () => onDocumentTap(document),
          onEdit: () => onEdit(document),
          onDelete: () => onDelete(document),
        );
      },
    );
  }
}
