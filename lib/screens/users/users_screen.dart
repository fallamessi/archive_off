// lib/screens/users/users_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class User {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String departement;
  final bool isActive;
  final String type_utilisateur;
  final String? telephone;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.departement,
    required this.isActive,
    required this.type_utilisateur,
    this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Utilisateur',
      departement: json['departement'] ?? '',
      isActive: json['isActive'] ?? true,
      type_utilisateur: json['type_utilisateur'] ?? '',
      telephone: json['telephone'],
    );
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'Tous les rôles';
  String _selectedDepartment = 'Tous les services';
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);

      final response = await supabase
          .from('utilisateurs')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _users = (response as List).map((user) => User.fromJson(user)).toList();
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des utilisateurs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                _buildFilters(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildUsersList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
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
          const Text(
            'Gestion des utilisateurs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouvel utilisateur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          _buildFilterSection(
            title: 'Rôle',
            items: [
              'Tous les rôles',
              'Administrateur',
              'Archiviste',
              'Consultant',
              'Compte Client cloud'
            ],
            selectedValue: _selectedRole,
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
                _filterUsers(_searchController.text);
              });
            },
          ),
          _buildFilterSection(
            title: 'Service',
            items: [
              'Tous les services',
              'Direction générale',
              'Service technique',
              'Service administratif',
              'Compte Client cloud'
            ],
            selectedValue: _selectedDepartment,
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value!;
                _filterUsers(_searchController.text);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required String selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text('Aucun utilisateur trouvé'),
      );
    }

    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  '${user.nom[0]}${user.prenom[0]}'.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text('${user.nom} ${user.prenom}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  if (user.telephone != null) Text(user.telephone!),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(user.role, AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      _buildTag(user.type_utilisateur, AppTheme.accentGreen),
                      if (user.departement.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildTag(user.departement, Colors.orange),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Modifier'),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Text(
                      user.isActive ? 'Désactiver' : 'Activer',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesQuery = '${user.nom} ${user.prenom}'
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase());
        final matchesRole =
            _selectedRole == 'Tous les rôles' || user.role == _selectedRole;
        final matchesDepartment = _selectedDepartment == 'Tous les services' ||
            user.departement == _selectedDepartment;
        return matchesQuery && matchesRole && matchesDepartment;
      }).toList();
    });
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _showDeleteUserDialog(context, user);
        break;
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      await supabase
          .from('utilisateurs')
          .update({'isActive': !user.isActive}).eq('id', user.id);

      _loadUsers(); // Recharger la liste des utilisateurs

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut de l\'utilisateur mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous vraiment supprimer l\'utilisateur ${user.nom} ${user.prenom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await supabase.from('utilisateurs').delete().eq('id', user.id);

                _loadUsers(); // Recharger la liste
                Navigator.pop(context);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController();
    final _prenomController = TextEditingController();
    final _emailController = TextEditingController();
    final _telephoneController = TextEditingController();
    String _role = 'Utilisateur';
    String _typeUtilisateur = 'Etudiant';
    String _departement = 'Service technique';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un utilisateur'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le prénom';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Utilisateur', child: Text('Utilisateur')),
                    DropdownMenuItem(
                        value: 'Administrateur', child: Text('Administrateur')),
                    DropdownMenuItem(
                        value: 'Archiviste', child: Text('Archiviste')),
                    DropdownMenuItem(
                        value: 'Restaurateur', child: Text('Restaurateur')),
                  ],
                  onChanged: (value) => _role = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _typeUtilisateur,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Etudiant', child: Text('Etudiant')),
                    DropdownMenuItem(
                        value: 'Chercheur', child: Text('Chercheur')),
                    DropdownMenuItem(
                        value: 'Agent de l\'État',
                        child: Text('Agent de l\'État')),
                    DropdownMenuItem(
                        value: 'Entreprise/ONG', child: Text('Entreprise/ONG')),
                    DropdownMenuItem(
                        value: 'Particulier', child: Text('Particulier')),
                  ],
                  onChanged: (value) => _typeUtilisateur = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _departement,
                  decoration: const InputDecoration(
                    labelText: 'Département',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Service technique',
                        child: Text('Service technique')),
                    DropdownMenuItem(
                        value: 'Direction générale',
                        child: Text('Direction générale')),
                    DropdownMenuItem(
                        value: 'Service administratif',
                        child: Text('Service administratif')),
                  ],
                  onChanged: (value) => _departement = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  // Créer l'utilisateur dans auth
                  final authResponse = await supabase.auth.signUp(
                    email: _emailController.text,
                    password:
                        'TemporaryPassword123!', // Mot de passe temporaire
                  );

                  if (authResponse.user != null) {
                    // Ajouter l'utilisateur dans la table utilisateurs
                    await supabase.from('utilisateurs').insert({
                      'auth_user_id': authResponse.user!.id,
                      'nom': _nomController.text,
                      'prenom': _prenomController.text,
                      'email': _emailController.text,
                      'telephone': _telephoneController.text,
                      'role': _role,
                      'type_utilisateur': _typeUtilisateur,
                      'departement': _departement,
                      'isActive': true,
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Utilisateur ajouté avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadUsers(); // Recharger la liste
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'ajout: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController(text: user.nom);
    final _prenomController = TextEditingController(text: user.prenom);
    final _emailController = TextEditingController(text: user.email);
    final _telephoneController = TextEditingController(text: user.telephone);
    String _role = user.role;
    String _typeUtilisateur = user.type_utilisateur;
    String _departement = user.departement;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le prénom';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Utilisateur', child: Text('Utilisateur')),
                    DropdownMenuItem(
                        value: 'Administrateur', child: Text('Administrateur')),
                    DropdownMenuItem(
                        value: 'Archiviste', child: Text('Archiviste')),
                    DropdownMenuItem(
                        value: 'Restaurateur', child: Text('Restaurateur')),
                  ],
                  onChanged: (value) => _role = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _typeUtilisateur,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Utilisateur systeme',
                        child: Text('Utilisateur systeme')),
                    DropdownMenuItem(
                        value: 'Etudiant', child: Text('Etudiant')),
                    DropdownMenuItem(
                        value: 'Chercheur', child: Text('Chercheur')),
                    DropdownMenuItem(
                        value: 'Agent de l\'État',
                        child: Text('Agent de l\'État')),
                    DropdownMenuItem(
                        value: 'Entreprise/ONG', child: Text('Entreprise/ONG')),
                    DropdownMenuItem(
                        value: 'Particulier', child: Text('Particulier')),
                  ],
                  onChanged: (value) => _typeUtilisateur = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _departement,
                  decoration: const InputDecoration(
                    labelText: 'Département',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Service technique',
                        child: Text('Service technique')),
                    DropdownMenuItem(
                        value: 'Direction générale',
                        child: Text('Direction générale')),
                    DropdownMenuItem(
                        value: 'Service administratif',
                        child: Text('Service administratif')),
                  ],
                  onChanged: (value) => _departement = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await supabase.from('utilisateurs').update({
                    'nom': _nomController.text,
                    'prenom': _prenomController.text,
                    'email': _emailController.text,
                    'telephone': _telephoneController.text,
                    'role': _role,
                    'type_utilisateur': _typeUtilisateur,
                    'departement': _departement,
                  }).eq('id', user.id);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Utilisateur modifié avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadUsers(); // Recharger la liste
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de la modification: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
