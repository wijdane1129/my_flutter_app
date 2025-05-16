import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final dbHelper = DatabaseHelper();
    final user = await dbHelper.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _user!.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement photo editing
                  },
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
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
