import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(appDocDir.path, 'incubator_database.db');


      bool dbExists = await File(dbPath).exists();
      print('Database exists: $dbExists');

      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE users(
            userId TEXT PRIMARY KEY NOT NULL,
            name TEXT,
            surname TEXT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');

          await db.execute('''
        CREATE TABLE exercises(
          exerciseId TEXT PRIMARY KEY NOT NULL,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          startDateTime TEXT NOT NULL,
          endDateTime TEXT,
          isSynced TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (userId)
        )
      ''');
          await db.execute('''
        CREATE TABLE media(
          mediaId TEXT PRIMARY KEY NOT NULL,
          exerciseId TEXT NOT NULL,
          comments TEXT NOT NULL,
          filePath TEXT NOT NULL,
          isSynced TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (exerciseId) REFERENCES exercises (exerciseId)
          )
        ''');
          print('Database tables created successfully');
        },
        onOpen: (Database db) async {
          List<Map<String, dynamic>> tables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table'",
          );
          print('Existing tables: ${tables.map((t) => t['name']).toList()}');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }
}
