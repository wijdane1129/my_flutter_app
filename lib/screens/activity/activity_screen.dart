// lib/screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/activity/activity_bloc.dart';
import '../../bloc/activity/activity_state.dart';
import '../../bloc/activity/activity_event.dart';
import '../../models/activity_data_model.dart';

class ActivityScreen extends StatelessWidget {
   const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityBloc()..add(LoadTodayActivity()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          actions: [
            BlocBuilder<ActivityBloc, ActivityState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: state is ActivityLoading
                      ? null
                      : () {
                          context.read<ActivityBloc>().add(SyncHealthData());
                        },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            if (state is ActivityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TodayActivityLoaded) {
              return _buildActivityContent(context, state.activityData);
            } else if (state is ActivityError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ActivityBloc>().add(SyncHealthData());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No activity data available'));
          },
        ),
      ),
    );
  }

  Widget _buildActivityContent(BuildContext context, ActivityDataModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayHeader(context),
          const SizedBox(height: 24),
          _buildActivityCards(context, data),
          const SizedBox(height: 24),
          _buildWeeklyButton(context),
        ],
      ),
    );
  }

  Widget _buildTodayHeader(BuildContext context) {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final month = _getMonthName(now.month);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '$dayName, $month ${now.day}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildActivityCards(BuildContext context, ActivityDataModel data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Steps',
                data.steps.toString(),
                Icons.directions_walk,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                context,
                'Distance',
                '${data.distance.toStringAsFixed(2)} km',
                Icons.straighten,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Calories',
                '${data.caloriesBurned.toStringAsFixed(0)} kcal',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                context,
                'Heart Rate',
                '${data.heartRate} bpm',
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          context,
          'Sleep',
          '${data.sleepHours.toStringAsFixed(1)} hours',
          Icons.bedtime,
          Colors.purple,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // Using withAlpha instead of withOpacity
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<ActivityBloc>().add(LoadWeeklyActivity());
          // Navigate to weekly view or show bottom sheet
        },
        icon: const Icon(Icons.calendar_today),
        label: const Text('View Weekly Summary'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}