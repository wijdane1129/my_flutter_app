import '../../models/meal_model.dart';

abstract class NutritionEvent {}

class SearchFoods extends NutritionEvent {
  final String query;
  SearchFoods(this.query);
}

class AddMeal extends NutritionEvent {
  final MealModel meal;
  AddMeal(this.meal);
}

class LoadDailyMeals extends NutritionEvent {
  final DateTime date;
  LoadDailyMeals(this.date);
}

