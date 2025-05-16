// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  weight: (json['weight'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  profileImagePath: json['profileImagePath'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
  'weight': instance.weight,
  'height': instance.height,
  'age': instance.age,
  'gender': instance.gender,
  'profileImagePath': instance.profileImagePath,
};
