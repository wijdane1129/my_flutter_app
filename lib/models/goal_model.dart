// lib/models/goal_model.dart

import 'dart:typed_data';

class Goal {
  int? id;
  String name;
  String description;
  Uint8List? imageBytes; // Pour stocker l'image en tant que bytes
  bool isCompleted;

  Goal({
    this.id,
    required this.name,
    required this.description,
    this.imageBytes,
    this.isCompleted = false,
  });

  // Méthode pour convertir un Goal en Map (pour la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageBytes': imageBytes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Méthode pour convertir une Map en Goal (depuis la base de données)
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageBytes: map['imageBytes'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
