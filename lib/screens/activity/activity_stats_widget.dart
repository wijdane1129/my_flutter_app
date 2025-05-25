import 'package:flutter/material.dart';
import '../../models/activity_data_model.dart';

class ActivityStatsWidget extends StatelessWidget {
  final ActivityDataModel activityData;

  const ActivityStatsWidget({super.key, required this.activityData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques du jour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  Icons.directions_walk,
                  'Pas',
                  '${activityData.steps}',
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  Icons.straighten,
                  'Distance',
                  '${activityData.distance.toStringAsFixed(2)} km',
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  Icons.local_fire_department,
                  'Calories',
                  '${activityData.caloriesBurned.toStringAsFixed(0)} kcal',
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  Icons.favorite,
                  'Fréq. cardiaque',
                  '${activityData.heartRate} bpm',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, 
      String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}