import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/health_service.dart';
import '../../services/activity_repository.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final HealthService _healthService;
  final ActivityRepository _activityRepository;

  ActivityBloc({
    HealthService? healthService,
    ActivityRepository? activityRepository,
  }) : _healthService = healthService ?? HealthService(),
       _activityRepository = activityRepository ?? ActivityRepository(),
       super(ActivityInitial()) {
    on<LoadTodayActivity>(_onLoadTodayActivity);
    on<LoadWeeklyActivity>(_onLoadWeeklyActivity);
    on<SyncHealthData>(_onSyncHealthData);
  }

  Future<void> _onLoadTodayActivity(
    LoadTodayActivity event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final data = await _activityRepository.getTodayActivity();
      emit(TodayActivityLoaded(data));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }

  Future<void> _onLoadWeeklyActivity(
    LoadWeeklyActivity event,
    Emitter<ActivityState> emit,
  ) async {
    // Implement weekly activity loading
  }

  Future<void> _onSyncHealthData(
    SyncHealthData event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      await _healthService.syncHealthData();
      final data = await _activityRepository.getTodayActivity();
      emit(TodayActivityLoaded(data));
    } catch (e) {
      emit(ActivityError(e.toString()));
    }
  }
}
