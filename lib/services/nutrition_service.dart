import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/meal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class NutritionService {
  static const String _cacheKey = 'recent_foods';
  final http.Client _client;
  final SharedPreferences _prefs;

  NutritionService(this._prefs, {http.Client? client}) 
      : _client = client ?? http.Client();

  Future<List<MealModel>> searchFoods(String query) async {
    try {
      // Vérifier d'abord le cache
      final cachedResults = _getCachedResults(query);
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }

      final response = await _client.get(
        Uri.parse('${ApiConfig.nutritionixBaseUrl}/search/instant?query=$query'),
        headers: {
          'x-app-id': ApiConfig.nutritionixAppId,
          'x-app-key': ApiConfig.nutritionixAppKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = _parseFoodsFromResponse(data);
        
        // Mettre en cache les résultats
        _cacheResults(query, foods);
        
        return foods;
      }
      throw Exception('Failed to load foods: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error searching foods: $e');
    }
  }

  List<MealModel> _parseFoodsFromResponse(Map<String, dynamic> data) {
    final commonFoods = data['common'] as List;
    return commonFoods.map((item) {
      final servingWeight = item['serving_weight_grams']?.toDouble() ?? 100.0;
      return MealModel(
        id: item['food_name'],
        name: item['food_name'],
        calories: _calculatePerServing(item['nf_calories']?.toDouble() ?? 0, servingWeight),
        proteins: _calculatePerServing(item['nf_protein']?.toDouble() ?? 0, servingWeight),
        carbs: _calculatePerServing(item['nf_total_carbohydrate']?.toDouble() ?? 0, servingWeight),
        fats: _calculatePerServing(item['nf_total_fat']?.toDouble() ?? 0, servingWeight),
        servingSize: servingWeight,
        servingUnit: 'g',
        consumedAt: DateTime.now(),
      );
    }).toList();
  }

  double _calculatePerServing(double value, double servingWeight) {
    return (value * 100) / servingWeight; // Normaliser à 100g
  }

  List<MealModel> _getCachedResults(String query) {
    final cachedData = _prefs.getString('${_cacheKey}_$query');
    if (cachedData != null) {
      try {
        final List<dynamic> decodedData = json.decode(cachedData);
        return decodedData.map((item) => MealModel.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Future<void> _cacheResults(String query, List<MealModel> foods) async {
    final encodedData = json.encode(
      foods.map((food) => food.toJson()).toList(),
    );
    await _prefs.setString('${_cacheKey}_$query', encodedData);
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cacheKey)) {
        await _prefs.remove(key);
      }
    }
  }

  double calculateTotalCalories(List<MealModel> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  Map<String, double> calculateMacronutrients(List<MealModel> meals) {
    return {
      'proteins': meals.fold(0, (sum, meal) => sum + meal.proteins),
      'carbs': meals.fold(0, (sum, meal) => sum + meal.carbs),
      'fats': meals.fold(0, (sum, meal) => sum + meal.fats),
    };
  }

  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final List<Map<String, dynamic>> maps = await db.query(
        'meals',
        where: 'consumedAt BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      return List.generate(maps.length, (i) {
        return MealModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to load meals: $e');
    }
  }
}