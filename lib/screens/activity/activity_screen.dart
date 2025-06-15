import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/activity/activity_bloc.dart';
import '../../bloc/activity/activity_event.dart';
import '../../bloc/activity/activity_state.dart';
import 'activity_stats_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Map<String, List<Map<String, dynamic>>> categorizedExercises = {
    'Upper Body': [
      {
        'name': 'Side Plank Rotation',
        'duration': 10,
        'target': 'Obliques, Shoulders',
        'description': 'Strengthens the obliques and improves core stability.',
        'gif': 'assets/gifs/side_plank_rotation.gif',
      },
      {
        'name': 'Kneeling Back Rotation',
        'duration': 8,
        'target': 'Back, Shoulders',
        'description': 'Improves thoracic spine mobility and posture.',
        'gif': 'assets/gifs/kneeling_back_rotation.gif',
      },
    ],
    'Lower Body': [
      {
        'name': 'Hip Thrust',
        'duration': 12,
        'target': 'Glutes, Hamstrings',
        'description': 'Builds strength in the glutes and hamstrings.',
        'gif': 'assets/gifs/hip_thrust.gif',
      },
      {
        'name': 'Cossack Squat',
        'duration': 10,
        'target': 'Quads, Adductors',
        'description': 'Improves flexibility and strength in the lower body.',
        'gif': 'assets/gifs/cossack_squat.gif',
      },
    ],
    'Whole Body': [
      {
        'name': 'High Jump and Squat',
        'duration': 10,
        'target': 'Legs, Core',
        'description': 'Combines explosive power with strength training.',
        'gif': 'assets/gifs/high_jump_and_squat.gif',
      },
      {
        'name': 'Steps Plank with Running Legs',
        'duration': 12,
        'target': 'Core, Cardio',
        'description':
            'Engages the core and improves cardiovascular endurance.',
        'gif': 'assets/gifs/steps_plank_running_legs.gif',
      },
    ],
    'Stretches': [
      {
        'name': 'Adductor Stretches',
        'duration': 5,
        'target': 'Adductors',
        'description': 'Stretches the inner thighs and improves flexibility.',
        'gif': 'assets/gifs/adductor_stretches.gif',
      },
      {
        'name': 'Leg Scissors',
        'duration': 5,
        'target': 'Hip Flexors, Core',
        'description': 'Improves flexibility and strengthens the hip flexors.',
        'gif': 'assets/gifs/leg_scissors.gif',
      },
    ],
  };

  // Liste contenant les exercices ajoutés par l'utilisateur
  final List<Map<String, dynamic>> userExercises = [];

  void _addExerciseToUserList(Map<String, dynamic> exercise) {
    setState(() {
      userExercises.add(exercise);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise['name']} ajouté à votre liste!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityBloc()..add(LoadTodayActivity()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ActivityBloc>().add(SyncHealthData());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activities',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<ActivityBloc, ActivityState>(
                    builder: (context, state) {
                      if (state is ActivityLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TodayActivityLoaded) {
                        return ActivityStatsWidget(
                          activityData: state.activityData,
                        );
                      }
                      return const Center(
                        child: Text('Aucune donnée disponible'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mes Exercices',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildUserExercises(),
                  const SizedBox(height: 24),
                  Text(
                    'Exercices Suggérés',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestedExercises(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserExercises() {
    if (userExercises.isEmpty) {
      return const Center(
        child: Text(
          'Aucun exercice ajouté.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userExercises.length,
      itemBuilder: (context, index) {
        final exercise = userExercises[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(exercise['gif'], fit: BoxFit.cover),
            ),
            title: Text(
              exercise['name'] ?? '',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Durée: ${exercise['duration']} min',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  userExercises.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedExercises() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categorizedExercises.keys.length,
      itemBuilder: (context, index) {
        final category = categorizedExercises.keys.elementAt(index);
        final exercises = categorizedExercises[category]!;
        return ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          title: Text(
            category,
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: exercises
              .map((exercise) => _buildExerciseCard(exercise))
              .toList(),
        );
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(exercise['gif'], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cible: ${exercise['target']}',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise['description'] ?? '',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Durée: ${exercise['duration']} min',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () => _addExerciseToUserList(exercise),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B45CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Ajouter',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
