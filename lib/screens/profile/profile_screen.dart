import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  String _calculateBMI(double weight, double height) {
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    return bmi.toStringAsFixed(1);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
      // TODO: Save image path to database
    }
  }

  Future<void> _logout() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearCurrentUser();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement du profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('No profile found'));
    }

    // Calculate BMI if weight and height are available
    String? bmiText;
    String? bmiCategory;
    if (_user!.weight != null && _user!.height != null) {
      final bmi = double.parse(_calculateBMI(_user!.weight!, _user!.height!));
      bmiText = bmi.toStringAsFixed(1);
      bmiCategory = _getBMICategory(bmi);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child:
                      _profileImagePath == null
                          ? Text(
                            _user!.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(_user!.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_user!.email, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Informations personnelles',
            items: [
              _buildInfoItem(
                Icons.height,
                'Taille',
                '${_user?.height ?? 0} cm',
              ),
              _buildInfoItem(
                Icons.monitor_weight,
                'Poids',
                '${_user?.weight ?? 0} kg',
              ),
              _buildInfoItem(Icons.cake, 'Âge', '${_user?.age ?? 0} ans'),
              _buildInfoItem(
                Icons.person_outline,
                'Genre',
                _user?.gender ?? 'Non spécifié',
              ),
            ],
          ),
          if (bmiText != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indice de masse corporelle (IMC)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMC',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              bmiText,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Catégorie',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              bmiCategory!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: _user!),
                ),
              );

              if (result == true) {
                _loadUserProfile(); // Refresh profile after editing
              }
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
    );
  }
}
