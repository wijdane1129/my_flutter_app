import 'package:json_annotation/json_annotation.dart';
part 'goal_model.g.dart';

@JsonSerializable()
class GoalModel {
  final int? id;
  final int userId;
  final String type;
  final String description;
  final double targetValue;
  final double currentValue;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime startDate;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime targetDate;

  GoalModel({
    this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.targetDate,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalModelToJson(this);
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  double get progressPercentage {
    return (currentValue / targetValue) * 100;
  }
}
