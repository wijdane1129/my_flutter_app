import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/nutrition/nutrition_event.dart' as nutrition_event;
import '../../bloc/nutrition/nutrition_state.dart';
import '../../models/meal_model.dart';

class FoodSearch extends StatelessWidget {
  const FoodSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher un aliment...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              if (query.length >= 3) {
                context.read<NutritionBloc>().add(nutrition_event.SearchFoods(query));
              }
            },
          ),
        ),
        BlocBuilder<NutritionBloc, NutritionState>(
          builder: (context, state) {
            if (state is NutritionLoaded && state.searchResults.isNotEmpty) {
              return _buildSearchResults(context, state.searchResults);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<MealModel> foods) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text('${food.calories.toStringAsFixed(0)} kcal / 100g'),
            trailing: Text(
              'P: ${food.proteins.toStringAsFixed(1)}g  C: ${food.carbs.toStringAsFixed(1)}g  F: ${food.fats.toStringAsFixed(1)}g',
            ),
            onTap: () {
              context.read<NutritionBloc>().add(nutrition_event.AddMeal(food));
            },
          );
        },
      ),
    );
  }
}