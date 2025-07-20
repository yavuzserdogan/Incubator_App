import 'package:sqflite/sqflite.dart';
import '../../models/exercise_model.dart';
import 'package:incubator/data/sources/local/database/database_helper.dart';

abstract class ExercisesLocalDataSource {
  Future<List<ExerciseModel>> getExercises(String userId);

  Future<ExerciseModel?> getExerciseById(String exerciseId);

  Future<List<ExerciseModel>> getExercisesBySynced(
    String userId,
    //bool isSynced,
  );

  Future<void> createExercise(ExerciseModel exercise);

  Future<void> updateExercise({
    required String exerciseId,
    required String userId,
    String? title,
    String? endDateTime,
    String? updatedAt,
    String? isSynced,
  });

  Future<void> createExerciseFromServer({
    required String exerciseId,
    required String userId,
    required String title,
    required String startDateTime,
    required String endDateTime,
    required String updatedAt,
  });

  Future<void> deleteExercise(String exerciseId);
}

class ExerciseLocalDataSourceImpl implements ExercisesLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _getCurrentUtcTime() {
    return DateTime.now().toUtc().toIso8601String();
  }

  @override
  Future<List<ExerciseModel>> getExercises(String userId) async {
    print('LocalDataSource: Getting exercises for user: $userId');
    final db = await _dbHelper.database;


    // Tüm tabloları kontrol et
    final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    print('Available tables in database:');
    for (var table in tables) {
      print('Table: ${table['name']}');
    }

    // Tüm exercise'leri kontrol et
    final allExercises = await db.query('exercises');
    print('All exercises in database:');
    for (var exercise in allExercises) {
      print('Exercise: ${exercise['exerciseId']} - UserID: ${exercise['userId']} - Title: ${exercise['title']}');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    print('Found ${maps.length} exercises for user $userId');
    if (maps.isEmpty) {
      print('No exercises found for user: $userId');
    } else {
      print('Exercises for user $userId:');
      for (var map in maps) {
        print('Exercise: ${map['exerciseId']} - Title: ${map['title']}');
      }
    }

    return List.generate(maps.length, (i) => ExerciseModel.fromJson(maps[i]));
  }

  @override
  Future<ExerciseModel?> getExerciseById(String exerciseId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    if (maps.isEmpty) {
      return null;
    }
    return ExerciseModel.fromJson(maps.first);
  }

  @override
  Future<List<ExerciseModel>> getExercisesBySynced(
    String userId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => ExerciseModel.fromJson(maps[i]));
  }

  @override
  Future<void> createExercise(ExerciseModel exercise) async {
    final db = await _dbHelper.database;

    final exerciseWithTime = exercise.copyWith(
      updatedAt: _getCurrentUtcTime(),
      isSynced: "false",
    );
    await db.insert(
      'exercises',
      exerciseWithTime.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> createExerciseFromServer({
    required String exerciseId,
    required String userId,
    required String title,
    required String startDateTime,
    required String endDateTime,
    required String updatedAt,
  }) async {
    final db = await _dbHelper.database;

    final exercise = ExerciseModel(
      exerciseId: exerciseId,
      userId: userId,
      title: title,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isSynced: "true",
      updatedAt: updatedAt,
    );

    await db.insert(
      'exercises',
      exercise.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateExercise({
    required String exerciseId,
    required String userId,
    String? title,
    String? endDateTime,
    String? updatedAt,
    String? isSynced,
  }) async {
    final db = await _dbHelper.database;

    final Map<String, dynamic> updateData = {};

    if (title != null) updateData['title'] = title;
    if (endDateTime != null) updateData['endDateTime'] = endDateTime;
    if (updatedAt != null) updateData['updatedAt'] = updatedAt;
    if (isSynced != null) updateData['isSynced'] = isSynced;


    if (updateData.isEmpty) {
      throw Exception("Güncellenecek veri bulunamadı");
    }

    final count = await db.update(
      'exercises',
      updateData,
      where: 'exerciseId = ? AND userId = ?',
      whereArgs: [exerciseId, userId],
    );

    if (count == 0) {
      throw Exception("Exercise not found or user not authorized");
    }
  }

  @override
  Future<void> deleteExercise(String id) async {
    final db = await _dbHelper.database;

    await db.delete('media', where: 'exerciseId = ?', whereArgs: [id]);

    final count = await db.delete(
      'exercises',
      where: 'exerciseId = ?',
      whereArgs: [id],
    );
    if (count == 0) {
      throw Exception("Exercise not found");
    }
  }
}
