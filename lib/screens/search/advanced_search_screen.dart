// lib/screens/search/advanced_search_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrigin = 'Tous';
  String _selectedMinistere = '';
  String _selectedNature = '';
  String _selectedPeriode = '';
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _departementController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  DateTime? _selectedDate;

  final List<String> _origines = ['Tous', 'Ministère', 'Particulier'];

  final List<String> _ministeres = [
    'Ministère de la Justice et des Droits de l’Homme',
    'Ministère de la Défense Nationale',
    'Ministère de l’Enseignement Supérieur, de la Recherche Scientifique et de l’Innovation',
    'Ministère de l’Éducation Nationale et de l’Alphabétisation',
    'Ministère de la Santé et de l’Hygiène Publique',
    'Ministère des Affaires Étrangères, de l’Intégration Africaine et des Guinéens de l’Étranger',
    'Ministère de l’Économie, des Finances et du Plan',
    'Ministère de l’Agriculture et de l’Élevage',
    'Ministère des Mines et de la Géologie',
    'Ministère des Transports',
    'Ministère des Travaux Publics',
    'Ministère de l’Environnement et du Développement Durable',
    'Ministère de l’Énergie, de l’Hydraulique et des Hydrocarbures',
    'Ministère du Commerce, de l’Industrie et des PME',
    'Ministère des Postes, des Télécommunications et de l’Économie Numérique',
    'Ministère de l’Habitat, de l’Urbanisme et de l’Aménagement du Territoire',
    'Ministère de la Culture, du Tourisme et de l’Artisanat',
    'Ministère de la Fonction Publique, du Travail et de la Réforme de l’État',
    'Ministère de l’Administration du Territoire et de la Décentralisation',
    'Ministère de la Sécurité et de la Protection Civile',
    'Ministère des Pêches et de l’Économie Maritime',
    'Ministère de la Jeunesse et des Sports',
    'Ministère de la Communication',
    'Ministère de la Promotion Féminine, de l’Enfance et des Personnes Vulnérables',
    'Ministère des Investissements et des Partenariats Publics-Privés'
  ];

  final List<String> _natures = [
    'Correspondance administrative',
    'Décret',
    'Arrêté',
    'Note de service',
    'Rapport',
    'Procès-verbal',
    'Document historique',
    'Archive coloniale',
    'Document juridique',
    'Registre d\'état civil',
    'Plan architectural',
    'Photographie historique',
    'Carte géographique',
    'Manuscrit',
    'Document financier',
    'Journal officiel',
    'Dossier médical',
    'Contrat',
    'Acte notarié',
    'Livre ancien',
    'Carte postale',
    'Affiche ou publicité historique',
    'Enregistrement audio',
    'Film ou vidéo',
    'Revue ou périodique',
    'Requête ou pétition',
    'Décision ou ordonnance',
    'Bulletin officiel',
    'Tableau statistique'
  ];

  final List<String> _periodes = [
    'Période coloniale (avant 1958)',
    'Première République (1958-1984)',
    'Deuxième République (1984-2008)',
    'Troisième République (2008-2010)',
    'Quatrième République (2010-présent)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panneau des filtres
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: _buildSearchFilters(),
                ),
                // Zone de résultats
                Expanded(
                  child: _buildSearchResults(),
                ),
              ],
            ),
          ),
        ],
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 16),
              const Text(
                'Recherche Avancée',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _keywordController,
            decoration: InputDecoration(
              hintText: 'Rechercher par mot-clé...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilterSection(
            title: 'Origine',
            child: Column(
              children: _origines
                  .map(
                    (origine) => _buildRadioOption(
                      title: origine,
                      value: origine,
                      groupValue: _selectedOrigin,
                      onChanged: (value) {
                        setState(() => _selectedOrigin = value!);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_selectedOrigin == 'Ministère') ...[
            const SizedBox(height: 16),
            _buildFilterSection(
              title: 'Ministère',
              child: DropdownButtonFormField<String>(
                value: _selectedMinistere.isEmpty ? null : _selectedMinistere,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Sélectionnez un ministère'),
                items: _ministeres
                    .map(
                      (ministere) => DropdownMenuItem(
                        value: ministere,
                        child: Text(ministere),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedMinistere = value!);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterSection(
              title: 'Département/Service',
              child: TextFormField(
                controller: _departementController,
                decoration: InputDecoration(
                  hintText: 'Nom du département',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildFilterSection(
            title: 'Nature du document',
            child: DropdownButtonFormField<String>(
              value: _selectedNature.isEmpty ? null : _selectedNature,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Type de document'),
              items: _natures
                  .map(
                    (nature) => DropdownMenuItem(
                      value: nature,
                      child: Text(nature),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedNature = value!);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterSection(
            title: 'Référence',
            child: TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Numéro de référence',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterSection(
            title: 'Période historique',
            child: DropdownButtonFormField<String>(
              value: _selectedPeriode.isEmpty ? null : _selectedPeriode,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Sélectionnez une période'),
              items: _periodes
                  .map(
                    (periode) => DropdownMenuItem(
                      value: periode,
                      child: Text(periode),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPeriode = value!);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterSection(
            title: 'Date du document',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    hintText: 'Année',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today,
                        size: 20, color: Colors.white),
                    label: const Text('Sélectionner une date précise'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Date sélectionnée: ${_formatDate(_selectedDate!)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applySearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Rechercher'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Les résultats de recherche apparaîtront ici',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Utilisez les filtres à gauche pour affiner votre recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryBlue,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedOrigin = 'Tous';
      _selectedMinistere = '';
      _selectedNature = '';
      _selectedPeriode = '';
      _keywordController.clear();
      _referenceController.clear();
      _departementController.clear();
      _yearController.clear();
      _selectedDate = null;
    });
  }

  void _applySearch() {
    if (_formKey.currentState!.validate()) {
      final searchParams = {
        'keyword': _keywordController.text,
        'origin': _selectedOrigin,
        'ministere': _selectedMinistere,
        'departement': _departementController.text,
        'nature': _selectedNature,
        'reference': _referenceController.text,
        'periode': _selectedPeriode,
        'year': _yearController.text,
        'date': _selectedDate?.toIso8601String(),
      };
      if (kDebugMode) {
        print('Paramètres de recherche: $searchParams');
      }
      // Implémenter la logique de recherche ici
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _referenceController.dispose();
    _departementController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
