// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  type: json['type'] as String,
  description: json['description'] as String,
  targetValue: (json['targetValue'] as num).toDouble(),
  currentValue: (json['currentValue'] as num).toDouble(),
  startDate: GoalModel._dateTimeFromJson(json['startDate'] as String),
  targetDate: GoalModel._dateTimeFromJson(json['targetDate'] as String),
);

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': instance.type,
  'description': instance.description,
  'targetValue': instance.targetValue,
  'currentValue': instance.currentValue,
  'startDate': GoalModel._dateTimeToJson(instance.startDate),
  'targetDate': GoalModel._dateTimeToJson(instance.targetDate),
};
