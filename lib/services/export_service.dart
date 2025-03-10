// lib/services/export_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

enum ExportFormat { pdf, excel, csv }

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<void> exportData({
    required List<Map<String, dynamic>> data,
    required String title,
    required ExportFormat format,
    Map<String, bool>? columns,
    required BuildContext context,
  }) async {
    try {
      final filename = _generateFilename(title, format);
      List<int> fileData;

      switch (format) {
        case ExportFormat.pdf:
          fileData = await _generatePDF(data, title, columns);
          break;
        case ExportFormat.excel:
          fileData = await _generateExcel(data, title, columns);
          break;
        case ExportFormat.csv:
          fileData = await _generateCSV(data, title, columns);
          break;
      }

      await _saveFile(fileData, filename);
      _showSuccessNotification(
          'Exportation réussie', 'Le fichier a été exporté avec succès.');
    } catch (e) {
      _showErrorNotification('Erreur lors de l\'exportation',
          'Une erreur est survenue lors de l\'exportation: ${e.toString()}');
      rethrow;
    }
  }

  String _generateFilename(String title, ExportFormat format) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedTitle = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    switch (format) {
      case ExportFormat.pdf:
        return '${sanitizedTitle}_$timestamp.pdf';
      case ExportFormat.excel:
        return '${sanitizedTitle}_$timestamp.xlsx';
      case ExportFormat.csv:
        return '${sanitizedTitle}_$timestamp.csv';
    }
  }

  Future<List<int>> _generatePDF(
    List<Map<String, dynamic>> data,
    String title,
    Map<String, bool>? columns,
  ) async {
    try {
      // Logique de génération PDF
      // Vous pouvez utiliser des packages comme pdf, printing, etc.
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la génération du PDF: ${e.toString()}');
    }
  }

  Future<List<int>> _generateExcel(
    List<Map<String, dynamic>> data,
    String title,
    Map<String, bool>? columns,
  ) async {
    try {
      // Logique de génération Excel
      // Vous pouvez utiliser des packages comme excel, spreadsheet_decoder, etc.
      return [];
    } catch (e) {
      throw Exception(
          'Erreur lors de la génération du fichier Excel: ${e.toString()}');
    }
  }

  Future<List<int>> _generateCSV(
    List<Map<String, dynamic>> data,
    String title,
    Map<String, bool>? columns,
  ) async {
    try {
      // Logique de génération CSV
      final buffer = StringBuffer();

      // En-têtes
      final headers = columns?.keys.where((key) => columns[key] ?? false) ??
          data.first.keys;
      buffer.writeln(headers.join(','));

      // Données
      for (var row in data) {
        final values = headers.map((header) => row[header]?.toString() ?? '');
        buffer.writeln(values.join(','));
      }

      return utf8.encode(buffer.toString());
    } catch (e) {
      throw Exception(
          'Erreur lors de la génération du fichier CSV: ${e.toString()}');
    }
  }

  Future<void> _saveFile(List<int> bytes, String filename) async {
    try {
      // Logique de sauvegarde du fichier
      // Utilisez file_picker ou file_saver pour sauvegarder sur Windows
    } catch (e) {
      throw Exception(
          'Erreur lors de la sauvegarde du fichier: ${e.toString()}');
    }
  }

  void _showSuccessNotification(String title, String message) {
    NotificationService().showSuccess(
      title: title,
      message: message,
    );
  }

  void _showErrorNotification(String title, String message) {
    NotificationService().showError(
      title: title,
      message: message,
    );
  }
}

class ExportDialog extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Map<String, String>? columnLabels;

  const ExportDialog({
    Key? key,
    required this.data,
    required this.title,
    this.columnLabels,
  }) : super(key: key);

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  final Map<String, bool> _selectedColumns = {};
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) {
      for (var key in widget.data.first.keys) {
        _selectedColumns[key] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFormatSelection(),
            const SizedBox(height: 24),
            _buildColumnSelection(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Exporter les données',
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
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format d\'export',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: ExportFormat.values.map((format) {
            return ChoiceChip(
              label: Text(_getFormatLabel(format)),
              selected: _selectedFormat == format,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFormat = format);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColumnSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Colonnes à exporter',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  for (var key in _selectedColumns.keys) {
                    _selectedColumns[key] = !_selectAll;
                  }
                  _selectAll = !_selectAll;
                });
              },
              icon: Icon(_selectAll ? Icons.clear_all : Icons.select_all),
              label: Text(
                  _selectAll ? 'Tout désélectionner' : 'Tout sélectionner'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            children: _selectedColumns.keys.map((key) {
              return CheckboxListTile(
                title: Text(widget.columnLabels?[key] ?? key),
                value: _selectedColumns[key],
                onChanged: (value) {
                  setState(() => _selectedColumns[key] = value ?? false);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _export,
          icon: const Icon(Icons.download),
          label: const Text('Exporter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  String _getFormatLabel(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.csv:
        return 'CSV';
    }
  }

  void _export() async {
    try {
      await ExportService().exportData(
        data: widget.data,
        title: widget.title,
        format: _selectedFormat,
        columns: _selectedColumns,
        context: context,
      );
      Navigator.pop(context, true);
    } catch (e) {
      // L'erreur est déjà gérée par le service
      Navigator.pop(context, false);
    }
  }
}
