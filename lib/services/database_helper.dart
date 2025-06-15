import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/activity_data_model.dart';
import '../models/goal_model.dart'; // <-- AJOUT: Importer le modèle de Goal
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    debugPrint('Creating database...');
    try {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          weight REAL,
          height REAL,
          age INTEGER,
          gender TEXT,
          profileImagePath TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE activity_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          steps INTEGER NOT NULL,
          distance REAL NOT NULL,
          calories_burned REAL NOT NULL,
          heart_rate INTEGER NOT NULL,
          sleep_hours REAL NOT NULL
        )
      ''');
      
      await db.execute('''
        CREATE TABLE meals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories REAL NOT NULL,
          image TEXT
        )
      ''');

      // --- START: GOALS TABLE ADDITION ---
      await db.execute('''
        CREATE TABLE goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          imageBytes BLOB,
          isCompleted INTEGER NOT NULL
        )
      ''');
      // --- END: GOALS TABLE ADDITION ---
      
      debugPrint('Tables created successfully');
    } catch (e) {
      debugPrint('Error creating tables: $e');
      rethrow;
    }
  }

  // ... (votre code existant pour insertUser, getUsers, authenticateUser, etc. reste inchangé)
  // ...
  // ...

  Future<int> insertUser(UserModel user) async {
    try {
      final db = await database;
      return await db.insert(
        'users',
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'insertion utilisateur: $e');
      throw Exception('Erreur lors de l\'insertion');
    }
  }

  Future<List<UserModel>> getUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return UserModel.fromJson(maps[i]);
    });
  }

  Future<UserModel?> authenticateUser(String email, String password) async {
    final Database db = await database;
    try {
      debugPrint('Tentative de connexion: $email');
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );

      if (result.isNotEmpty) {
        debugPrint('Utilisateur trouvé');
        return UserModel.fromJson(result.first);
      }
      debugPrint('Aucun utilisateur trouvé');
      return null;
    } catch (e) {
      debugPrint('Erreur d\'authentification: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return UserModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur de recherche utilisateur: $e');
      return null;
    }
  }

  Future<bool> tableExists(String tableName) async {
    final Database db = await database;
    try {
      final result = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', tableName],
      );
      debugPrint('Table $tableName existe: ${result.isNotEmpty}');
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la table: $e');
      return false;
    }
  }

  static const String _currentUserKey = 'current_user_id';

  Future<void> setCurrentUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserKey, userId);
  }

  Future<UserModel?> getCurrentUser() async {
    final Database db = await database;
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt(_currentUserKey);

      if (currentUserId == null) {
        debugPrint('No current user ID found in preferences');
        return null;
      }

      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [currentUserId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        debugPrint('Current user found: ${result.first['email']}');
        return UserModel.fromJson(result.first);
      }

      debugPrint('No user found with ID: $currentUserId');
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<void> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      debugPrint('Current user cleared from preferences');
    } catch (e) {
      debugPrint('Error clearing current user: $e');
      rethrow;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    final Database db = await database;
    try {
      final result = await db.update(
        'users',
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      debugPrint('User updated successfully: ${user.email}');
      return result > 0;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<bool> saveProfileImage(int userId, String imagePath) async {
    final Database db = await database;
    try {
      final result = await db.update(
        'users',
        {'profile_image_path': imagePath},
        where: 'id = ?',
        whereArgs: [userId],
      );
      debugPrint('Profile image saved for user $userId');
      return result > 0;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return false;
    }
  }

  Future<int> insertActivityData(ActivityDataModel data) async {
    final Database db = await database;
    return await db.insert('activity_data', data.toJson());
  }

  Future<int> updateActivityData(ActivityDataModel data) async {
    final Database db = await database;
    return await db.update(
      'activity_data',
      data.toJson(),
      where: 'date = ?',
      whereArgs: [data.date.toIso8601String()],
    );
  }

  Future<int> insertOrUpdateActivityData(ActivityDataModel data) async {
    try {
      return await insertActivityData(data);
    } on DatabaseException catch (e) {
        if (e.isUniqueConstraintError()) {
        return await updateActivityData(data);
      }
      rethrow;
    }
  }

  Future<ActivityDataModel?> getActivityDataByDate(DateTime date) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_data',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
    
    if (maps.isNotEmpty) {
      return ActivityDataModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<ActivityDataModel>> getActivityDataInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_data',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => ActivityDataModel.fromJson(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    try {
      final db = await database;
      return await db.query('meals');
    } catch (e) {
      debugPrint('Erreur lors de la récupération des repas: $e');
      throw Exception('Erreur lors de la récupération');
    }
  }

  Future<int> deleteMeal(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'meals',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du repas: $e');
      throw Exception('Erreur lors de la suppression');
    }
  }

  Future<int> insertMeal(Map<String, dynamic> meal) async {
    try {
      final db = await database;
      return await db.insert(
        'meals',
        meal,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'insertion du repas: $e');
      throw Exception('Erreur lors de l\'insertion');
    }
  }

  // --- START: GOALS METHODS ADDITION ---

  /// Ajoute un nouveau goal à la base de données.
  Future<int> addGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Récupère tous les goals qui ne sont pas encore complétés.
  Future<List<Goal>> getActiveGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'isCompleted = ?',
      whereArgs: [0], // 0 pour false
    );

    // Convertit la liste de Maps en une liste de Goals.
    return List.generate(maps.length, (i) {
      return Goal.fromMap(maps[i]);
    });
  }

  /// Met à jour un goal existant (utile pour le marquer comme complété).
  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
  
  /// Supprime un goal de la base de données par son ID.
  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- END: GOALS METHODS ADDITION ---

}

extension DatabaseExceptionExtension on DatabaseException {
  bool isUniqueConstraintError() {
    return toString().contains('UNIQUE constraint failed');
  }
}
