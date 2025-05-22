// lib/services/health_service.dart
import 'package:flutter/material.dart';
import 'package:health/health.dart' show HealthFactory, HealthDataType, HealthDataPoint, HealthDataAccess, NumericHealthValue;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_data_model.dart';

// Define health exception types
enum HealthExceptionType {
  unauthorized,
  noData,
  error
}

// Define custom health exception
class HealthException implements Exception {
  final String message;
  final HealthExceptionType type;

  HealthException(this.message, this.type);

  @override
  String toString() => message;
}

class HealthService {
  static final HealthService _instance = HealthService._internal();
  
  factory HealthService() => _instance;
  
  HealthService._internal();
  
  // Create a HealthFactory instance
  final HealthFactory _health = HealthFactory();
  
  // Types of data to request
  static final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
  ];
  
  // Permissions to request
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
  ];
  
  // Request authorization to access health data
  Future<bool> requestAuthorization() async {
    try {
      // First check if we need to request OS permissions
      if (await Permission.activityRecognition.request().isGranted) {
        // Request health permissions
        final authorized = await _health.requestAuthorization(_types, permissions: _permissions);
        return authorized;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting health authorization: $e');
      return false;
    }
  }
  
  // Fetch health data for a specific date range
  Future<List<ActivityDataModel>> fetchHealthData(DateTime startDate, DateTime endDate) async {
    try {
      // Request authorization if needed
      bool authorized = await requestAuthorization();
      if (!authorized) {
        throw HealthException(
          'Authorization not granted for health data access',
          HealthExceptionType.unauthorized,
        );
      }
      
      // Fetch data from health platform
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startDate, 
        endDate, 
        _types,
      );
      
      // Process and convert to our model
      return _processHealthData(healthData, startDate, endDate);
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      throw Exception('Failed to fetch health data: ${e.toString()}');
    }
  }
  
  // Process raw health data into our model
  List<ActivityDataModel> _processHealthData(
    List<HealthDataPoint> healthData,
    DateTime startDate,
    DateTime endDate,
  ) {
    // Group data by date
    Map<String, ActivityDataModel> dailyData = {};
    
    for (HealthDataPoint point in healthData) {
      // Format date as YYYY-MM-DD for grouping
      String dateKey = _formatDate(point.dateFrom);
      
      // Initialize if not exists
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = ActivityDataModel(
          date: _parseDate(dateKey),
          steps: 0,
          distance: 0.0,
          caloriesBurned: 0.0,
          heartRate: 0,
          sleepHours: 0.0,
        );
      }
      
      // Update the appropriate field based on data type
      switch (point.type) {
        case HealthDataType.STEPS:
          dailyData[dateKey] = dailyData[dateKey]!.copyWith(
            steps: dailyData[dateKey]!.steps + (point.value as NumericHealthValue).numericValue.toInt(),
          );
          break;
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          dailyData[dateKey] = dailyData[dateKey]!.copyWith(
            distance: dailyData[dateKey]!.distance + (point.value as NumericHealthValue).numericValue,
          );
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          dailyData[dateKey] = dailyData[dateKey]!.copyWith(
            caloriesBurned: dailyData[dateKey]!.caloriesBurned + (point.value as NumericHealthValue).numericValue,
          );
          break;
        case HealthDataType.HEART_RATE:
          // For heart rate, we'll take the average later
          int currentCount = dailyData[dateKey]!.heartRateReadings?.length ?? 0;
          List<int> readings = dailyData[dateKey]!.heartRateReadings ?? [];
          readings.add((point.value as NumericHealthValue).numericValue.toInt());
          
          dailyData[dateKey] = dailyData[dateKey]!.copyWith(
            heartRateReadings: readings,
            heartRate: readings.reduce((a, b) => a + b) ~/ readings.length,
          );
          break;
        case HealthDataType.SLEEP_ASLEEP:
          // Calculate sleep duration in hours
          final sleepDuration = point.dateTo.difference(point.dateFrom).inMinutes / 60;
          dailyData[dateKey] = dailyData[dateKey]!.copyWith(
            sleepHours: dailyData[dateKey]!.sleepHours + sleepDuration,
          );
          break;
        default:
          break;
      }
    }
    
    return dailyData.values.toList();
  }
  
  // Sync health data with local storage
  Future<void> syncHealthData() async {
    try {
      // Get the last sync date or default to 7 days ago
      final lastSync = await _getLastSyncDate();
      final now = DateTime.now();
      
      // Fetch data since last sync
      final activityData = await fetchHealthData(lastSync, now);
      
      // Save to local database (you'll need to implement this)
      // await _saveActivityData(activityData);
      
      // Update last sync date
      await _updateLastSyncDate(now);
    } catch (e) {
      debugPrint('Error syncing health data: $e');
      throw Exception('Failed to sync health data: ${e.toString()}');
    }
  }
  
  // Get the last sync date from shared preferences
  Future<DateTime> _getLastSyncDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMillis = prefs.getInt('last_health_sync') ?? 0;
      
      if (lastSyncMillis == 0) {
        // Default to 7 days ago if never synced
        return DateTime.now().subtract(const Duration(days: 7));
      }
      
      return DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
    } catch (e) {
      debugPrint('Error getting last sync date: $e');
      // Default to 7 days ago on error
      return DateTime.now().subtract(const Duration(days: 7));
    }
  }
  
  // Update the last sync date in shared preferences
  Future<void> _updateLastSyncDate(DateTime syncDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_health_sync', syncDate.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error updating last sync date: $e');
    }
  }
  
  // Helper method to format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Helper method to parse YYYY-MM-DD to DateTime
  DateTime _parseDate(String dateStr) {
    List<String> parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

class HealthFactory {
  requestAuthorization(List<HealthDataType> types, {required List<HealthDataAccess> permissions}) {}
  
  getHealthDataFromTypes(DateTime startDate, DateTime endDate, List<HealthDataType> types) {}
}