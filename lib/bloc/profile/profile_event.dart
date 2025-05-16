import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserModel user;

  const UpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateProfileImage extends ProfileEvent {
  final int userId;
  final String imagePath;

  const UpdateProfileImage({required this.userId, required this.imagePath});

  @override
  List<Object?> get props => [userId, imagePath];
}
