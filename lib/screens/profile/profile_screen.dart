import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../services/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_profile_screen.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(databaseHelper: DatabaseHelper())..add(LoadProfile()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _ProfileContent(user: state.user);
          } else if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _profileImagePath = widget.user.profileImagePath;
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

    if (image != null && mounted) {
      setState(() {
        _profileImagePath = image.path;
      });

      // Save image path to database
      final dbHelper = DatabaseHelper();
      await dbHelper.saveProfileImage(widget.user.id!, image.path);

      // Refresh profile
      if (mounted) {
        context.read<ProfileBloc>().add(LoadProfile());
      }
    }
  }

  Future<void> _logout() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearCurrentUser();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate BMI if weight and height are available
    String? bmiText;
    String? bmiCategory;
    if (widget.user.weight != null && widget.user.height != null) {
      final bmi = double.parse(
        _calculateBMI(widget.user.weight!, widget.user.height!),
      );
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
                            widget.user.name.substring(0, 1).toUpperCase(),
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
          Text(
            widget.user.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.user.email, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: 'Informations personnelles',
            items: [
              _buildInfoItem(
                Icons.height,
                'Taille',
                widget.user.height != null ? '${widget.user.height} cm' : 'Non spécifié',
              ),
              _buildInfoItem(
                Icons.monitor_weight,
                'Poids',
                widget.user.weight != null ? '${widget.user.weight} kg' : 'Non spécifié',
              ),
              _buildInfoItem(
                Icons.cake, 
                'Âge', 
                widget.user.age != null ? '${widget.user.age} ans' : 'Non spécifié'
              ),
              _buildInfoItem(
                Icons.person_outline,
                'Genre',
                widget.user.gender ?? 'Non spécifié',
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
              // Navigate to edit profile screen without BlocProvider
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: widget.user),
                ),
              );

              if (result == true && mounted) {
                // Refresh profile after editing
                context.read<ProfileBloc>().add(LoadProfile());
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
