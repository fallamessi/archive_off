import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/document_model.dart';
import '../../providers/document_provider.dart';
import '../../theme/app_theme.dart';

class DocumentEditScreen extends StatefulWidget {
  final Document document;

  const DocumentEditScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DocumentType _selectedType;
  late String? _selectedService;
  late AccessLevel _selectedAccessLevel;
  bool _isDirty = false;
  bool _isLoading = false;
  PlatformFile? _selectedFile;
  late DocumentProvider _documentProvider;

  final List<String> _services = [
    'Direction générale',
    'Service technique',
    'Service administratif',
    'Service financier',
  ];

  @override
  void initState() {
    super.initState();
    _documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    _initializeFormValues();
  }

  void _initializeFormValues() {
    _titleController = TextEditingController(text: widget.document.titre);
    _descriptionController =
        TextEditingController(text: widget.document.description);
    _selectedType = widget.document.typeDocument;
    _selectedService = widget.document.departement;
    _selectedAccessLevel = widget.document.niveauAcces;
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Des modifications non sauvegardées'),
        content: const Text(
            'Voulez-vous quitter sans sauvegarder vos modifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildFileSection(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _buildForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
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
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 16),
          const Text(
            'Modifier le document',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fichier du document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_present),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile?.name ?? widget.document.nomFichier,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedFile != null
                                ? 'Nouvelle version'
                                : 'Version actuelle',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedFile != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                            _isDirty = true;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickNewFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Téléverser une nouvelle version'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Form(
        key: _formKey,
        onChanged: () {
          setState(() {
            _isDirty = true;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildTypeDropdown(),
            const SizedBox(height: 16),
            _buildServiceDropdown(),
            const SizedBox(height: 16),
            _buildAccessLevelDropdown(),
            const SizedBox(height: 16),
            _buildMetadataFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
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
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<DocumentType>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type de document',
        border: OutlineInputBorder(),
      ),
      items: DocumentType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
          _isDirty = true;
        });
      },
    );
  }

  Widget _buildServiceDropdown() {
    return DropdownButtonFormField<String>(
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
        setState(() {
          _selectedService = value;
          _isDirty = true;
        });
      },
    );
  }

  Widget _buildAccessLevelDropdown() {
    return DropdownButtonFormField<AccessLevel>(
      value: _selectedAccessLevel,
      decoration: const InputDecoration(
        labelText: 'Niveau d\'accès',
        border: OutlineInputBorder(),
      ),
      items: AccessLevel.values.map((level) {
        return DropdownMenuItem(
          value: level,
          child: Text(level.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedAccessLevel = value!;
          _isDirty = true;
        });
      },
    );
  }

  Widget _buildMetadataFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métadonnées complémentaires',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Ajoutez ici d'autres champs de métadonnées spécifiques
      ],
    );
  }

  Future<void> _pickNewFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _isDirty = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection du fichier'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updates = {
          'titre': _titleController.text,
          'description': _descriptionController.text,
          'type_document': _selectedType.toString().split('.').last,
          'niveau_acces': _selectedAccessLevel.toString().split('.').last,
          'departement': _selectedService,
        };

        Uint8List? fileBytes;
        String? fileName;
        String? fileType;

        if (_selectedFile != null) {
          fileBytes = _selectedFile!.bytes;
          fileName = _selectedFile!.name;
          fileType = _selectedFile!.extension;
        }

        final success = await _documentProvider.updateDocument(
          documentId: widget.document.id,
          updates: updates,
          newFileBytes: fileBytes,
          newFileName: fileName,
          newFileType: fileType,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
