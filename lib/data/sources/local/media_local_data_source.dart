import 'package:incubator/data/models/media_model.dart';
import 'package:incubator/data/sources/local/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class MediaLocalDataSource {
  Future<List<MediaModel>> getMedia(String exerciseId);

  Future<MediaModel?> getMediaById(String mediaId);

  Future<List<MediaModel>> getMediaBySynced(String exerciseId);

  Future<void> createMedia(MediaModel media, String exerciseId);

  Future<void> updateMedia({
    required String exerciseId,
    required String mediaId,
    String? comments,
    String? updatedAt,
    String? isSynced,
  });

  Future<void> createMediaFromServer({
    required String mediaId,
    required String exerciseId,
    required String comment,
    required String updatedAt,
    required String filePath,
  });

  Future<void> deleteMedia(String mediaId, String exerciseId);
}

class MediaLocalDataSourcesImpl implements MediaLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _getCurrentUtcTime() {
    return DateTime.now().toUtc().toIso8601String();
  }

  @override
  Future<List<MediaModel>> getMedia(String exerciseId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'media',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return List.generate(maps.length, (i) => MediaModel.fromJson(maps[i]));
  }

  @override
  Future<MediaModel?> getMediaById(String mediaId) async {
    final db = await _dbHelper.database;
    print('Getting media by ID: $mediaId');
    final List<Map<String, dynamic>> maps = await db.query(
      'media',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
    );
    print('Found ${maps.length} media records');
    if (maps.isNotEmpty) {
      print('Media data: ${maps.first}');
    }

    if (maps.isEmpty) return null;
    return MediaModel.fromJson(maps.first);
  }

  @override
  Future<List<MediaModel>> getMediaBySynced(
    String userId
  ) async {
    final db = await _dbHelper.database;
    print('Getting all medias for user: $userId');

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.* 
      FROM media m
      INNER JOIN exercises e ON m.exerciseId = e.exerciseId
      WHERE e.userId = ?
    ''', [userId]);


    return List.generate(
      maps.length,
      (i) => MediaModel.fromJson(maps[i]),
    ).toList();
  }

  @override
  Future<void> createMedia(MediaModel media, String exerciseId) async {
    final db = await _dbHelper.database;
    final exerciseWithTime = media.copyWith(
      updatedAt: _getCurrentUtcTime(),
      isSynced: "false",
    );
      await db.insert(
        'media',
        exerciseWithTime.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  @override
  Future<void> createMediaFromServer({
    required String mediaId,
    required String exerciseId,
    required String comment,
    required String updatedAt,
    required String filePath,
  }) async {
    final db = await _dbHelper.database;

    final media = MediaModel(
      mediaId: mediaId,
      exerciseId: exerciseId,
      comments: comment,
      isSynced: "true",
      updatedAt: updatedAt,
      filePath: filePath,
    );

    await db.insert(
      'media',
      media.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateMedia({
    required String mediaId,
    required String exerciseId,
    String? comments,
    String? updatedAt,
    String? isSynced,
  }) async {

    final db = await _dbHelper.database;

    final Map<String, dynamic> updateData = {};

      if (comments != null) updateData['comments'] = comments;
      if (updatedAt != null) updateData['updatedAt'] = updatedAt;
      if (isSynced != null) updateData['isSynced'] = isSynced;

      if (updateData.isEmpty) return;

      await db.update(
        'media',
        updateData,
        where: 'mediaId = ? AND exerciseId = ?',
        whereArgs: [mediaId, exerciseId],
      );

  }

  @override
  Future<void> deleteMedia(String mediaId, String exerciseId) async {
    final db = await _dbHelper.database;
      await db.delete(
        'media',
        where: 'mediaId = ? AND exerciseId = ?',
        whereArgs: [mediaId, exerciseId],
      );
  }
}
