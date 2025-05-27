import 'package:flutter/material.dart';
import '../../services/meal_database.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await MealDatabase.instance.fetchMeals();
    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  Future<void> _addMeal(Map<String, dynamic> meal) async {
    await MealDatabase.instance.addMeal(meal);
    _loadMeals();
  }

  Future<void> _removeMeal(int id) async {
    await MealDatabase.instance.deleteMeal(id);
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Change la couleur de fond
        title: const Text('Nutrition'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final newMeal = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _AddMealDialog(),
              );
              if (newMeal != null) {
                _addMeal(newMeal);
              }
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Ajouter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun repas ajouté.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          meal['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Ingrédients : ${meal['ingredients']}\nCalories : ${meal['calories']} kcal',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMeal(meal['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddMealDialog extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un repas'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du repas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingrédients',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final ingredients = _ingredientsController.text.trim();
            final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

            if (name.isNotEmpty && ingredients.isNotEmpty && calories > 0) {
              Navigator.pop(context, {
                'name': name,
                'ingredients': ingredients,
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