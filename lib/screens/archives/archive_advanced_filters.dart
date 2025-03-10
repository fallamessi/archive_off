// lib/screens/archives/archive_advanced_filters.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArchiveAdvancedFilters extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const ArchiveAdvancedFilters({
    Key? key,
    this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _ArchiveAdvancedFiltersState createState() => _ArchiveAdvancedFiltersState();
}

class _ArchiveAdvancedFiltersState extends State<ArchiveAdvancedFilters> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _yearRange = const RangeValues(2020, 2024);
  RangeValues _duaRange = const RangeValues(1, 10);
  List<String> _selectedTypes = [];
  List<String> _selectedFormats = [];
  String? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    if (widget.currentFilters != null) {
      setState(() {
        _searchController.text = widget.currentFilters!['search'] ?? '';
        _yearRange = widget.currentFilters!['yearRange'] ??
            const RangeValues(2020, 2024);
        _duaRange =
            widget.currentFilters!['duaRange'] ?? const RangeValues(1, 10);
        _selectedTypes = widget.currentFilters!['types'] ?? [];
        _selectedFormats = widget.currentFilters!['formats'] ?? [];
        _selectedStatus = widget.currentFilters!['status'];
        _dateRange = widget.currentFilters!['dateRange'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres avancés',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recherche
          _buildSearchField(),
          const SizedBox(height: 24),

          // Période
          _buildDateRangeFilter(),
          const SizedBox(height: 24),

          // Plage d'années
          _buildYearRangeFilter(),
          const SizedBox(height: 24),

          // DUA
          _buildDUARangeFilter(),
          const SizedBox(height: 24),

          // Types de documents
          _buildTypesFilter(),
          const SizedBox(height: 24),

          // Formats
          _buildFormatsFilter(),
          const SizedBox(height: 24),

          // Statut
          _buildStatusFilter(),
          const SizedBox(height: 32),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recherche textuelle',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher dans le contenu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Période de création',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  _dateRange == null
                      ? 'Sélectionner une période'
                      : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                  style: TextStyle(
                    color: _dateRange == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plage d\'années',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _yearRange,
          min: 2000,
          max: 2024,
          divisions: 24,
          labels: RangeLabels(
            _yearRange.start.round().toString(),
            _yearRange.end.round().toString(),
          ),
          onChanged: (values) {
            setState(() {
              _yearRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '2000',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '2024',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDUARangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée d\'utilité administrative (DUA)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          values: _duaRange,
          min: 1,
          max: 10,
          divisions: 9,
          labels: RangeLabels(
            '${_duaRange.start.round()} ans',
            '${_duaRange.end.round()} ans',
          ),
          onChanged: (values) {
            setState(() {
              _duaRange = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTypesFilter() {
    final types = [
      'Document administratif',
      'Rapport',
      'Note de service',
      'Correspondance',
      'Contrat',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Types de documents',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = _selectedTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFormatsFilter() {
    final formats = ['A4', 'A3', 'Lettre', 'Légal', 'Personnalisé'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formats',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            final isSelected = _selectedFormats.contains(format);
            return FilterChip(
              label: Text(format),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFormats.add(format);
                  } else {
                    _selectedFormats.remove(format);
                  }
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['En cours', 'À valider', 'Validé', 'Archivé'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: statuses.map((status) {
              final isSelected = _selectedStatus == status;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = isSelected ? null : status;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _yearRange = const RangeValues(2020, 2024);
      _duaRange = const RangeValues(1, 10);
      _selectedTypes = [];
      _selectedFormats = [];
      _selectedStatus = null;
      _dateRange = null;
    });
  }

  void _applyFilters() {
    final filters = {
      'search': _searchController.text,
      'yearRange': _yearRange,
      'duaRange': _duaRange,
      'types': _selectedTypes,
      'formats': _selectedFormats,
      'status': _selectedStatus,
      'dateRange': _dateRange,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}
