import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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
    debugPrint('Création de la base de données...');
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
          gender TEXT
        )
      ''');
      debugPrint('Table users créée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la création de la table users: $e');
      rethrow;
    }
  }

  Future<int> insertUser(UserModel user) async {
    final Database db = await database;
    try {
      debugPrint('Tentative d\'insertion utilisateur: ${user.email}');
      final result = await db.insert('users', user.toJson());
      debugPrint('Utilisateur inséré avec succès, ID: $result');
      return result;
    } catch (e) {
      debugPrint('Erreur lors de l\'insertion utilisateur: $e');
      return -1;
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
}
