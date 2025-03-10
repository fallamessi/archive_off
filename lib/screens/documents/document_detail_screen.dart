// lib/screens/documents/document_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../../theme/app_theme.dart';
import '../../models/document_model.dart';
import '../../models/document_version_model.dart' as model;
import '../../providers/document_provider.dart';
import '../../widgets/document_widgets/document_preview.dart';
import 'document_edit_screen.dart';
import 'document_version_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late DocumentProvider _documentProvider;
  List<model.DocumentVersion> _versions = [];
  bool _isLoadingVersions = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _documentProvider = _documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() => _isLoadingVersions = true);
    try {
      final versions =
          await _documentProvider.getDocumentVersions(widget.document.id);
      setState(() => _versions = versions);
    } finally {
      setState(() => _isLoadingVersions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DocumentPreview(
                              document: widget.document,
                              onDownload: () => _downloadDocument(context),
                              onEdit: () => _navigateToEdit(context),
                              onDelete: () => _deleteDocument(context),
                            ),
                            const SizedBox(height: 24),
                            if (!widget.document.estArchive)
                              _buildWorkflowActions(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 320,
                        child: _buildSidePanel(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading || _isLoadingVersions)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
// deuxieme partie

  Widget _buildHeader(BuildContext context) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Détails du document',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Référence : ${widget.document.reference}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!widget.document.estArchive) ...[
            OutlinedButton.icon(
              onPressed: () => _downloadDocument(context),
              icon: const Icon(Icons.download),
              label: const Text('Télécharger'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _navigateToEdit(context),
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }

// partie 3

  Widget _buildSidePanel(BuildContext context) {
    return Column(
      children: [
        _buildStatusSection(),
        const SizedBox(height: 16),
        _buildClassificationSection(),
        const SizedBox(height: 16),
        _buildMetadataSection(),
        const SizedBox(height: 16),
        _buildVersionHistory(),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildSectionCard(
      title: 'État du document',
      child: Row(
        children: [
          _buildStatusBadge(widget.document.statut),
          if (widget.document.necessiteValidation &&
              widget.document.validateurId != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'En attente de validation',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

// Partie 4

  Widget _buildStatusBadge(DocumentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toString().split('.').last.replaceAll('_', ' '),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClassificationSection() {
    return _buildSectionCard(
      title: 'Classification',
      child: Column(
        children: [
          _buildClassificationItem(
            'Type',
            widget.document.typeDocument
                .toString()
                .split('.')
                .last
                .replaceAll('_', ' '),
            AppTheme.primaryBlue,
          ),
          const SizedBox(height: 8),
          _buildClassificationItem(
            'Niveau d\'accès',
            widget.document.niveauAcces.toString().split('.').last,
            _getAccessLevelColor(widget.document.niveauAcces),
          ),
          if (widget.document.departement != null) ...[
            const SizedBox(height: 8),
            _buildClassificationItem(
              'Département',
              widget.document.departement!,
              Colors.grey,
            ),
          ],
          if (widget.document.motsCles != null &&
              widget.document.motsCles!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.document.motsCles!
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        labelStyle: TextStyle(color: AppTheme.primaryBlue),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

// Partie 5

  Widget _buildClassificationItem(String label, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return _buildSectionCard(
      title: 'Informations',
      child: Column(
        children: [
          _buildMetadataItem('Créé par', widget.document.creePar ?? ''),
          _buildMetadataItem('Créé le', _formatDate(widget.document.creeLe)),
          _buildMetadataItem(
            'Dernière modification',
            _formatDate(widget.document.modifieLe),
          ),
          if (widget.document.modifiePar != null)
            _buildMetadataItem('Modifié par', widget.document.modifiePar!),
          if (widget.document.dateValidation != null)
            _buildMetadataItem(
              'Validé le',
              _formatDate(widget.document.dateValidation!),
            ),
          _buildMetadataItem(
            'Consultations',
            '${widget.document.nombreConsultations} fois',
          ),
          if (widget.document.derniereConsultation != null)
            _buildMetadataItem(
              'Dernière consultation',
              _formatDate(widget.document.derniereConsultation!),
            ),
          if (widget.document.dua != null) ...[
            _buildMetadataItem('DUA', '${widget.document.dua} ans'),
            if (widget.document.dateElimination != null)
              _buildMetadataItem(
                'Date d\'élimination',
                _formatDate(widget.document.dateElimination!),
              ),
          ],
          if (widget.document.estArchive &&
              widget.document.dateArchivage != null)
            _buildMetadataItem(
              'Archivé le',
              _formatDate(widget.document.dateArchivage!),
            ),
        ],
      ),
    );
  }

// Partie 6
  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowActions(BuildContext context) {
    return _buildSectionCard(
      title: 'Actions disponibles',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildActionButton(
            icon: Icons.check_circle_outline,
            label: 'Valider',
            onPressed: () => _validateDocument(context, true),
            color: AppTheme.accentGreen,
          ),
          _buildActionButton(
            icon: Icons.cancel_outlined,
            label: 'Rejeter',
            onPressed: () => _validateDocument(context, false),
            color: AppTheme.accentRed,
          ),
          _buildActionButton(
            icon: Icons.archive_outlined,
            label: 'Archiver',
            onPressed: () => _archiveDocument(context),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildVersionHistory() {
    return _buildSectionCard(
      title: 'Versions',
      trailing: TextButton(
        onPressed: () => _navigateToVersions(context),
        child: const Text('Voir tout'),
      ),
      child: _isLoadingVersions
          ? const Center(child: CircularProgressIndicator())
          : _versions.isEmpty
              ? Center(
                  child: Text(
                    'Aucune version antérieure',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _versions.length.clamp(0, 3),
                  itemBuilder: (context, index) {
                    final version = _versions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: _buildVersionBadge(version.numeroVersion),
                      title: Text(
                        version.commentaire ??
                            'Version ${version.numeroVersion}',
                      ),
                      subtitle: Text(
                        _formatDate(version.creeLe),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildVersionBadge(String version) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'v$version',
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  //Partie 7

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

  Future<void> _downloadDocument(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final bytes =
          await _documentProvider.downloadDocument(widget.document.id);
      if (bytes != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Téléchargement réussi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showValidationDialog(BuildContext context, bool isApproved) {
    final commentController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproved ? 'Valider le document' : 'Rejeter le document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApproved
                  ? 'Le document sera marqué comme validé et disponible pour consultation.'
                  : 'Le document sera renvoyé au créateur pour modification.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Commentaire',
                hintText: isApproved
                    ? 'Ajouter un commentaire de validation (optionnel)'
                    : 'Raison du rejet',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, commentController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isApproved ? AppTheme.accentGreen : AppTheme.accentRed,
            ),
            child: Text(isApproved ? 'Valider' : 'Rejeter'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showArchiveDialog(BuildContext context) {
    final reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver le document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Le document sera déplacé vers les archives et ne sera plus modifiable.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Raison de l\'archivage',
                hintText: 'Expliquez pourquoi ce document doit être archivé',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateDocument(BuildContext context, bool isApproved) async {
    try {
      setState(() => _isLoading = true);
      final commentaire = await _showValidationDialog(context, isApproved);
      if (commentaire != null) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          throw Exception('Utilisateur non connecté');
        }

        final success = await _documentProvider.validateDocument(
          documentId: widget.document.id,
          validateurId: currentUser.id,
          isApproved: isApproved,
          commentaire: commentaire,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApproved ? 'Document validé' : 'Document rejeté'),
              backgroundColor: isApproved ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context);
        }
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _archiveDocument(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      final reason = await _showArchiveDialog(context);
      if (reason != null) {
        final success = await _documentProvider.archiveDocument(
          widget.document.id,
          reason,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document archivé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDocument(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
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
        final success =
            await _documentProvider.deleteDocument(widget.document.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document supprimé')),
          );
          Navigator.pop(context);
        }
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(document: widget.document),
      ),
    ).then((_) => setState(() {}));
  }

  void _navigateToVersions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentVersionScreen(documentId: widget.document.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
