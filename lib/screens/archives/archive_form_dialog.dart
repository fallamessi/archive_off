// lib/screens/archives/archive_form_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArchiveFormDialog extends StatefulWidget {
  final Map<String, dynamic>? archiveData;

  const ArchiveFormDialog({
    Key? key,
    this.archiveData,
  }) : super(key: key);

  @override
  _ArchiveFormDialogState createState() => _ArchiveFormDialogState();
}

class _ArchiveFormDialogState extends State<ArchiveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _referenceController;
  late final TextEditingController _descriptionController;
  String _selectedLocation = 'Local A';
  int _selectedDUA = 5;
  String _selectedState = 'À conserver';

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.archiveData?['reference'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.archiveData?['description'] ?? '',
    );
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
            Row(
              children: [
                Text(
                  widget.archiveData == null
                      ? 'Nouvelle archive'
                      : 'Modifier l\'archive',
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
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                              _buildSection(
                                title: 'Informations générales',
                                children: [
                                  _buildTextField(
                                    controller: _referenceController,
                                    label: 'Référence',
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'La référence est requise';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _descriptionController,
                                    label: 'Description',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'Localisation',
                                children: [
                                  _buildDropdown(
                                    label: 'Emplacement',
                                    value: _selectedLocation,
                                    items: const [
                                      'Local A',
                                      'Local B',
                                      'Local C'
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedLocation = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Colonne droite
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSection(
                                title: 'Conservation',
                                children: [
                                  _buildDropdown(
                                    label: 'DUA (années)',
                                    value: _selectedDUA,
                                    items: List.generate(10, (i) => i + 1),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDUA = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdown(
                                    label: 'État',
                                    value: _selectedState,
                                    items: const [
                                      'À conserver',
                                      'À éliminer',
                                      'À verser'
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedState = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                title: 'Métadonnées',
                                children: [
                                  _buildMetadataFields(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
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
                            widget.archiveData == null
                                ? 'Créer l\'archive'
                                : 'Enregistrer les modifications',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
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
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildMetadataField(
            label: 'Type de document',
            value: 'Document administratif',
          ),
          _buildMetadataField(
            label: 'Format',
            value: 'A4',
          ),
          _buildMetadataField(
            label: 'Nombre de pages',
            value: '45',
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _saveArchive() {
    if (_formKey.currentState!.validate()) {
      // Sauvegarder les données
      final archiveData = {
        'reference': _referenceController.text,
        'description': _descriptionController.text,
        'location': _selectedLocation,
        'dua': _selectedDUA,
        'state': _selectedState,
      };
      Navigator.pop(context, archiveData);
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
