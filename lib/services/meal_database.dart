import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MealDatabase {
  static final MealDatabase instance = MealDatabase._init();
  static Database? _database;

  MealDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meals.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        calories INTEGER NOT NULL
      )
    ''');
  }

  Future<int> addMeal(Map<String, dynamic> meal) async {
    final db = await instance.database;
    return await db.insert('meals', meal);
  }

  Future<List<Map<String, dynamic>>> fetchMeals() async {
    final db = await instance.database;
    return await db.query('meals');
  }

  Future<int> deleteMeal(int id) async {
    final db = await instance.database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}