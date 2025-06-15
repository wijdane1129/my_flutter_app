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
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(databaseHelper: DatabaseHelper())..add(LoadProfile()),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      backgroundColor: const Color(0xFF6B45CC),
                      child: _profileImagePath == null
                          ? Text(
                              widget.user.name.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.poppins(
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
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                widget.user.name,
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.user.email,
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Personal Information',
              items: [
                _buildInfoItem(
                  Icons.height,
                  'Height',
                  widget.user.height != null
                      ? '${widget.user.height} cm'
                      : 'Not specified',
                ),
                _buildInfoItem(
                  Icons.monitor_weight,
                  'Weight',
                  widget.user.weight != null
                      ? '${widget.user.weight} kg'
                      : 'Not specified',
                ),
                _buildInfoItem(
                  Icons.cake,
                  'Age',
                  widget.user.age != null
                      ? '${widget.user.age} years'
                      : 'Not specified',
                ),
                _buildInfoItem(
                  Icons.person_outline,
                  'Gender',
                  widget.user.gender ?? 'Not specified',
                ),
              ],
            ),
            if (bmiText != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Body Mass Index (BMI)',
                items: [
                  _buildInfoItem(
                    Icons.info_outline,
                    'BMI',
                    bmiText,
                  ),
                  _buildInfoItem(
                    Icons.category,
                    'Category',
                    bmiCategory!,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6B45CC),
                    Color(0xFF8B64E6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(user: widget.user),
                    ),
                  );

                  if (result == true && mounted) {
                    context.read<ProfileBloc>().add(LoadProfile());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color(0xFF6B45CC)),
              label: Text(
                'Log out',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6B45CC),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF6B45CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
