import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayActivity extends ActivityEvent {}

class LoadWeeklyActivity extends ActivityEvent {}

class SyncHealthData extends ActivityEvent {}
