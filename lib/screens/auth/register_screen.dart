// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Contrôleurs pour les champs de base
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _dateNaissance;
  String _nationalite = 'Guinéenne';
  PlatformFile? _pieceIdentiteRecto;
  PlatformFile? _pieceIdentiteVerso;
  String _typeUtilisateur = 'Etudiant';
  bool _acceptTerms = false;

  // Contrôleurs pour les champs spécifiques
  final _etablissementController = TextEditingController();
  final _niveauEtudesController = TextEditingController();
  final _institutionController = TextEditingController();
  final _directionController = TextEditingController();
  final _posteController = TextEditingController();
  final _ministereController = TextEditingController();
  final _entrepriseController = TextEditingController();
  final _secteurActiviteController = TextEditingController();
  PlatformFile? _rccmAgrement;
  final _professionController = TextEditingController();

  // Liste des nationalités (à compléter)
  final List<String> _nationalites = [
    'Guinéenne',
    'Malienne',
    'Sénégalaise',
    'Ivoirienne',
    // Ajouter d'autres nationalités...
  ];

  // Types d'utilisateurs
  final List<String> _typesUtilisateur = [
    'Etudiant',
    'Chercheur',
    'Agent de l\'État',
    'Entreprise/ONG',
    'Particulier',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Section gauche avec image et texte
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Bienvenue aux Archives\nNationales de Guinée',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Créez votre compte pour accéder à notre patrimoine documentaire.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section droite avec formulaire (50% de l'écran)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: _buildStepper(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Créer un compte',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour à la connexion'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Veuillez remplir le formulaire avec vos informations.',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      height: MediaQuery.of(context).size.height - 200, // Hauteur fixe
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _handleStepContinue,
        onStepCancel: _handleStepCancel,
        type: StepperType.horizontal,
        steps: [
          Step(
            title: const Text('Informations de base'),
            content: _buildBasicInfoStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Informations spécifiques'),
            content: _buildSpecificInfoStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Validation'),
            content: _buildValidationStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nomController,
                label: 'Nom',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _prenomController,
                label: 'Prénom',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le prénom est requis';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _telephoneController,
                label: 'Numéro de téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le numéro de téléphone est requis';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Nationalité',
          value: _nationalite,
          items: _nationalites,
          onChanged: (value) {
            setState(() {
              _nationalite = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Type d\'utilisateur',
          value: _typeUtilisateur,
          items: _typesUtilisateur,
          onChanged: (value) {
            setState(() {
              _typeUtilisateur = value!;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildDocumentUpload(
          label: 'Pièce d\'identité (Recto)',
          file: _pieceIdentiteRecto,
          onUpload: () async {
            final result = await _pickFile();
            if (result != null) {
              setState(() {
                _pieceIdentiteRecto = result;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _buildDocumentUpload(
          label: 'Pièce d\'identité (Verso)',
          file: _pieceIdentiteVerso,
          onUpload: () async {
            final result = await _pickFile();
            if (result != null) {
              setState(() {
                _pieceIdentiteVerso = result;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpecificInfoStep() {
    // Afficher les champs en fonction du type d'utilisateur
    switch (_typeUtilisateur) {
      case 'Etudiant':
        return _buildStudentFields();
      case 'Chercheur':
        return _buildResearcherFields();
      case 'Agent de l\'État':
        return _buildStateAgentFields();
      case 'Entreprise/ONG':
        return _buildCompanyFields();
      case 'Particulier':
        return _buildIndividualFields();
      default:
        return Container();
    }
  }

  Widget _buildStudentFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _etablissementController,
          label: 'Établissement',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'L\'établissement est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _niveauEtudesController,
          label: 'Niveau d\'études',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le niveau d\'études est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResearcherFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _institutionController,
          label: 'Institution/Centre de recherche',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'L\'institution est requise';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStateAgentFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _directionController,
          label: 'Direction',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'La direction est requise';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _posteController,
          label: 'Poste',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le poste est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _ministereController,
          label: 'Ministère de tutelle',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le ministère est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCompanyFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _entrepriseController,
          label: 'Nom de l\'entreprise',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le nom de l\'entreprise est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _secteurActiviteController,
          label: 'Secteur d\'activité',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le secteur d\'activité est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildDocumentUpload(
          label: 'RCCM ou Agrément',
          file: _rccmAgrement,
          onUpload: () async {
            final result = await _pickFile();
            if (result != null) {
              setState(() {
                _rccmAgrement = result;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildIndividualFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _professionController,
          label: 'Profession',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'La profession est requise';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _secteurActiviteController,
          label: 'Secteur d\'activité',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le secteur d\'activité est requis';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildValidationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'L\'email est requis';
            }
            if (!value!.contains('@')) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Le mot de passe est requis';
            }
            if (value!.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        // Conditions d'utilisation
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'J\'accepte les ',
                  style: TextStyle(color: Colors.grey[600]),
                  children: [
                    TextSpan(
                      text: 'conditions d\'utilisation',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'politique de confidentialité',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateNaissance != null
                  ? '${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                  : 'Sélectionner une date',
              style: TextStyle(
                color: _dateNaissance != null ? Colors.black : Colors.grey[600],
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String label,
    required PlatformFile? file,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (file == null)
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choisir un fichier'),
            )
          else
            Row(
              children: [
                Icon(Icons.file_present, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      if (file == _pieceIdentiteRecto) {
                        _pieceIdentiteRecto = null;
                      } else if (file == _pieceIdentiteVerso) {
                        _pieceIdentiteVerso = null;
                      } else if (file == _rccmAgrement) {
                        _rccmAgrement = null;
                      }
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateNaissance) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }

  Future<PlatformFile?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        return result.files.first;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection du fichier'),
        ),
      );
    }
    return null;
  }

  void _handleStepContinue() {
    setState(() {
      if (_currentStep < 2) {
        _currentStep += 1;
      } else {
        _submitForm();
      }
    });
  }

  void _handleStepCancel() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep -= 1;
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez accepter les conditions d\'utilisation pour continuer'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Simulation d'une requête API
        await Future.delayed(const Duration(seconds: 2));

        // En cas de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Inscription réussie !',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Votre compte sera activé après validation par un administrateur.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'inscription: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _etablissementController.dispose();
    _niveauEtudesController.dispose();
    _institutionController.dispose();
    _directionController.dispose();
    _posteController.dispose();
    _ministereController.dispose();
    _entrepriseController.dispose();
    _secteurActiviteController.dispose();
    _professionController.dispose();
    super.dispose();
  }
}
