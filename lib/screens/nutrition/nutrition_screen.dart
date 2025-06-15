import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../services/nutritionix_service.dart';
import '../../models/meal_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionixService _nutritionixService = NutritionixService();
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _loadSuggestions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadMeals(query: _searchController.text);
  }

  Future<void> _loadMeals({String? query}) async {
    try {
      final meals = await DatabaseHelper.instance.getMeals();
      setState(() {
        if (query != null && query.isNotEmpty) {
          _meals = meals
              .where((meal) =>
                  meal['name']!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        } else {
          _meals = meals;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des repas: $e');
    }
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await _nutritionixService.searchFoods('healthy meal');
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      print('Erreur lors du chargement des suggestions: $e');
    }
  }

  Future<void> _addMeal(Map<String, dynamic> meal) async {
    try {
      await DatabaseHelper.instance.insertMeal(meal);
      _loadMeals();
    } catch (e) {
      print('Erreur lors de l\'ajout du repas: $e');
    }
  }

  Future<void> _removeMeal(int id) async {
    try {
      await DatabaseHelper.instance.deleteMeal(id);
      _loadMeals();
    } catch (e) {
      print('Erreur lors de la suppression du repas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => const AddCustomMealDialog(),
          );
          if (result != null) {
            await _addMeal(result);
          }
        },
        backgroundColor: const Color(0xFF6B45CC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMeals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nutrition',
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search meals...',
                        labelStyle:
                            GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF6B45CC)),
                        filled: true,
                        fillColor: Colors.grey[50],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF6B45CC)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'My Meals',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildMealList(),
                    const SizedBox(height: 24),
                    Text(
                      'Suggestions',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildSuggestionsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMealList() {
    if (_meals.isEmpty) {
      return Center(
        child: Text(
          'No meals added yet.',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _meals.length,
      itemBuilder: (context, index) {
        final meal = _meals[index];
        return MealCard(
          meal: meal,
          onDelete: () => _removeMeal(meal['id']),
        );
      },
    );
  }

  Widget _buildSuggestionsList() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return SuggestionCard(
            suggestion: suggestion,
            onAdd: () => _addMeal({
              'name': suggestion['name'],
              'calories': suggestion['calories'],
              'image': suggestion['image'],
            }),
          );
        },
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onDelete;

  const MealCard({
    Key? key,
    required this.meal,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            meal['image'] != null && meal['image']!.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      meal['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : meal['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(meal['image'] as String),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.restaurant,
                        color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'] ?? '',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${meal['calories']} calories',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final VoidCallback onAdd;

  const SuggestionCard({
    Key? key,
    required this.suggestion,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            suggestion['image'] != null && suggestion['image'] != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      suggestion['image'],
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.restaurant,
                    size: 60, color: Theme.of(context).colorScheme.primary),
            Text(
              suggestion['name'] ?? '',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${suggestion['calories']} calories',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B45CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCustomMealDialog extends StatefulWidget {
  const AddCustomMealDialog({super.key});

  @override
  State<AddCustomMealDialog> createState() => _AddCustomMealDialogState();
}

class _AddCustomMealDialogState extends State<AddCustomMealDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Custom Meal',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600])
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name',
                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6B45CC)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(
                labelText: 'Calories',
                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6B45CC)),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            final calories = double.tryParse(_caloriesController.text) ?? 0.0;
            if (name.isNotEmpty && calories > 0) {
              Navigator.of(context).pop({
                'name': name,
                'calories': calories,
                'image': _imageFile?.path
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter valid name and calories.',
                      style: GoogleFonts.poppins()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B45CC),
            foregroundColor: Colors.white,
          ),
          child: Text('Add', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
