import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final double? weight;
  final double? height;
  final int? age;
  final String? gender;
  final String? profileImagePath; // Add this field

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.profileImagePath, // Add this parameter
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
