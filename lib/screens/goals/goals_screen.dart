// lib/screens/goals/goals_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/goal_model.dart';
import '../../services/database_helper.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // --- Services and State ---
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Goal>> _currentGoals;

  // --- Theme Colors ---
  static const Color _scaffoldBgColor = Color(0xFFF7F7FD);
  static const Color _primaryColor = Color(0xFF7B61FF);
  static const Color _cardColor = Colors.white;
  static const Color _titleColor = Color(0xFF2F2E41);
  static const Color _subtitleColor = Color(0xFF9B9B9B);
  static const Color _accentColor = Color(0xFFFFD6F7);

  // --- Predefined Fitness Goals ---
  final List<Goal> _fitnessGoals = [
    Goal(name: "Marcher 10,000 pas", description: "Boost ton énergie et améliore ton cœur en marchant 10 000 pas chaque jour."),
    Goal(name: "3 entraînements par semaine", description: "Effectuer 3 séances d'entraînement complètes par semaine pour te renforcer."),
    Goal(name: "Boire 2L d'eau par jour", description: "Ta peau et ton énergie te remercieront ! Hydrate-toi bien."),
    Goal(name: "Dormir 7h par nuit", description: "Un bon sommeil est la clé de la récupération et de la bonne humeur."),
    Goal(name: "Manger 5 fruits/légumes", description: "Fais le plein de vitamines et de couleurs dans ton assiette."),
    Goal(name: "10 min de méditation", description: "Prends un moment pour toi, pour te calmer et te recentrer."),
  ];

  @override
  void initState() {
    super.initState();
    _refreshGoalsList();
  }

  // --- Data Logic ---
  void _refreshGoalsList() {
    setState(() {
      _currentGoals = _dbHelper.getActiveGoals();
    });
  }

  void _addGoal(Goal goal) async {
    await _dbHelper.addGoal(goal);
    _refreshGoalsList();
    _showStyledSnackBar('${goal.name} ajouté à tes objectifs !', Icons.favorite_border);
  }

  void _completeGoal(Goal goal) async {
    goal.isCompleted = true;
    await _dbHelper.updateGoal(goal);
    _refreshGoalsList();
    _showStyledSnackBar('Bravo ! "${goal.name}" complété !', Icons.star);
  }

  // --- UI Building Blocks ---

  // Custom SnackBar for feedback
  void _showStyledSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: _primaryColor),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: _titleColor, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: _accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Header inspired by the template
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 30.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quels sont tes\nobjectifs ?',
                style: TextStyle(
                  color: _titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _titleColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: ListView(
        children: [
          _buildHeader(),
          
          _buildSectionTitle('Mes Objectifs Actuels'),
          const SizedBox(height: 20),
          _buildCurrentGoalsList(),

          const SizedBox(height: 40),

          _buildSectionTitle('Idées d\'Objectifs'),
          const SizedBox(height: 20),
          _buildFitnessGoalsList(),

          const SizedBox(height: 40), // Extra space at the bottom
        ],
      ),
    );
  }

  // --- Detailed List Widgets ---

  Widget _buildCurrentGoalsList() {
    return FutureBuilder<List<Goal>>(
      future: _currentGoals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _primaryColor));
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20)
            ),
            child: const Center(
              child: Text(
                'Aucun objectif pour le moment.\nAjoutes-en un ! ✨',
                textAlign: TextAlign.center,
                style: TextStyle(color: _subtitleColor, fontSize: 16),
              ),
            ),
          );
        }

        final goals = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: goals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final goal = goals[index];
            return Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                leading: Checkbox(
                  value: goal.isCompleted,
                  onChanged: (bool? value) {
                    if (value == true) {
                      _completeGoal(goal);
                    }
                  },
                  activeColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, color: _titleColor)),
                subtitle: Text(goal.description, style: const TextStyle(color: _subtitleColor)),
                trailing: goal.imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.memory(goal.imageBytes!, width: 55, height: 55, fit: BoxFit.cover),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFitnessGoalsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: _fitnessGoals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final fitnessGoal = _fitnessGoals[index];
        return Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20.0),
             boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Text(fitnessGoal.name, style: const TextStyle(fontWeight: FontWeight.w600, color: _titleColor)),
            iconColor: _primaryColor,
            collapsedIconColor: _primaryColor,
            shape: const Border(), // Remove default border
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fitnessGoal.description, style: const TextStyle(color: _subtitleColor, height: 1.5)),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _addGoal(fitnessGoal),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Ajouter cet objectif'),
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Add Goal Dialog ---
  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    Uint8List? imageBytes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _scaffoldBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Créer un objectif perso', style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du goal',
                        labelStyle: const TextStyle(color: _subtitleColor),
                        filled: true,
                        fillColor: _cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: _subtitleColor),
                        filled: true,
                        fillColor: _cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setDialogState(() {
                            imageBytes = bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(12),
                          image: imageBytes != null ? DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover) : null,
                        ),
                        child: imageBytes == null 
                          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_outlined, color: _subtitleColor), SizedBox(height: 4), Text('Ajouter une photo', style: TextStyle(color: _subtitleColor))]))
                          : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler', style: TextStyle(color: _subtitleColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                      final newGoal = Goal(
                        name: nameController.text,
                        description: descriptionController.text,
                        imageBytes: imageBytes,
                      );
                      _addGoal(newGoal);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
