import 'package:equatable/equatable.dart';
import '../../models/activity_data_model.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class TodayActivityLoaded extends ActivityState {
  final ActivityDataModel activityData;

  const TodayActivityLoaded(this.activityData);

  @override
  List<Object> get props => [activityData];
}

class ActivityError extends ActivityState {
  final String message;

  const ActivityError(this.message);

  @override
  List<Object> get props => [message];
}