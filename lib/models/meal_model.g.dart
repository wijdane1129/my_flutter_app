// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  type: json['type'] as String,
  calories: (json['calories'] as num).toInt(),
  proteins: (json['proteins'] as num).toDouble(),
  carbs: (json['carbs'] as num).toDouble(),
  fats: (json['fats'] as num).toDouble(),
  date: MealModel._dateTimeFromJson(json['date'] as String),
);

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'type': instance.type,
  'calories': instance.calories,
  'proteins': instance.proteins,
  'carbs': instance.carbs,
  'fats': instance.fats,
  'date': MealModel._dateTimeToJson(instance.date),
};
