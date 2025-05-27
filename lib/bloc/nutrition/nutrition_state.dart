
import '../../models/meal_model.dart';

abstract class NutritionState {}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class NutritionLoaded extends NutritionState {
  final List<MealModel> meals;
  final List<MealModel> searchResults;
  final double totalCalories;

  NutritionLoaded({
    required this.meals,
    this.searchResults = const [],
    required this.totalCalories,
  });
}

class NutritionError extends NutritionState {
  final String message;
  NutritionError(this.message);
}