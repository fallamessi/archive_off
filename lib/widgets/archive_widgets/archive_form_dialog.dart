// lib/screens/archives/archive_form_dialog.dart
import 'package:flutter/material.dart';
import '../../models/archive_model.dart';
import '../../theme/app_theme.dart';

class ArchiveFormDialog extends StatefulWidget {
  final Archive? archive;

  const ArchiveFormDialog({
    Key? key,
    this.archive,
    required Map<String, Object> archiveData,
  }) : super(key: key);

  @override
  State<ArchiveFormDialog> createState() => _ArchiveFormDialogState();
}

class _ArchiveFormDialogState extends State<ArchiveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _referenceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  String _selectedLocation = 'Local A';
  int _selectedDUA = 5;
  String _selectedStatus = 'À conserver';
  Map<String, dynamic> _metadata = {};
  DateTime? _eliminationDate;
  DateTime? _transferDate;

  final List<String> _locations = ['Local A', 'Local B', 'Local C'];
  final List<String> _statuses = ['À conserver', 'À éliminer', 'À verser'];

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs existantes si en mode édition
    _referenceController =
        TextEditingController(text: widget.archive?.reference ?? '');
    _descriptionController =
        TextEditingController(text: widget.archive?.description ?? '');
    _notesController = TextEditingController(text: widget.archive?.notes ?? '');

    if (widget.archive != null) {
      _selectedLocation = widget.archive!.location;
      _selectedDUA = widget.archive!.dua;
      _selectedStatus = widget.archive!.status;
      _metadata = Map.from(widget.archive!.metadata);
      _eliminationDate = widget.archive!.eliminationDate;
      _transferDate = widget.archive!.transferDate;
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Colonne gauche
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoSection(),
                                const SizedBox(height: 24),
                                _buildLocationSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Colonne droite
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildConservationSection(),
                                const SizedBox(height: 24),
                                _buildMetadataSection(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          widget.archive == null ? 'Nouvelle archive' : 'Modifier l\'archive',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations générales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _referenceController,
          decoration: const InputDecoration(
            labelText: 'Référence',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La référence est requise';
            }
            return null;
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
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: const InputDecoration(
            labelText: 'Emplacement',
            border: OutlineInputBorder(),
          ),
          items: _locations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLocation = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildConservationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conservation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedDUA,
          decoration: const InputDecoration(
            labelText: 'DUA (années)',
            border: OutlineInputBorder(),
          ),
          items: List.generate(10, (i) => i + 1)
              .map((dua) => DropdownMenuItem(
                    value: dua,
                    child: Text('$dua ans'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedDUA = value;
                // Calculer automatiquement la date d'élimination
                _eliminationDate =
                    DateTime.now().add(Duration(days: 365 * value));
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: const InputDecoration(
            labelText: 'État',
            border: OutlineInputBorder(),
          ),
          items: _statuses
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Métadonnées',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addMetadata,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._metadata.entries.map((entry) => _buildMetadataField(entry.key)),
      ],
    );
  }

  Widget _buildMetadataField(String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: key,
              decoration: const InputDecoration(
                labelText: 'Clé',
                border: InputBorder.none,
              ),
              onChanged: (newKey) {
                if (newKey != key) {
                  setState(() {
                    final value = _metadata[key];
                    _metadata.remove(key);
                    _metadata[newKey] = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: _metadata[key].toString(),
              decoration: const InputDecoration(
                labelText: 'Valeur',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _metadata[key] = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _metadata.remove(key);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveArchive,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
          child: Text(
            widget.archive == null ? 'Créer l\'archive' : 'Enregistrer',
          ),
        ),
      ],
    );
  }

  void _addMetadata() {
    setState(() {
      int counter = _metadata.length + 1;
      String key = 'Champ $counter';
      while (_metadata.containsKey(key)) {
        counter++;
        key = 'Champ $counter';
      }
      _metadata[key] = '';
    });
  }

  void _saveArchive() {
    if (_formKey.currentState!.validate()) {
      // Créer un objet Archive à partir des données du formulaire
      final archiveData = Archive(
        id: widget.archive?.id ??
            DateTime.now().toString(), // Générer un nouvel ID si création
        reference: _referenceController.text,
        description: _descriptionController.text,
        location: _selectedLocation,
        dua: _selectedDUA,
        createdAt: widget.archive?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.archive?.createdBy ??
            'Utilisateur actuel', // À remplacer par l'utilisateur réel
        status: _selectedStatus,
        metadata: _metadata,
        eliminationDate: _eliminationDate,
        transferDate: _transferDate,
        notes: _notesController.text,
      );

      Navigator.pop(context, archiveData);
    }
  }
}
