// lib/models/activity_data_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_data_model.g.dart';

@JsonSerializable()
class ActivityDataModel extends Equatable {
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  final int steps;
  final double distance;
  final double caloriesBurned;
  final int heartRate;
  final double sleepHours;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<int>? heartRateReadings;

  const ActivityDataModel({
    required this.date,
    required this.steps,
    required this.distance,
    required this.caloriesBurned,
    required this.heartRate,
    required this.sleepHours,
    this.heartRateReadings,
  });

  ActivityDataModel copyWith({
    DateTime? date,
    int? steps,
    double? distance,
    double? caloriesBurned,
    int? heartRate,
    double? sleepHours,
    List<int>? heartRateReadings,
  }) {
    return ActivityDataModel(
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      heartRate: heartRate ?? this.heartRate,
      sleepHours: sleepHours ?? this.sleepHours,
      heartRateReadings: heartRateReadings ?? this.heartRateReadings,
    );
  }

  @override
  List<Object?> get props => [date, steps, distance, caloriesBurned, heartRate, sleepHours];

  // Use the generated methods instead of manual implementation
  factory ActivityDataModel.fromJson(Map<String, dynamic> json) => 
      _$ActivityDataModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActivityDataModelToJson(this);

  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}