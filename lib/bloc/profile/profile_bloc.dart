import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_helper.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final DatabaseHelper databaseHelper;

  ProfileBloc({required this.databaseHelper}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await databaseHelper.getCurrentUser();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('No profile found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final success = await databaseHelper.updateUser(event.user);
      if (success) {
        emit(ProfileLoaded(event.user));
      } else {
        emit(const ProfileError('Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await databaseHelper.saveProfileImage(event.userId, event.imagePath);
      add(LoadProfile());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
