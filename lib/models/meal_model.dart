import 'package:json_annotation/json_annotation.dart';
part 'meal_model.g.dart';

@JsonSerializable()
class MealModel {
  final int? id;
  final int userId;
  final String name;
  final String type;
  final int calories;
  final double proteins;
  final double carbs;
  final double fats;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;


  MealModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  factory MealModel.fromJson(Map<String,dynamic> json)=>_$MealModelFromJson(json);
  Map<String,dynamic> toJson()=>_$MealModelToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}
