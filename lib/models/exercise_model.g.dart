// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      duration: (json['duration'] as num).toInt(),
      calloriesBurned: (json['calloriesBurned'] as num).toInt(),
      date: ExerciseModel._dateTimeFromJson(json['date'] as String),
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'type': instance.type,
      'duration': instance.duration,
      'calloriesBurned': instance.calloriesBurned,
      'date': ExerciseModel._dateTimeToJson(instance.date),
    };
