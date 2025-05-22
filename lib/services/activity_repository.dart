// lib/services/activity_repository.dart
import 'package:flutter/foundation.dart';
import '../models/activity_data_model.dart';
import 'database_helper.dart';
import 'health_service.dart';

class ActivityRepository {
  final DatabaseHelper _databaseHelper;
  final HealthService _healthService;

  ActivityRepository({
    DatabaseHelper? databaseHelper,
    HealthService? healthService,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        _healthService = healthService ?? HealthService();

  // Sync health data with local storage
  Future<void> syncHealthData() async {
    await _healthService.syncHealthData();
  }

  // Get activity data for a specific date
  Future<ActivityDataModel?> getActivityDataForDate(DateTime date) async {
    return await _databaseHelper.getActivityDataByDate(date);
  }

  // Get activity data for a date range
  Future<List<ActivityDataModel>> getActivityDataForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _databaseHelper.getActivityDataInRange(startDate, endDate);
  }

  // Get today's activity data
  Future<ActivityDataModel?> getTodayActivityData() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Try to get from local database first
    ActivityDataModel? activityData =
        await _databaseHelper.getActivityDataByDate(startOfDay);

    // If not found or data is old, sync with health service
    if (activityData == null) {
      try {
        await syncHealthData();
        activityData = await _databaseHelper.getActivityDataByDate(startOfDay);
      } catch (e) {
        print('Error fetching today\'s activity data: $e');
        // Return empty data if we can't get it
        activityData = ActivityDataModel(
          date: startOfDay,
          steps: 0,
          distance: 0.0,
          caloriesBurned: 0.0,
          heartRate: 0,
          sleepHours: 0.0,
        );
      }
    }

    return activityData;
  }

  // Get weekly activity summary
  Future<List<ActivityDataModel>> getWeeklyActivityData() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    try {
      // Sync before getting weekly data
      await syncHealthData();
      return await getActivityDataForRange(startOfDay, today);
    } catch (e) {
      print('Error fetching weekly activity data: $e');
      return [];
    }
  }

  Future<ActivityDataModel> getTodayActivity() async {
    try {
      final today = DateTime.now();
      final data = await _databaseHelper.getActivityDataByDate(today);

      if (data != null) {
        return data;
      }

      // Return empty activity data if none exists for today
      return ActivityDataModel(
        date: today,
        steps: 0,
        distance: 0.0,
        caloriesBurned: 0.0,
        heartRate: 0,
        sleepHours: 0.0,
      );
    } catch (e) {
      debugPrint('Error getting today\'s activity: $e');
      rethrow;
    }
  }

  Future<List<ActivityDataModel>> getWeeklyActivity() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      return await _databaseHelper.getActivityDataInRange(weekStart, weekEnd);
    } catch (e) {
      debugPrint('Error getting weekly activity: $e');
      rethrow;
    }
  }

  Future<void> saveActivity(ActivityDataModel activity) async {
    try {
      await _databaseHelper.insertOrUpdateActivityData(activity);
    } catch (e) {
      debugPrint('Error saving activity: $e');
      rethrow;
    }
  }
}