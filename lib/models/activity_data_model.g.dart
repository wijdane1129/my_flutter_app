// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityDataModel _$ActivityDataModelFromJson(Map<String, dynamic> json) =>
    ActivityDataModel(
      date: ActivityDataModel._dateTimeFromJson(json['date'] as String),
      steps: (json['steps'] as num).toInt(),
      distance: (json['distance'] as num).toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      heartRate: (json['heartRate'] as num).toInt(),
      sleepHours: (json['sleepHours'] as num).toDouble(),
    );

Map<String, dynamic> _$ActivityDataModelToJson(ActivityDataModel instance) =>
    <String, dynamic>{
      'date': ActivityDataModel._dateTimeToJson(instance.date),
      'steps': instance.steps,
      'distance': instance.distance,
      'caloriesBurned': instance.caloriesBurned,
      'heartRate': instance.heartRate,
      'sleepHours': instance.sleepHours,
    };
