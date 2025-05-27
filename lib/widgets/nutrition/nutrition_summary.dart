import 'package:flutter/material.dart';
import '../../models/meal_model.dart';

class NutritionSummary extends StatelessWidget {
  final List<MealModel> meals;

  const NutritionSummary({
    super.key,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    final macros = _calculateMacros();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${_calculateTotalCalories().toStringAsFixed(0)} kcal',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroWidget(
                  label: 'Protéines',
                  value: macros['proteins']!,
                  color: Colors.red,
                ),
                _MacroWidget(
                  label: 'Glucides',
                  value: macros['carbs']!,
                  color: Colors.blue,
                ),
                _MacroWidget(
                  label: 'Lipides',
                  value: macros['fats']!,
                  color: Colors.yellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalCalories() {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  Map<String, double> _calculateMacros() {
    return {
      'proteins': meals.fold(0, (sum, meal) => sum + meal.proteins),
      'carbs': meals.fold(0, (sum, meal) => sum + meal.carbs),
      'fats': meals.fold(0, (sum, meal) => sum + meal.fats),
    };
  }
}

class _MacroWidget extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroWidget({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}g',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Container(
          height: 4,
          width: 60,
          color: color,
        ),
      ],
    );
  }
}