// lib/widgets/archive_widgets/location_picker.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LocationPicker extends StatefulWidget {
  final String? currentLocation;
  final Function(String) onLocationSelected;

  const LocationPicker({
    Key? key,
    this.currentLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? _selectedLocal;
  String? _selectedEtagere;
  String? _selectedPosition;

  // Ces données devraient venir d'une API ou d'une base de données
  final Map<String, List<String>> _localEtageres = {
    'Local A': ['Étagère 1', 'Étagère 2', 'Étagère 3'],
    'Local B': ['Étagère 1', 'Étagère 2', 'Étagère 3'],
    'Local C': ['Étagère 1', 'Étagère 2'],
  };

  final Map<String, List<String>> _etagerePositions = {
    'Étagère 1': ['Position 1', 'Position 2', 'Position 3', 'Position 4'],
    'Étagère 2': ['Position 1', 'Position 2', 'Position 3', 'Position 4'],
    'Étagère 3': ['Position 1', 'Position 2', 'Position 3', 'Position 4'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      final parts = widget.currentLocation!.split(' - ');
      if (parts.length >= 1) _selectedLocal = parts[0];
      if (parts.length >= 2) _selectedEtagere = parts[1];
      if (parts.length >= 3) _selectedPosition = parts[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sélection du local
        DropdownButtonFormField<String>(
          value: _selectedLocal,
          decoration: InputDecoration(
            labelText: 'Local',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _localEtageres.keys.map((local) {
            return DropdownMenuItem(
              value: local,
              child: Text(local),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocal = value;
              _selectedEtagere = null;
              _selectedPosition = null;
              _updateSelectedLocation();
            });
          },
        ),
        const SizedBox(height: 16),

        // Sélection de l'étagère
        if (_selectedLocal != null) ...[
          DropdownButtonFormField<String>(
            value: _selectedEtagere,
            decoration: InputDecoration(
              labelText: 'Étagère',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _localEtageres[_selectedLocal]!.map((etagere) {
              return DropdownMenuItem(
                value: etagere,
                child: Text(etagere),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEtagere = value;
                _selectedPosition = null;
                _updateSelectedLocation();
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Sélection de la position
        if (_selectedEtagere != null) ...[
          DropdownButtonFormField<String>(
            value: _selectedPosition,
            decoration: InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: _etagerePositions[_selectedEtagere]!.map((position) {
              return DropdownMenuItem(
                value: position,
                child: Text(position),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPosition = value;
                _updateSelectedLocation();
              });
            },
          ),
        ],

        // Visualisation de l'emplacement
        if (_selectedLocal != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emplacement sélectionné',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFullLocation(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getFullLocation() {
    final List<String> parts = [];
    if (_selectedLocal != null) parts.add(_selectedLocal!);
    if (_selectedEtagere != null) parts.add(_selectedEtagere!);
    if (_selectedPosition != null) parts.add(_selectedPosition!);
    return parts.join(' - ');
  }

  void _updateSelectedLocation() {
    if (_selectedLocal != null) {
      widget.onLocationSelected(_getFullLocation());
    }
  }
}
