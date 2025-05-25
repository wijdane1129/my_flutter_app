import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';

class AddExerciseForm extends StatefulWidget {
  final Function(ExerciseModel) onExerciseAdded;

  const AddExerciseForm({super.key, required this.onExerciseAdded});

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedType = 'Cardio';
  final int _caloriesBurned = 0;

  static const exerciseTypes = ['Cardio', 'Force', 'Flexibilité', 'Sport'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'exercice',
              icon: Icon(Icons.fitness_center),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Type d\'exercice',
              icon: Icon(Icons.category),
            ),
            items: exerciseTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Durée (minutes)',
              icon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une durée';
              }
              if (int.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submitForm,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter l\'exercice'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final exercise = ExerciseModel(
        userId: 1, // À remplacer par l'ID de l'utilisateur actuel
        name: _nameController.text,
        type: _selectedType,
        duration: int.parse(_durationController.text),
        calloriesBurned: _calculateCalories(),
        date: DateTime.now(),
      );

      widget.onExerciseAdded(exercise);
      Navigator.pop(context);
    }
  }

  int _calculateCalories() {
    // Calcul simplifié des calories
    final duration = int.parse(_durationController.text);
    switch (_selectedType) {
      case 'Cardio':
        return duration * 10;
      case 'Force':
        return duration * 8;
      case 'Sport':
        return duration * 12;
      default:
        return duration * 5;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}