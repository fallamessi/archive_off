// lib/widgets/document_widgets/document_filters.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DocumentFilters extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const DocumentFilters({
    Key? key,
    this.initialFilters = const {},
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<DocumentFilters> createState() => _DocumentFiltersState();
}

class _DocumentFiltersState extends State<DocumentFilters> {
  late Map<String, dynamic> _filters;
  final TextEditingController _searchController = TextEditingController();
  final DateTimeRange _defaultDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
    _searchController.text = _filters['search'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  _buildDateFilter(),
                  const SizedBox(height: 24),
                  _buildTypeFilter(),
                  const SizedBox(height: 24),
                  _buildStatusFilter(),
                  const SizedBox(height: 24),
                  _buildServiceFilter(),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filtres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        _filters['search'] = value;
        widget.onFiltersChanged(_filters);
      },
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Période',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDateRangePicker(),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    final DateTimeRange dateRange = _filters['dateRange'] ?? _defaultDateRange;
    return InkWell(
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
            Expanded(
              child: Text(
                '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de document',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('Document administratif'),
            _buildFilterChip('Rapport'),
            _buildFilterChip('Note de service'),
            _buildFilterChip('Correspondance'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('Validé', color: AppTheme.accentGreen),
            _buildFilterChip('En attente', color: AppTheme.accentYellow),
            _buildFilterChip('Rejeté', color: AppTheme.accentRed),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildServiceItem('Direction générale'),
            _buildServiceItem('Service technique'),
            _buildServiceItem('Service administratif'),
            _buildServiceItem('Service financier'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {Color? color}) {
    final isSelected = (_filters['selected_filters'] ?? []).contains(label);
    final displayColor = color ?? AppTheme.primaryBlue;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          final selectedFilters =
              List<String>.from(_filters['selected_filters'] ?? []);
          if (selected) {
            selectedFilters.add(label);
          } else {
            selectedFilters.remove(label);
          }
          _filters['selected_filters'] = selectedFilters;
          widget.onFiltersChanged(_filters);
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: displayColor.withOpacity(0.1),
      checkmarkColor: displayColor,
      labelStyle: TextStyle(
        color: isSelected ? displayColor : Colors.grey[700],
      ),
    );
  }

  Widget _buildServiceItem(String service) {
    final isSelected = (_filters['selected_services'] ?? []).contains(service);

    return CheckboxListTile(
      title: Text(service),
      value: isSelected,
      onChanged: (selected) {
        setState(() {
          final selectedServices =
              List<String>.from(_filters['selected_services'] ?? []);
          if (selected ?? false) {
            selectedServices.add(service);
          } else {
            selectedServices.remove(service);
          }
          _filters['selected_services'] = selectedServices;
          widget.onFiltersChanged(_filters);
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          widget.onFiltersChanged(_filters);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 0),
          foregroundColor: Colors.white, // Texte en blanc
        ),
        child: const Text(
          'Appliquer les filtres',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _filters['dateRange'] ?? _defaultDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filters['dateRange'] = picked;
        widget.onFiltersChanged(_filters);
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _filters.clear();
      _searchController.clear();
      widget.onFiltersChanged(_filters);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Widget complémentaire pour afficher les filtres actifs
class ActiveFilters extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Function(String) onRemoveFilter;

  const ActiveFilters({
    Key? key,
    required this.filters,
    required this.onRemoveFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> filterChips = [];

    // Ajouter le filtre de recherche s'il existe
    if (filters['search']?.isNotEmpty ?? false) {
      filterChips.add(_buildFilterChip(
        'Recherche: ${filters['search']}',
        'search',
      ));
    }

    // Ajouter les filtres de type
    final selectedFilters = filters['selected_filters'] ?? [];
    for (var filter in selectedFilters) {
      filterChips.add(_buildFilterChip(filter, filter));
    }

    // Ajouter les filtres de service
    final selectedServices = filters['selected_services'] ?? [];
    for (var service in selectedServices) {
      filterChips.add(_buildFilterChip(
        'Service: $service',
        'service:$service',
      ));
    }

    // Ajouter le filtre de date s'il existe
    final dateRange = filters['dateRange'];
    if (dateRange != null) {
      filterChips.add(_buildFilterChip(
        'Période: ${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
        'dateRange',
      ));
    }

    if (filterChips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filterChips,
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => onRemoveFilter(key),
      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
      deleteIconColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(color: AppTheme.primaryBlue),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
