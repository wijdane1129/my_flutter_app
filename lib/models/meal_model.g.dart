// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
  id: json['id'] as String,
  name: json['name'] as String,
  calories: (json['calories'] as num).toDouble(),
  proteins: (json['proteins'] as num).toDouble(),
  carbs: (json['carbs'] as num).toDouble(),
  fats: (json['fats'] as num).toDouble(),
  servingSize: (json['servingSize'] as num).toDouble(),
  servingUnit: json['servingUnit'] as String,
  consumedAt: DateTime.parse(json['consumedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'calories': instance.calories,
  'proteins': instance.proteins,
  'carbs': instance.carbs,
  'fats': instance.fats,
  'servingSize': instance.servingSize,
  'servingUnit': instance.servingUnit,
  'consumedAt': instance.consumedAt.toIso8601String(),
  'isFavorite': instance.isFavorite,
};
