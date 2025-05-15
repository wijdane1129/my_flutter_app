import 'package:json_annotation/json_annotation.dart';
part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  final int? id;
  final int userId;
  final String name;
  final String type;
  final int duration;
  final int calloriesBurned;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;

  ExerciseModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.calloriesBurned,
    required this.date,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>_$ExerciseModelFromJson(json);
  Map<String,dynamic> toJson()=> _$ExerciseModelToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

}
