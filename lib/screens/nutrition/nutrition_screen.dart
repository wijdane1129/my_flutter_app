import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../services/nutritionix_service.dart';
import '../../models/meal_model.dart'; 

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

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _loadSuggestions();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await DatabaseHelper.instance.getMeals();
      setState(() {
        _meals = meals;
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
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => AddCustomMealDialog(),
              );

              if (result != null) {
                final meal = MealModel.custom(
                  name: result['name'],
                  calories: result['calories'],
                );

                await DatabaseHelper.instance.insertMeal(meal.toJson());
                _loadMeals();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return MealCard(
                        meal: meal,
                        onDelete: () => _removeMeal(meal['id']),
                      );
                    },
                  ),
                ),
                const Divider(),
                const Text(
                  'Suggestions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
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
                ),
              ],
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
      child: ListTile(
        leading: meal['image'] != null
            ? Image.network(
                meal['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.restaurant),
        title: Text(meal['name']),
        subtitle: Text('${meal['calories']} calories'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
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
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            suggestion['image'] != null && suggestion['image'] != ''
                ? Image.network(
                    suggestion['image'],
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.restaurant, size: 80),
            const SizedBox(height: 8),
            Text(
              suggestion['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text('${suggestion['calories']} calories'),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class AddCustomMealDialog extends StatelessWidget {
  const AddCustomMealDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _caloriesController = TextEditingController();

    return AlertDialog(
      title: const Text('Ajouter un repas personnalisé'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du repas'),
          ),
          TextField(
            controller: _caloriesController,
            decoration: const InputDecoration(labelText: 'Calories'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final String name = _nameController.text;
            final int? calories = int.tryParse(_caloriesController.text);

            if (name.isNotEmpty && calories != null) {
              Navigator.of(context).pop({
                'name': name,
                'calories': calories,
              });
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}