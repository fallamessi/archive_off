// lib/widgets/archive_widgets/location_dialogs.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AddLocalDialog extends StatefulWidget {
  final List<String> existingLocals;

  const AddLocalDialog({
    Key? key,
    required this.existingLocals,
  }) : super(key: key);

  @override
  State<AddLocalDialog> createState() => _AddLocalDialogState();
}

class _AddLocalDialogState extends State<AddLocalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasHumidityControl = false;
  bool _hasTemperatureControl = false;
  String _securityLevel = 'Normal';

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Ajouter un nouveau local',
                  style: TextStyle(
                    fontSize: 20,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du local',
                      hintText: 'Ex: Local A',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom du local est requis';
                      }
                      if (widget.existingLocals.contains(value)) {
                        return 'Ce nom de local existe déjà';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Description du local et de son usage',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureSwitch(
                          'Contrôle humidité',
                          _hasHumidityControl,
                          (value) {
                            setState(() {
                              _hasHumidityControl = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureSwitch(
                          'Contrôle température',
                          _hasTemperatureControl,
                          (value) {
                            setState(() {
                              _hasTemperatureControl = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _securityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de sécurité',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Normal',
                        child: Text('Normal'),
                      ),
                      DropdownMenuItem(
                        value: 'Restreint',
                        child: Text('Restreint'),
                      ),
                      DropdownMenuItem(
                        value: 'Haute sécurité',
                        child: Text('Haute sécurité'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _securityLevel = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitLocal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  void _submitLocal() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'hasHumidityControl': _hasHumidityControl,
        'hasTemperatureControl': _hasTemperatureControl,
        'securityLevel': _securityLevel,
      });
    }
  }
}

class AddEtagereDialog extends StatefulWidget {
  final String local;
  final List<String> existingEtageres;

  const AddEtagereDialog({
    Key? key,
    required this.local,
    required this.existingEtageres,
  }) : super(key: key);

  @override
  State<AddEtagereDialog> createState() => _AddEtagereDialogState();
}

class _AddEtagereDialogState extends State<AddEtagereDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  int _capacite = 100;
  int _nombrePositions = 4;
  String _type = 'Standard';

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter une étagère',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Local: ${widget.local}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'étagère',
                      hintText: 'Ex: Étagère 1',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom de l\'étagère est requis';
                      }
                      if (widget.existingEtageres.contains(value)) {
                        return 'Ce nom d\'étagère existe déjà dans ce local';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'étagère',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Standard',
                        child: Text('Standard'),
                      ),
                      DropdownMenuItem(
                        value: 'Grande capacité',
                        child: Text('Grande capacité'),
                      ),
                      DropdownMenuItem(
                        value: 'Sécurisée',
                        child: Text('Sécurisée'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capacité totale: $_capacite',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _capacite.toDouble(),
                              min: 50,
                              max: 200,
                              divisions: 15,
                              label: _capacite.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _capacite = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre de positions: $_nombrePositions',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _nombrePositions.toDouble(),
                              min: 2,
                              max: 8,
                              divisions: 6,
                              label: _nombrePositions.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _nombrePositions = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitEtagere,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                        child: const Text('Ajouter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitEtagere() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nom': _nomController.text,
        'type': _type,
        'capacite': _capacite,
        'nombrePositions': _nombrePositions,
      });
    }
  }
}

/// Dialog de confirmation de suppression
class DeleteLocationDialog extends StatelessWidget {
  final String type; // 'local' ou 'etagere'
  final String nom;
  final int archivesCount;

  const DeleteLocationDialog({
    Key? key,
    required this.type,
    required this.nom,
    required this.archivesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasArchives = archivesCount > 0;

    return AlertDialog(
      title: Text('Supprimer ${type == 'local' ? 'le local' : 'l\'étagère'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Êtes-vous sûr de vouloir supprimer $nom ?',
          ),
          if (hasArchives) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.accentRed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cet emplacement contient $archivesCount archives. '
                      'Vous devez d\'abord les déplacer avant de pouvoir le supprimer.',
                      style: TextStyle(
                        color: AppTheme.accentRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: hasArchives ? null : () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentRed,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}

class EditLocalDialog extends StatefulWidget {
  final String nom;
  final String description;
  final bool hasHumidityControl;
  final bool hasTemperatureControl;
  final String securityLevel;
  final List<String> existingLocals;

  const EditLocalDialog({
    Key? key,
    required this.nom,
    required this.description,
    required this.hasHumidityControl,
    required this.hasTemperatureControl,
    required this.securityLevel,
    required this.existingLocals,
  }) : super(key: key);

  @override
  State<EditLocalDialog> createState() => _EditLocalDialogState();
}

class _EditLocalDialogState extends State<EditLocalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late bool _hasHumidityControl;
  late bool _hasTemperatureControl;
  late String _securityLevel;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nom);
    _descriptionController = TextEditingController(text: widget.description);
    _hasHumidityControl = widget.hasHumidityControl;
    _hasTemperatureControl = widget.hasTemperatureControl;
    _securityLevel = widget.securityLevel;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Modifier le local',
                  style: TextStyle(
                    fontSize: 20,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du local',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom du local est requis';
                      }
                      if (value != widget.nom &&
                          widget.existingLocals.contains(value)) {
                        return 'Ce nom de local existe déjà';
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
                  const SizedBox(height: 24),
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureSwitch(
                          'Contrôle humidité',
                          _hasHumidityControl,
                          (value) {
                            setState(() {
                              _hasHumidityControl = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureSwitch(
                          'Contrôle température',
                          _hasTemperatureControl,
                          (value) {
                            setState(() {
                              _hasTemperatureControl = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _securityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de sécurité',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Normal',
                        child: Text('Normal'),
                      ),
                      DropdownMenuItem(
                        value: 'Restreint',
                        child: Text('Restreint'),
                      ),
                      DropdownMenuItem(
                        value: 'Haute sécurité',
                        child: Text('Haute sécurité'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _securityLevel = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  void _submitChanges() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nom': _nomController.text,
        'description': _descriptionController.text,
        'hasHumidityControl': _hasHumidityControl,
        'hasTemperatureControl': _hasTemperatureControl,
        'securityLevel': _securityLevel,
      });
    }
  }
}

class EditEtagereDialog extends StatefulWidget {
  final String nom;
  final String type;
  final int capacite;
  final int nombrePositions;
  final List<String> existingEtageres;

  const EditEtagereDialog({
    Key? key,
    required this.nom,
    required this.type,
    required this.capacite,
    required this.nombrePositions,
    required this.existingEtageres,
  }) : super(key: key);

  @override
  State<EditEtagereDialog> createState() => _EditEtagereDialogState();
}

class _EditEtagereDialogState extends State<EditEtagereDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late String _type;
  late int _capacite;
  late int _nombrePositions;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nom);
    _type = widget.type;
    _capacite = widget.capacite;
    _nombrePositions = widget.nombrePositions;
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Modifier l\'étagère',
                  style: TextStyle(
                    fontSize: 20,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'étagère',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom de l\'étagère est requis';
                      }
                      if (value != widget.nom &&
                          widget.existingEtageres.contains(value)) {
                        return 'Ce nom d\'étagère existe déjà dans ce local';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'étagère',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Standard',
                        child: Text('Standard'),
                      ),
                      DropdownMenuItem(
                        value: 'Grande capacité',
                        child: Text('Grande capacité'),
                      ),
                      DropdownMenuItem(
                        value: 'Sécurisée',
                        child: Text('Sécurisée'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capacité totale: $_capacite',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _capacite.toDouble(),
                              min: 50,
                              max: 200,
                              divisions: 15,
                              label: _capacite.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _capacite = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre de positions: $_nombrePositions',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _nombrePositions.toDouble(),
                              min: 2,
                              max: 8,
                              divisions: 6,
                              label: _nombrePositions.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _nombrePositions = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _submitChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitChanges() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'nom': _nomController.text,
        'type': _type,
        'capacite': _capacite,
        'nombrePositions': _nombrePositions,
      });
    }
  }
}
