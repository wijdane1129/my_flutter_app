import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class MealModel {
  final String id;
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double servingSize;
  final String servingUnit;
  final DateTime consumedAt;
  final bool isFavorite;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.servingUnit,
    required this.consumedAt,
    this.isFavorite = false,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => _$MealModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  double get totalCalories => calories * (servingSize / 100);
  double get totalProteins => proteins * (servingSize / 100);
  double get totalCarbs => carbs * (servingSize / 100);
  double get totalFats => fats * (servingSize / 100);

  factory MealModel.custom({
    required String name,
    required double calories,
    String? imageUrl,
  }) {
    return MealModel(
      id: DateTime.now().toString(),
      name: name,
      calories: calories,
      proteins: 0,
      carbs: 0,
      fats: 0,
      servingSize: 100,
      servingUnit: 'g',
      consumedAt: DateTime.now(),
    );
  }
}
