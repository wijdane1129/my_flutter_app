import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/nutrition_service.dart';
import '../../models/meal_model.dart';
import 'nutrition_event.dart' as ne;
import 'nutrition_state.dart';

class NutritionBloc extends Bloc<ne.NutritionEvent, NutritionState> {
  final NutritionService _nutritionService;

  NutritionBloc(this._nutritionService) : super(NutritionInitial()) {
    on<ne.SearchFoods>(_onSearchFoods);
    on<ne.AddMeal>(_onAddMeal);
    on<ne.LoadDailyMeals>(_onLoadDailyMeals);
  }

  Future<void> _onSearchFoods(
    ne.SearchFoods event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      emit(NutritionLoading());
      final foods = await _nutritionService.searchFoods(event.query);
      
      if (state is NutritionLoaded) {
        final currentState = state as NutritionLoaded;
        emit(NutritionLoaded(
          meals: currentState.meals,
          searchResults: foods,
          totalCalories: currentState.totalCalories,
        ));
      } else {
        emit(NutritionLoaded(
          meals: [],
          searchResults: foods,
          totalCalories: 0,
        ));
      }
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }

  Future<void> _onAddMeal(
    ne.AddMeal event,
    Emitter<NutritionState> emit,
  ) async {
    if (state is NutritionLoaded) {
      final currentState = state as NutritionLoaded;
      final updatedMeals = [...currentState.meals, event.meal];
      final totalCalories = _calculateTotalCalories(updatedMeals);
      
      emit(NutritionLoaded(
        meals: updatedMeals,
        searchResults: currentState.searchResults,
        totalCalories: totalCalories,
      ));
    }
  }

  Future<void> _onLoadDailyMeals(
    ne.LoadDailyMeals event,
    Emitter<NutritionState> emit,
  ) async {
    try {
      emit(NutritionLoading());
      
      final meals = await _nutritionService.getMealsByDate(event.date);
      final totalCalories = _calculateTotalCalories(meals);
      
      emit(NutritionLoaded(
        meals: meals,
        totalCalories: totalCalories,
      ));
    } catch (e) {
      emit(NutritionError(e.toString()));
    }
  }

  double _calculateTotalCalories(List<MealModel> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  }
}